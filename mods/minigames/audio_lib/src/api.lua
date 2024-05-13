local function change_bgm_vol() end
local function stop_bgm() end
local function check_params_and_play() end
local function play_for_players() end
local function handle_sound() end
local function get_track_type() end

local BGM = {}                  -- KEY: track_name; VALUE: {name, description, params}  <- params as in MT params
local SFX = {}                  -- ^
local custom_types = {}         -- KEY: type_name; VALUE: {track_name1 = ^, track_name2 = ^}
-- Salvo l'info a parte, così da non inquinare custom_types (che si romperebbe
-- al primo ciclo for, in quanto avrebbe parametri che non sono tracce audio). In
-- futuro, se serviranno altre informazioni, tramutare valore in tabella con vari campi
local types_info = {}           -- KEY: type_name; VALUE: {mods = {mod1 = mod name, mod2 = mod name}, name}
-- I nomi delle tracce sono le cose più gettonate, per questo salvate anche a parte:
-- così da non dover copiare tabelle su tabelle ogni volta
local now_playing = {}      -- KEY: p_name; VALUE: {bgm = name, -- sfx = {name1, name2}, whatev_custom_type = {name1, name2},
                                                    -- _data = {bgm = {name, description, handle, started_at, params}, prev_bgm = {name, description, started_at, params},
                                                    -- sfx = {[name1] = {name, description, params}, [name2] = {name, description, params}},
                                                    -- whatev_custom_type = {[name1] = {name, description, handle, params}, [name2] = {name, description, handle, params}}}}



-- INTERNAL ONLY
function audio_lib.init_player(p_name)
  audio_lib.load_settings(p_name)
  now_playing[p_name] = {sfx = {}, _data = {bgm = {}, prev_bgm = {}, sfx = {}}}

  for k, _ in pairs(custom_types) do
    now_playing[p_name][k] = {}
    now_playing[p_name]._data[k] = {}
  end
end



function audio_lib.dealloc_player(p_name)
  now_playing[p_name] = nil
end





----------------------------------------------
---------------------CORE---------------------
----------------------------------------------

function audio_lib.register_type(mod, s_type, readable_names)
  assert(type ~= "bgm" and s_type ~= "sfx" and s_type ~= "main", "[AUDIO_LIB] Error! " .. s_type .. " is a built-in type, you can't register a type with the same name!")
  assert(not s_type:match("[^a-z0-9_]"), "[AUDIO_LIB] Error with music type " .. s_type .. "! Custom types can only contain lowercase letters, numbers and underscores!")

  -- to remove in 2.0
  if type(readable_names) == "string" then
    readable_names = {type = readable_names}
    minetest.log("warning", "[AUDIO_LIB] (" .. mod .. ") register_type(mod, s_type, name) is deprecated. Check the DOCS and use the new arguments")
  end

  local mod_name = readable_names.mod or mod
  local type_name = readable_names.type or s_type

  -- se è già registrato, controllo se proviene da un'altra mod e in caso la aggiungo
  if custom_types[s_type] then
    if not types_info[s_type].mods[mod] then
      types_info[s_type].mods[mod] = mod_name
    end

  -- sennò lo aggiungo e basta
  else
    custom_types[s_type] = {}
    types_info[s_type] = {
      name = type_name,
      mods = {[mod] = mod_name}
    }
  end
end



function audio_lib.register_sound(s_type, track_name, desc, def)
  assert(type(s_type) == "string", "[AUDIO_LIB] Error! The first parameter in `audio_lib.register_sound` must be a string!")
  assert(desc, "[AUDIO_LIB] Error! Description is mandatory for accessibility reasons. Let's everyone enjoy videogames!")
  -- TODO assert if audio track exists. It needs https://github.com/minetest/minetest/issues/4955

  def = def or {}
  def.to_player = nil
  def.object = nil
  def.pos = nil
  def.exclude_player = nil
  def.ephemeral = def.ephemeral ~= false and true or false

  if s_type == "bgm" then
    def.loop = true
    def.cant_overlap = true
    def.ephemeral = false

    BGM[track_name] = {
      name = track_name,
      description = desc,
      params = def
    }

  elseif s_type == "sfx" then
    def.loop = false
    def.ephemeral = true

    SFX[track_name] = {
      name = track_name,
      description = desc,
      params = def
    }

  elseif custom_types[s_type] then
    custom_types[s_type][track_name] = {
      name = track_name,
      description = desc,
      params = def
    }

  else
    minetest.log("error", "[AUDIO_LIB] Trying to register track \"" .. track_name .. "\" under the unknown type \"" .. s_type .. "\". Aborting")
  end
end



-- TODO: passare tabella se si vogliono incolonnare più canzoni
function audio_lib.play_bgm(p_name, track_name, override_params)
  if not now_playing[p_name] then return end

  local audio = table.copy(BGM[track_name])
  local params = audio.params

  if override_params then
    for k, v in pairs(override_params) do
      params[k] = v
    end
  end

  audio.started_at = minetest.get_us_time()
  params.to_player = p_name
  params.ephemeral = false

  -- se c'era già una canzone in corso
  if now_playing[p_name].bgm then
    local _data = now_playing[p_name]._data

    -- se è la stessa, non metterla in prev_bgm e interrompila soltanto
    if now_playing[p_name].bgm == track_name then
      minetest.sound_stop(_data.bgm.handle)

    else
      local curr_bgm = table.copy(_data.bgm)

      _data.prev_bgm = table.copy(_data.bgm)
      _data.prev_bgm.handle = nil
      _data.prev_bgm.params.start_time = (_data.prev_bgm.params.start_time or 0) + (minetest.get_us_time() - curr_bgm.started_at) / 1000000

      minetest.sound_stop(curr_bgm.handle)
    end
  end

  local p_settings = audio_lib.get_settings(p_name)

  params.gain = (params.gain or 1) * (p_settings.volume_bgm / 100) * (p_settings.volume_main / 100)
  local handle = minetest.sound_play(track_name, params)

  audio.handle = handle
  now_playing[p_name].bgm = track_name
  now_playing[p_name]._data.bgm = audio

  if audio_lib.get_settings(p_name).accessibility then
    audio_lib.HUD_accessibility_play(p_name, "bgm", audio)
  end
end



function audio_lib.change_bgm_volume(p_name, gain, fade_duration)
  local p_playing = now_playing[p_name]

  if not p_playing or not p_playing.bgm then return end
  assert(gain, "[AUDIO_LIB] Missing mandatory `gain` parameter in `change_bgm_volume()`")

  local _data = p_playing._data
  fade_duration = fade_duration or 0

  if not fade_duration or fade_duration <= 0 then
    change_bgm_vol(p_name, _data, gain)

  else
    local step = _data.bgm.params.gain / fade_duration
    minetest.sound_fade(_data.bgm.handle, step, gain)

    minetest.after(fade_duration, function()
      if not p_playing or not p_playing.bgm then return end
      change_bgm_vol(p_name, _data, gain)
    end)
  end
end



function audio_lib.continue_bgm(p_name)
  if not now_playing[p_name] then return end

  local _data = now_playing[p_name]._data

  if not next(_data.prev_bgm) then return end

  local prev_bgm = _data.prev_bgm

  audio_lib.play_bgm(p_name, prev_bgm.name, { start_time = prev_bgm.params.start_time })
end



function audio_lib.stop_bgm(p_name, fade_duration)
  local p_playing = now_playing[p_name]

  if not p_playing or not p_playing.bgm then return end

  local _data = p_playing._data
  fade_duration = fade_duration or 0

  if not fade_duration or fade_duration <= 0 then
    stop_bgm(p_name, p_playing, _data)

  else
    local step = _data.bgm.params.gain / fade_duration
    minetest.sound_fade(_data.bgm.handle, step, 0)

    minetest.after(fade_duration, function()
      if not p_playing or not p_playing.bgm then return end
      stop_bgm(p_name, p_playing, _data)
    end)
  end
end


function audio_lib.play_sound(track_name, override_params)
  local s_type = get_track_type(track_name)

  if not s_type then return end

  local is_sfx = s_type == "sfx"
  local audio = is_sfx and table.copy(SFX[track_name]) or table.copy(custom_types[s_type][track_name])
  local params = audio.params

  if override_params then
    for k, v in pairs(override_params) do
      params[k] = v
    end
  end

  if is_sfx then
    params.loop = false
    params.ephemeral = true
  end

  check_params_and_play(s_type, track_name, audio, params)
end



-- TODO: non va perché c'è da aspettare https://github.com/minetest/minetest/issues/12375.
-- Segnato anche nella documentazione. In generale, credo da riscrivere perché potrebbe
-- non dovrebbe prendere p_name, ma fare tanti controlli come su play_sound (se pos,
-- ecc)
function audio_lib.stop_sound(p_name, track_name)
  local p_playing = now_playing[p_name]

  if not p_playing then return end

  local s_type = get_track_type(track_name)

  if not s_type or not p_playing[s_type][track_name] then return end

  local _data = p_playing._data
  local handle = _data[s_type][track_name].handle

  if not handle then return end

  -- TODO: ci sarà poi da tenere in considerazione i nomi dei duplicati ("__1" ecc)
  minetest.sound_stop(handle)
  p_playing[s_type][track_name] = nil
  _data[s_type][track_name] = nil
end



function audio_lib.reload_music(p_name, old_settings)
  local p_playing = now_playing[p_name]
  if not p_playing then return end

  local p_settings = audio_lib.get_settings(p_name)
  local _data = p_playing._data

  if p_playing.bgm then
    local bgm = _data.bgm
    local params = bgm.params

    minetest.sound_stop(bgm.handle)

    local old_gain

    -- 1. Ottengo il vecchio volume invertendo il calcolo che lo determina (perché
    -- in caso di parametro sovrascritto tramite play_bgm(..), non mi è possibile
    -- ottenerlo da BGM[bgm])
    -- 2. tutti i parametri ~= 0 perché sennò se il volume di prima stava a 0, nella
    -- moltiplicazione in params.gain darebbe sempre 0
    if not params.gain or params.gain == 0 or old_settings.volume_main == 0 or old_settings.volume_bgm == 0 then
      old_gain = 1
    else
      old_gain = params.gain / (old_settings.volume_bgm / 100) / (old_settings.volume_main / 100)
    end

    params.gain = old_gain * (p_settings.volume_bgm / 100) * (p_settings.volume_main / 100)
    params.start_time = (params.start_time or 0) + (minetest.get_us_time() - bgm.started_at) / 1000000
    bgm.started_at = minetest.get_us_time()
    bgm.handle = minetest.sound_play(bgm.name, params)

    if p_settings.accessibility then
      audio_lib.HUD_accessibility_play(p_name, "bgm", _data.bgm)
    elseif old_settings.accessibility and not p_settings.accessibility then
      audio_lib.HUD_accessibility_stop(p_name, "bgm", bgm.name)
    end
  end
end





----------------------------------------------
-----------------GETTERS----------------------
----------------------------------------------

function audio_lib.get_player_bgm(p_name, in_detail)
  local p_playing = now_playing[p_name]
  if not p_playing then return end

  if not in_detail then
    return p_playing.bgm
  else
    local result = table.copy(p_playing._data.bgm)

    result.started_at = nil -- internal use only
    return result
  end
end



function audio_lib.get_player_sounds(s_type, p_name, in_detail)
  local p_playing = now_playing[p_name]
  if not p_playing then return end

  if not in_detail then
    local swapped = {}

    for k, _ in pairs(p_playing[s_type]) do
      swapped[#swapped +1] = k
    end

    return swapped
  else
    return table.copy(p_playing._data[s_type])
  end
end



function audio_lib.get_types()
  local types = {}

  for s_type, _ in pairs(custom_types) do
    table.insert(types, s_type)
  end

  return types
end



function audio_lib.get_type_name(s_type)
  return types_info[s_type].name
end



function audio_lib.get_mods_of_type(s_type)
  return types_info[s_type].mods
end





----------------------------------------------
--------------------UTILS---------------------
----------------------------------------------

function audio_lib.is_sound_registered(track_name, s_type)
  if not s_type then
    if BGM[track_name] ~= nil or SFX[track_name] then return true end

    for _, tracks in pairs(custom_types) do
      if tracks[track_name] then return true
      end
    end

  else
    if s_type == "bgm" then
      return BGM[track_name] ~= nil
    elseif s_type == "sfx" then
      return SFX[track_name] ~= nil
    elseif custom_types[s_type] then
      return custom_types[s_type][track_name] ~= nil
    end
  end
end





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function change_bgm_vol(p_name, _data, gain)
  local bgm = _data.bgm
  local params = bgm.params

  params.gain = gain
  params.start_time = (params.start_time or 0) + (minetest.get_us_time() - bgm.started_at) / 1000000
  audio_lib.play_bgm(p_name, bgm.name, params)
end



function stop_bgm(p_name, p_playing, _data)
  local track_name = p_playing.bgm

  p_playing.bgm = nil
  _data.prev_bgm = table.copy(_data.bgm)
  _data.bgm = {}

  minetest.sound_stop(_data.prev_bgm.handle)

  if audio_lib.get_settings(p_name).accessibility then
    audio_lib.HUD_accessibility_stop(p_name, "bgm", track_name)
  end
end



function check_params_and_play(s_type, track_name, audio, params)
  -- tutto il server
  if not params.pos and not params.object and not params.to_player and not params.exclude_player then
    play_for_players(minetest.get_connected_players(), s_type, track_name, audio, params)

  -- sennò...
  else
    -- pos
    if params.pos then
      local group = {}
      -- TODO: se MT fa riprodurre suoni posizionali/entità a chi entra nel raggio dopo che sono stati avviati,
      -- aggiungere un margine extra al raggio (es. +15 blocchi)
      for _, obj in pairs(minetest.get_objects_inside_radius(params.pos, params.max_hear_distance or 32)) do
        if obj:is_player()
           and (not params.to_player or params.to_player == obj:get_player_name())
           and (not params.exclude_player or params.exclude_player ~= obj:get_player_name()) then
          table.insert(group, obj)
        end
      end

      play_for_players(group, s_type, track_name, audio, params)

    -- object
    elseif params.object then
      local object = params.object
      local pos = object:get_pos()

      if not pos then return end

      local group = {}
      -- vedasi TODO in pos
      for _, obj in pairs(minetest.get_objects_inside_radius(pos, params.max_hear_distance or 32)) do
        if obj:is_player()
           and (not params.to_player or params.to_player == obj:get_player_name())
           and (not params.exclude_player or params.exclude_player ~= obj:get_player_name()) then
          table.insert(group, obj)
        end
      end

      play_for_players(group, s_type, track_name, audio, params)

    -- to_player
    elseif params.to_player then
      local player = minetest.get_player_by_name(params.to_player)
      if not player then return end

      play_for_players({player}, s_type, track_name, audio, params)

    -- exclude_player
    elseif params.exclude_player then
      local group = minetest.get_connected_players()
      for k, pl in pairs(group) do
        if pl:get_player_name() == params.exclude_player then
          k = nil
        end
      end

      play_for_players(group, s_type, track_name, audio, params)
    end
  end
end



function play_for_players(group, s_type, track_name, audio, params)
  local gain = audio.params.gain or 1

  for _, pl in pairs(group) do
    local pl_name = pl:get_player_name()
    local pl_settings = audio_lib.get_settings(pl_name)
    local type_volume = "volume_" .. s_type

    params.to_player = pl_name
    params.gain = gain * (pl_settings[type_volume] / 100) * (pl_settings.volume_main / 100)

    -- sfx sono per forza effimeri
    if s_type == "sfx" then
      minetest.sound_play(track_name, params, true)

    else
      if not params.ephemeral and params.cant_overlap then
        audio_lib.stop_sound(pl_name, track_name)
      end

      audio.handle = minetest.sound_play(track_name, params, params.ephemeral)
    end

    if audio_lib.get_settings(pl_name).accessibility then
      audio_lib.HUD_accessibility_play(pl_name, s_type, audio)
    end

    handle_sound(s_type, track_name, audio, pl_name)
  end
end



function handle_sound(s_type, track_name, audio, p_name)
  if not now_playing[p_name] then return end    -- in caso sia statə deallocatə prima dell'on_leaveplayer di un'altra mod che usa un suono

  local p_playing = now_playing[p_name]

  if p_playing[s_type][track_name] then
    for i = 1, 99999 do
      if not p_playing[s_type][track_name .. "__" .. i] then
        track_name = track_name .. "__" .. i
        break
      end
    end
  end

  p_playing[s_type][track_name] = true
  p_playing._data[s_type][track_name] = audio

  -- TEMP: hardcoded to 1s. https://github.com/minetest/minetest/issues/12375 needed to actually know the length of a track
  minetest.after(1, function()
    if not now_playing[p_name] then return end
    now_playing[p_name][s_type][track_name] = nil
    now_playing[p_name]._data[s_type][track_name] = nil
  end)
end



function get_track_type(track_name)
  if SFX[track_name] then return "sfx" end

  for type_name, type_data in pairs(custom_types) do
    for title, _ in pairs(type_data) do
      if track_name == title then
        return type_name
      end
    end
  end
end





----------------------------------------------
------------------DEPRECATED------------------
----------------------------------------------

-- to remove in 1.0
function audio_lib.play_sfx(track_name, override_params)
  minetest.log("warning", "[AUDIO_LIB] `audio_lib.play_sfx` is deprecated (track: " .. track_name .. "). Please use `audio_lib.play_sound` instead")
  audio_lib.play_sound(track_name, override_params)
end

function audio_lib.get_player_sfx(p_name, in_detail)
  minetest.log("warning", "[AUDIO_LIB] `audio_lib.get_player_sfx` is deprecated. Please use `audio_lib.get_player_sounds` instead")
  return audio_lib.get_player_sounds("sfx", p_name, in_detail)
end
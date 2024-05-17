local function can_override_panel() end
local function override_panel() end
local function calc_pos() end
local function hide_after_s() end
local function hide() end
local function flash() end

local MAX_SLOTS = 10 -- TODO: crasha se raggiunge il limite
local READING_DURATION = 1
local DIST_TRESHOLD = 1.5
local BG = "audiolib_hud_panel_bg.png"

-- contains data to then display onto panels. In case of duplicates, audio_name will be audio_name@1, audio_name@2 etc.
local curr_shown = {}           -- KEY: p_name; VALUE: {audio_name = {id = id, title = desc, icons = {left = "", right = ""}, pos = pos, object = obj,
                                --                      fading = false, fading_time = 0, after_func = func}}
local instances = {}            -- KEY: p_name; VALUE: {track_name = counter}
local panels_order = {}         -- KEY: p_name; VALUE: {n = audio_name}





minetest.register_globalstep(function(dtime)
  -- rimozione vecchi pannelli e aggiornamento indicatore posizione
  for pl_name, tracks in pairs(curr_shown) do
    for audio_name, data in pairs(tracks) do
      -- se non è BGM
      if data.id ~= -1 then
        -- rimozione vecchi pannelli
        if data.fading then
          data.fading_time = data.fading_time + dtime

          if data.fading_time >= 1 then
            hide(pl_name, audio_name)
          end
        end

        -- aggiornamento indicatore posizione (non aggiornare se sta svanendo)
        if not data.fading and (data.pos or data.object) then
          local pos = data.pos or data.object:get_pos()
          local main_panel, sub_txt = calc_pos(pl_name, pos)
          local panel = panel_lib.get_panel(pl_name, "audiolib_acc_" .. data.id)

          data.icons = {left = sub_txt.indicator_left.text, right = sub_txt.indicator_right.text}
          panel:update(main_panel, nil, sub_txt)
        end
      end
    end
  end

  -- renderizzazione pannelli
  for pl_name, data in pairs(panels_order) do
    for i, audio_name in pairs(data) do
      local track_data = curr_shown[pl_name][audio_name]
      local panel = panel_lib.get_panel(pl_name, "audiolib_acc_" .. i)
      local col = 0xFFFFFF

      if track_data.fading then
        local fading_time = track_data.fading_time
        if fading_time <= 0.25 then
          col = 0xD0C9C7
        elseif fading_time <= 0.5 then
          col = 0xB5ABA7
        else
          col = 0xA0938E
        end
      end

      panel:update({title = track_data.title, title_color = col}, nil, {indicator_left = {number = col, text = track_data.icons.left}, indicator_right = {number = col, text = track_data.icons.right}})
    end
  end
end)



function audio_lib.HUD_accessibility_create(p_name)
  curr_shown[p_name] = {}
  instances[p_name] = {}
  panels_order[p_name] = {}

  local y_off   = 0

  -- bgm
  Panel:new("audiolib_acc_bgm", {
    player = p_name,
    position  = {x = 1, y = 0.8},
    alignment = {x = -1, y = 0},
    offset = {x = 0, y = y_off},
    bg = BG .. "^[opacity:220",
    bg_scale = {x = 200, y = 37},
    title = "",
    title_offset = {x = -100, y = 0},
    z_index = 1000,
    sub_txt_elems = {
      indicator_left = {
        text = "",
        alignment = {x = 0},
        offset = {x = -185}
      },
      indicator_right = {
        text = "",
        alignment = {x = 0},
        offset = {x = -15}
      },
    },
    visible = false
  })

  y_off = -37

  -- sounds
  for i = 1, MAX_SLOTS - 1 do             -- MAX_SLOTS -1 due to bgm
    Panel:new("audiolib_acc_" .. i, {
      player = p_name,
      position  = {x = 1, y = 0.8},
      alignment = {x = -1, y = 0},
      offset = {x = 0, y = y_off},
      bg = "audiolib_hud_panel_bg.png^[opacity:220",
      bg_scale = {x = 200, y = 37},
      title = "Sound test plchldr",
      title_offset = {x = -100, y = 0},
      z_index = 1000,
      sub_txt_elems = {
        indicator_left = {
          text = "",
          alignment = {x = 0},
          offset = {x = -185}
        },
        indicator_right = {
          text = "",
          alignment = {x = 0},
          offset = {x = -15}
        },
      },
      visible = false
    })

    y_off = y_off - 37
  end
end



function audio_lib.HUD_accessibility_remove(p_name)
  curr_shown[p_name] = nil
  instances[p_name] = nil
  panels_order[p_name] = nil
end



function audio_lib.HUD_accessibility_play(p_name, s_type, audio)
  if not curr_shown[p_name] then return end

  -- non incolonnare in caso di suoni simili, ricomincia soltanto durata
  if s_type ~= "bgm" then
    local p_shown = curr_shown[p_name]
    local p_instances = instances[p_name]
    local p_data = p_shown[audio.name]
    local audio_name = audio.name

    -- potrebbe non esserci più l'originale ma solo le copie: prendi la prima
    if not p_data and p_instances[audio.name] then
      for i = 1, 99999 do
        if p_shown[audio.name .. "@" .. i] then
          audio_name = audio.name .. "@" .. i
          p_data = p_shown[audio_name]
          break
        end
      end
    end

    if p_data then
      local params = audio.params
      -- se ce n'è più di uno..
      if p_instances[audio.name] > 1 then
        -- controllo pannello con nome originale, se esiste
        if p_shown[audio.name] and can_override_panel(p_data, params) then
          override_panel(p_name, p_data, audio.name)
          return

        -- controllo gli altri (@N)
        else
          local name_to_update
          local remaining_duplicates = p_instances[audio.name]

          for i = 1, 99999 do
            local name = audio.name .. "@" .. i
            local p_data_i = p_shown[name]

            if p_data_i then
              remaining_duplicates = remaining_duplicates - 1

              if can_override_panel(p_data_i, params) then
                name_to_update = name
                p_data = p_data_i
                break
              end
            end

            if remaining_duplicates == 0 then
              break
            end
          end

          if name_to_update then
            override_panel(p_name, p_data, name_to_update)
            return
          end
        end

      -- .. sennò ce n'è solo uno
      else
        if can_override_panel(p_data, params) then
          override_panel(p_name, p_data, audio_name)
          return
        end
      end

      -- se arrivo qua, c'è da aumentare le istanze perché verrà creato un nuovo pannello
      p_instances[audio.name] = (p_instances[audio.name] or 0) + 1
    else
      p_instances[audio.name] = 1
    end
  end

  local panel
  local slot_id

  -- trovo pannello
  if s_type ~= "bgm" then
    for i = 1, MAX_SLOTS -1 do
      local ppanel = panel_lib.get_panel(p_name, "audiolib_acc_" .. i)

      if not ppanel:is_visible() then
        panel = ppanel
        slot_id = i
        break
      end
    end

    -- se non trova niente, cambia la 1° casella non bgm (abbastanza assurdo che
    -- vengano riprodotti più di 10 suoni alla volta, ma se proprio dovesse succedere..)
    if not slot_id then
      slot_id = 1
      panel = panel_lib.get_panel(p_name, "audiolib_acc_1")
    end

  else
    panel = panel_lib.get_panel(p_name, "audiolib_acc_bgm")
    slot_id = -1 -- non ho bisogno di un id per bgm ,che ha casella a parte
  end

  local p_shown = curr_shown[p_name]
  local audio_name = audio.name

  -- se ha duplicati, trasforma nome in nome@N
  if p_shown[audio_name] then
    for i = 1, 99999 do
      if not p_shown[audio_name .. "@" .. i] then
        audio_name = audio_name .. "@" .. i
        break
      end
    end
  end

  p_shown[audio_name] = {id = slot_id, title = audio.description, icons = {left = "", right = ""}, fading = false, fading_time = 0}

  if s_type ~= "bgm" then
    table.insert(panels_order[p_name], audio_name)
  end

  local main_panel = {title = audio.description, title_color = 0xffffff}
  local sub_txt = {}

  -- icona da mettere
  if s_type == "bgm" then
    sub_txt = {indicator_left = {text = "♪"}, indicator_right = {text = "♪"}}
  else
    local params = audio.params

    if params.pos or params.object then
      local sound_pos = params.pos or params.object:get_pos()
      local main_bg = {}

      main_bg, sub_txt = calc_pos(p_name, sound_pos)

      if params.pos then
        p_shown[audio_name].pos = params.pos
      else
        p_shown[audio_name].object = params.object
      end

      p_shown[audio_name].icons = {
        left = sub_txt.indicator_left.text,
        right = sub_txt.indicator_right.text
      }

      if next(main_bg) then
        main_panel.bg = main_bg.bg
      end
    else
      sub_txt = {indicator_left = {text = ""}, indicator_right = {text = ""}}
    end
  end

  sub_txt.indicator_left.number = 0xffffff
  sub_txt.indicator_right.number = 0xffffff

  panel:update(main_panel, nil, sub_txt)
  panel:show()

  if s_type ~= "bgm" then
    p_shown[audio_name].after_func = hide_after_s(p_name, audio_name)
  else
    flash(p_name, panel, audio.description)
  end
end



function audio_lib.HUD_accessibility_stop(p_name, s_type, track_name)
  if not minetest.get_player_by_name(p_name) then return end

  local p_data = curr_shown[p_name][track_name]

  if not p_data then return end

  if s_type == "bgm" then
    panel_lib.get_panel(p_name, "audiolib_acc_bgm"):hide()
    curr_shown[p_name][track_name] = nil

  else
    -- TODO: non supportato al momento
    -- fallo diventare un attimo rosso per indicare visivamente l'interruzione
  end
end





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function can_override_panel(p_data, params)
  if (params.pos and not p_data.pos) or (params.object and not p_data.object) or (p_data.pos and not params.pos) or (p_data.object and not params.object) then
    return false
  end

  if (not params.pos or vector.distance(p_data.pos, params.pos) < DIST_TRESHOLD)
     and (not params.object or vector.distance(p_data.object:get_pos(), params.object:get_pos()) < DIST_TRESHOLD) then
    return true
  end
end



function override_panel(p_name, p_data, audio_name)
  local panel = panel_lib.get_panel(p_name, "audiolib_acc_" .. p_data.id)

  p_data.fading = false
  p_data.fading_time = 0
  p_data.after_func:cancel()
  p_data.after_func = hide_after_s(p_name, audio_name)

  panel:update({title_color = 0xffffff}, nil, {indicator_left = {number = 0xffffff}, indicator_right = {number = 0xffffff}})
end



function calc_pos(p_name, sound_pos)
  local player = minetest.get_player_by_name(p_name)
  local p_pos = player:get_pos()
  local distance = vector.distance(sound_pos, p_pos)
  local ret1, ret2

  if distance < DIST_TRESHOLD then
    ret1, ret2 = {bg = BG .. "^[opacity:220"}, {indicator_left = {text = "•"}, indicator_right = {text = "•"}}

  else
    if distance < 5 then
      ret1 = {bg = BG .. "^[opacity:220"}
    elseif distance < 10 then
      ret1 = {bg = BG .. "^[opacity:190"}
    elseif distance < 15 then
      ret1 = {bg = BG .. "^[opacity:160"}
    elseif distance < 20 then
      ret1 = {bg = BG .. "^[opacity:130"}
    else
      ret1 = {bg = BG .. "^[opacity:100"}
    end

    local p_dir = player:get_look_dir()
    local to_target_dir = vector.direction(p_pos, sound_pos)
    local deg = math.deg(math.atan2(p_dir.z, p_dir.x) - math.atan2(to_target_dir.z, to_target_dir.x))

    if math.abs(deg) < 10 then
      ret2 = {indicator_left = {text = "^"}, indicator_right = {text = "^"}}
    elseif math.abs(deg) > 170 then
      ret2 = {indicator_left = {text = "v"}, indicator_right = {text = "v"}}
    elseif deg > 10 and deg < 45 then
      ret2 = {indicator_left = {text = ""}, indicator_right = {text = "^"}}
    elseif deg > -45 and deg < -10 then
      ret2 = {indicator_left = {text = "^"}, indicator_right = {text = ""}}
    elseif deg > 135 and deg < 170 then
      ret2 = {indicator_left = {text = ""}, indicator_right = {text = "v"}}
    elseif deg > -170 and deg < -135 then
      ret2 = {indicator_left = {text = "v"}, indicator_right = {text = ""}}
    elseif deg < 0 then
      ret2 = {indicator_left = {text = "<"}, indicator_right = {text = ""}}
    else
      ret2 = {indicator_left = {text = ""}, indicator_right = {text = ">"}}
    end
  end

  return ret1, ret2
end



function hide_after_s(p_name, audio_name)
  return minetest.after(math.max(0.75, READING_DURATION), function() -- TODO: sostituire poi 0.75 con duration
    if not minetest.get_player_by_name(p_name) or not curr_shown[p_name][audio_name] then return end
    curr_shown[p_name][audio_name].fading = true
  end)
end



function hide(p_name, audio_name)
  local p_instances = instances[p_name]
  local stripped_name = string.gsub(audio_name, "@%d", "")

  -- diminuisco contatore istanze
  p_instances[stripped_name] = p_instances[stripped_name] - 1

  if p_instances[stripped_name] == 0 then
    p_instances[stripped_name] = nil
  end

  local id = curr_shown[p_name][audio_name].id

  -- scalo id
  for _, val in pairs(curr_shown[p_name]) do
    if val.id > id then
      val.id = val.id - 1
    end
  end

  local panels_amount = #panels_order[p_name]
  local panel = panel_lib.get_panel(p_name, "audiolib_acc_" .. panels_amount)

  curr_shown[p_name][audio_name] = nil
  table.remove(panels_order[p_name], id)
  panel:hide()
end



function flash(p_name, panel, txt)
  local white = "^[fill:1000x1000:0,0:#ffffff^[opacity:220"
  local black = "^[opacity:220"

  panel:update({bg = BG .. white, title_color = 0x000000})

  minetest.after(0.1, function()
    if not minetest.get_player_by_name(p_name) or not panel:is_visible() or txt ~= panel:get_info().title.text then return end
    panel:update({bg = BG .. black, title_color = 0xffffff})

    minetest.after(0.1, function()
      if not minetest.get_player_by_name(p_name) or not panel:is_visible() or txt ~= panel:get_info().title.text then return end
      panel:update({bg = BG .. white, title_color = 0x000000})

      minetest.after(0.1, function()
        if not minetest.get_player_by_name(p_name) or not panel:is_visible() or txt ~= panel:get_info().title.text then return end
        panel:update({bg = BG .. black, title_color = 0xffffff})
      end)
    end)
  end)
end
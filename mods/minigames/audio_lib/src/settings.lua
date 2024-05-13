local function check_settings() end

local storage = minetest.get_mod_storage()

local p_settings = {}
local default_settings = {
  volume_main = 100,
  volume_bgm = 100,
  volume_sfx = 100,
  accessibility = false,
  -- custom types added in load_settings
}


function audio_lib.load_settings(p_name)
  local settings = storage:get_string(p_name)

  if storage:get_string(p_name) == "" then
    settings = table.copy(default_settings)

    for _, s_type in pairs(audio_lib.get_types()) do
      settings["volume_" .. s_type] = 100
    end

    storage:set_string(p_name, minetest.serialize(settings))
    p_settings[p_name] = settings
  else
    settings = minetest.deserialize(settings)
    check_settings(settings, p_name)

    p_settings[p_name] = settings

    --v------------- legacy update, to remove in 1.0 ---------------v--
    if not p_settings[p_name].volume_sfx then
      p_settings[p_name].volume_sfx = default_settings.volume_sfx
      storage:set_string(p_name, minetest.serialize(p_settings[p_name]))
    end
    --^-------------------------------------------------------------^--

    --v------------- legacy update, to remove in 2.0 ---------------v--
    if not p_settings[p_name].accessibility then
      p_settings[p_name].accessibility = false
      storage:set_string(p_name, minetest.serialize(p_settings[p_name]))
    end
    --^-------------------------------------------------------------^--
  end
end



-- se settings == "_ALL_", val deve essere tabella
function audio_lib.save_settings(p_name, setting, val)
  local old_settings = table.copy(p_settings[p_name])

  if setting ~= "_ALL_" then
    p_settings[p_name][setting] = val
  elseif type(val) == "table" then
    p_settings[p_name] = val
  end

  storage:set_string(p_name, minetest.serialize(p_settings[p_name]))
  audio_lib.reload_music(p_name, old_settings)
end





----------------------------------------------
-----------------GETTERS----------------------
----------------------------------------------

function audio_lib.get_settings(p_name)
  return p_settings[p_name]
end





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function check_settings(settings, p_name)
  local custom_types = audio_lib.get_types()
  local to_update = false

  -- se non c'è un tipo personalizzato, aggiungilo
  for _, s_type in pairs(custom_types) do
    local setting = "volume_" .. s_type
    if not settings[setting] then
      settings[setting] = 100
      to_update = true
    end
  end

  local swapped_types = table.key_value_swap(custom_types)
  local settings_custom_only = table.copy(settings)

  settings_custom_only.volume_main = nil
  settings_custom_only.volume_bgm = nil
  settings_custom_only.volume_sfx = nil
  settings_custom_only.accessibility = nil

  -- rimuovi eventuali tipi personalizzati che ora non esistono più
  for setting, _ in pairs(settings_custom_only) do
    if not swapped_types[setting:sub(8,-1)] then -- rimuovo "volume_"
      settings[setting] = nil
      to_update = true
    end
  end

  if to_update then
    storage:set_string(p_name, minetest.serialize(settings))
  end
end

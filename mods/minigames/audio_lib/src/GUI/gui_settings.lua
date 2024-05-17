local S = minetest.get_translator("audio_lib")

local function get_formspec() end

local temp_settings = {}          -- KEY: p_name, VALUE: {accessibility = true/false}



minetest.register_tool("audio_lib:settings", {
    description = S("Audio Settings"),
    inventory_image = "audiolib_settings.png",
    on_place = function() end,
    on_drop = function() end,

    on_use = function(itemstack, user, pointed_thing)
      local p_name = user:get_player_name()
      audio_lib.open_settings(p_name)
    end
})





----------------------------------------------
--------------------UTILS---------------------
----------------------------------------------

function audio_lib.open_settings(p_name)
  temp_settings[p_name] = {accessibility = audio_lib.get_settings(p_name).accessibility}
  minetest.show_formspec(p_name, "audio_lib:p_settings", get_formspec(p_name))
end





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function get_formspec(p_name)
  local p_settings = audio_lib.get_settings(p_name)

  -- TEMP: hack by Luk3yx, waiting for https://github.com/minetest/minetest/issues/13993
  local main_val = {"label[0,0.3;0]"}
  local bgm_val = {"label[0,0.3;0]"}
  local sfx_val = {"label[0,0.3;0]"}
  local types_val = ""

  for i = 1, 100 do
    main_val[i+1] = ("label[0,%s;%s]"):format(i + 0.3, i)
    bgm_val[i+1] = ("label[0,%s;%s]"):format(i + 0.3, i)
    sfx_val[i+1] = ("label[0,%s;%s]"):format(i + 0.3, i)
  end

  main_val = table.concat(main_val, "")
  bgm_val = table.concat(bgm_val, "")
  sfx_val = table.concat(sfx_val, "")

  local y = 1.98 -- 0.7 distance of one section from another. Sfx is at 1.28

  -- tipi personalizzati
  for _, s_type in pairs(audio_lib.get_types()) do
    local mods = {}

    for _, mod_name in pairs(audio_lib.get_mods_of_type(s_type)) do
      table.insert(mods, mod_name)
    end
    table.sort(mods)

    local mods_involved = table.concat(mods, ", ")
    local vol_setting = "volume_" .. s_type
    local body = {
      "box[-5.5," .. y - 0.275 .. ";12,0.01;#a0938e]",
      "image[-5.9," .. y - 0.06 .. ";0.4,0.4;audiolib_gui_help.png]",
      "tooltip[-5.9," .. y - 0.06 .. ";0.4,0.4;" .. S("Used by:\n@1", mods_involved) .. "]",
      "label[-5.5," .. y + 0.12 .. ";" .. audio_lib.get_type_name(s_type) .. "]",
      "scrollbar[0.4," .. y .. ";5.2,0.2;;" .. vol_setting .. ";" .. p_settings[vol_setting] .. "]",
      "scroll_container[5.75," .. y - 0.18 .. ";1,0.6;" .. vol_setting .. ";vertical;1]"
    }
    local type_val = {"label[0,0.3;0]"}

    for i = 1, 100 do
      type_val[i+1] = ("label[0,%s;%s]"):format(i + 0.3, i)
    end

    types_val = types_val .. table.concat(body, "") ..  table.concat(type_val, "") .. "scroll_container_end[]"
    y = y + 0.7
  end

  local responsive_y = (0.7 * #audio_lib.get_types())
  local formspec = {
    "formspec_version[4]",
    "size[13," .. 4.6 + responsive_y .. "]",
    "bgcolor[;false]",
    "style_type[image_button;border=false]",
    "scrollbaroptions[max=100;smallstep=1;largestep=10;arrows=hide]",
    "hypertext[0.5,0;12,0.95;audio_settings;<global font=mono size=20 halign=center valign=middle>" .. S("Audio Settings") .. "]",
    -- icone in alto a dx
    "image[11.7,0.06;0.7,0.7;audiolib_gui_help.png]",
    "tooltip[11.7,0.06;0.7,0.7;" .. S("It only affects mods that use audio_lib") .. "]",
    "image_button[12.37,0.17;0.481,0.481;audiolib_gui_close.png;close;]", -- can't style image_button_exit
    -- parametri
    "container[0.5,1.4]",
    "label[0,0;" .. S("Main") .. "]",
    "box[0,0.325;12,0.01;#a0938e]",
    "label[0,0.7;" .. S("BGM") .. "]",
    "box[0,1.025;12,0.01;#a0938e]",
    "label[0,1.4;" .. S("SFX") .. "]",
    "container[5.5,0]",
    "scrollbar[0.4,-0.12;5.2,0.2;;volume_main;" .. p_settings.volume_main .. "]",
    "scroll_container[5.75,-0.3;1,0.6;volume_main;vertical;1]",
    main_val,
    "scroll_container_end[]",
    "scrollbar[0.4,0.58;5.2,0.2;;volume_bgm;" .. p_settings.volume_bgm .. "]",
    "scroll_container[5.75,0.4;1,0.6;volume_bgm;vertical;1]",
    bgm_val,
    "scroll_container_end[]",
    "scrollbar[0.4,1.28;5.2,0.2;;volume_sfx;" .. p_settings.volume_sfx .. "]",
    "scroll_container[5.75,1.1;1,0.6;volume_sfx;vertical;1]",
    sfx_val,
    "scroll_container_end[]",
    types_val,
    "container_end[]",
    "container_end[]",
    "container[4.45," .. 3.7 + responsive_y .. "]",
    "checkbox[-4,0.28;accessibility;" .. S("Accessibility") .. ";" .. tostring(p_settings.accessibility) .. "]",
    "button[0,0;2,0.6;reset;" .. S("Reset") .. "]",
    "button[2.1,0;2,0.6;apply;" .. S("Apply") .."]",
    "container_end[]",
  }

  return table.concat(formspec, "")
end





----------------------------------------------
---------------GESTIONE CAMPI-----------------
----------------------------------------------

minetest.register_on_player_receive_fields(function(player, formname, fields)
  if formname ~= "audio_lib:p_settings" then return end

  local p_name = player:get_player_name()

  if fields.close or fields.quit then
    temp_settings[p_name] = nil
    minetest.close_formspec(p_name, "audio_lib:p_settings")

  elseif fields.reset then
    local settings = {
      volume_main = 100,
      volume_bgm = 100,
      volume_sfx = 100
    }

    for _, s_type in pairs(audio_lib.get_types()) do
      local vol_setting = "volume_" .. s_type
      settings[vol_setting] = 100
    end

    audio_lib.save_settings(p_name, "_ALL_", settings)
    minetest.close_formspec(p_name, "audio_lib:p_settings")

    minetest.after(0.1, function()
      audio_lib.open_settings(p_name)
    end)

  -- applico il tutto
  elseif fields.apply then
    local settings = {
      volume_main = minetest.explode_scrollbar_event(fields.volume_main).value,
      volume_bgm = minetest.explode_scrollbar_event(fields.volume_bgm).value,
      volume_sfx = minetest.explode_scrollbar_event(fields.volume_sfx).value,
      accessibility = temp_settings[p_name].accessibility
    }

    for _, s_type in pairs(audio_lib.get_types()) do
      local vol_setting = "volume_" .. s_type
      settings[vol_setting] = minetest.explode_scrollbar_event(fields[vol_setting]).value
    end

    audio_lib.save_settings(p_name, "_ALL_", settings)

  elseif fields.accessibility then
    temp_settings[p_name].accessibility = not temp_settings[p_name].accessibility
  end
end)

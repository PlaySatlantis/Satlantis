local S = minetest.get_translator("collectible_skins")
local function FS(...) return minetest.formspec_escape(S(...)) end

local locked_skin = {
  name        = "???",
  description = "???",
  collection  = "",   -- TODO: con questa versione del formspec tanto non serve
  model       = nil,
  texture     = nil,
  preview     = "cskins_locked.png",
  splash_art  = "blank.png"
}



function collectible_skins.get_formspec(p_name, page, skin_ID)
  local selected_skin
  local skin_bg
  local skin_stars

  -- se la skin è bloccata o meno
  if skin_ID == "LOCKED" then
    selected_skin = locked_skin
    skin_bg = "cskins_gui_bg_locked.png"
    skin_stars = "blank.png"

    minetest.get_player_by_name(p_name):get_meta():set_int("collectible_skins:selected_skin_ID", -1)        -- metadato per "Wear" se è bloccata

  else
    selected_skin = collectible_skins.get_skin(skin_ID) or collectible_skins.get_skin(1) -- evita che possano abusare del valore passato nei formspec
    skin_bg = "cskins_gui_bg_tier" .. selected_skin.tier .. ".png"
    skin_stars = "cskins_gui_stars" .. selected_skin.tier .. ".png"

    minetest.get_player_by_name(p_name):get_meta():set_int("collectible_skins:selected_skin_ID", skin_ID)    -- metadato per "Wear" se è sbloccata
  end

  local fs_begin = {
    "formspec_version[4]",
    "size[16.15,9.24]",
    "no_prepend[]",
    "background[0,0;16.15,9.24;cskins_gui_bg.png]",
    "style_type[image_button;border=false]",
    "style[wear;font=mono;textcolor=#dff6f5]",
    "bgcolor[;true]",
    "image_button[14.65,0.1;0.6,0.6;cskins_gui_close.png;close;]"
  }

  local skins_amount = #collectible_skins.get_skins()
  local arrows = skins_amount > 16 and "image_button[0.2,6;0.7,1.2;cskins_gui_arrow_left.png;GO_LEFT]image_button[15.2,6;0.7,1.2;cskins_gui_arrow_right.png;GO_RIGHT;]" or ""

  local formspec = {
    -- immagini
    "image[0,0;16.15,9.24;" .. skin_bg .. "]",
    "image[0,0;16.15,9.24;" .. selected_skin.splash_art .. "]",
    "image[0,0;16.15,9.24;cskins_gui_overlay.png]",
    -- skin selezionata
    "image[1.95,0.85;1.05,0.15;" .. skin_stars .. "]",
    "image[1.77,0.92;1.5,2.34;" .. selected_skin.preview .. "]",
    -- pulsanti
    "image_button[1.87,3.2;1.3,0.3;cskins_gui_button_wear.png;WEAR;" .. S("Wear") .. "]",
    arrows,
    -- testo
    "hypertext[3.6,0.85;4,1;name; <global size=23 font=mono color=#7a444a><b>" .. selected_skin.name .. "</b>]",
    "hypertext[3.6,1.25;3.2,2;desc; <global size=12 font=mono halign=justify color=#a05b53><i>" .. FS(selected_skin.description) .. "</i>]"
  }

  local first_idx = (math.floor(skins_amount / 16) + 1) * page

  -- creo slot in matrice x*y
  for y = 1, 2 do
    for x = 1, 8 do

      local skin_ID = (x + (8 * (y-1))) * first_idx

      -- se ho raggiunto il numero massimo di skin, interrompo
      if skin_ID > skins_amount then
        break
      end

      local size_x = 1.603
      local size_y = 2.462
      local pos_x = size_x * x
      local pos_y = size_y * y
      local indent_x = 0.04
      local indent_y = 1.8
      local slot_size = size_x .. "," .. size_y .. ";"
      local slot_pos = indent_x + pos_x ..  "," .. indent_y + pos_y .. ";"
      local skin = collectible_skins.get_skin(skin_ID)

      if collectible_skins.is_skin_unlocked(p_name, skin_ID) then
        table.insert(formspec, skin_ID, "image_button[" .. slot_pos .. slot_size .. skin.preview .. ";" .. skin_ID .. ";]")
      else
        table.insert(formspec, skin_ID, "image_button[" .. slot_pos .. slot_size .. "cskins_gui_button.png;LOCKED;]")
        table.insert(formspec, skin_ID +1, "tooltip[" .. slot_pos .. slot_size .. FS(skin.hint) .. " ;#dff6f5;#5a5353]")
      end
    end
  end

  table.insert(formspec, 1, table.concat(fs_begin, ""))

  return table.concat(formspec, "")
end



function FS(txt)
	return minetest.formspec_escape(S(txt))
end





----------------------------------------------
---------------GESTIONE CAMPI-----------------
----------------------------------------------

minetest.register_on_player_receive_fields(function(player, formname, fields)

  if formname ~= "collectible_skins:GUI" then return end
  if fields.quit or fields.key_up or fields.key_down then return end

  local p_name = player:get_player_name()

  if fields.close then
    minetest.close_formspec(p_name, "collectible_skins:GUI")
    return
  end

  -- se provo a indossarla
  if fields.WEAR then
    local skin_ID = player:get_meta():get_int("collectible_skins:selected_skin_ID")

    -- se è sbloccata, indosso la skin e chiudo il formspec
    if skin_ID ~= -1 then
      collectible_skins.set_skin(player, skin_ID, true)
      minetest.close_formspec(p_name, "collectible_skins:GUI")
      --TODO: suono + effetto particellare
    -- sennò riproduco un suono d'errore
    else
      minetest.sound_play("cskins_deny", {to_player = p_name})
    end

  -- se provo a cambiar pagina
  elseif fields.GO_LEFT then
  elseif fields.GO_RIGHT then

  -- selezione skin
  elseif fields.LOCKED then
    minetest.show_formspec(p_name, "collectible_skins:GUI", collectible_skins.get_formspec(p_name, 1, "LOCKED"))
  else
    local skin_ID = tonumber(string.match(dump(fields), "(%d+)"))
    minetest.show_formspec(p_name, "collectible_skins:GUI", collectible_skins.get_formspec(p_name, 1, skin_ID))
  end

end)

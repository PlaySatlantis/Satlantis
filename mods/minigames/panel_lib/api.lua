local panels = {}       -- KEY: p_name; VALUE: {{"panel name" = panel}, {"panel name 2" = panel2}, ...}

local function clone_table() end
local function add_sub_elem() end
local function update_sub_elems() end

Panel = {
    name = "",
    -- player to show the panel to
    player_name = "",
    -- ids of the hud of the player
    hud_id = {},
    -- text values of the huds, to retrieve on :show()
    hud_text = {},
    -- because the panel is composed by a background and a text we need to
    -- define the two HUD to use later
    background_def = {
        hud_elem_type = "image",
        position = { x = 0.5, y = 0.5 },
        scale = { x = 1, y = 1 },
        alignment = { x = 0, y = 0 },
        offset    = {x = 0, y = 0},
        text = "panel_bg.png",
        z_index = 0
    },
    title_def = {
        hud_elem_type = "text",
        position  = {x = 0.5, y = 0.5},
        alignment = {x = 0, y = 0},
        offset    = {x = 0, y = 0},
        size      = { x = 1 },
        number    = 0xFFFFFF,
        text      = "",
        z_index   = 0
    },

    sub_img_elems = {},       -- KEY: ID, VALUE: name
    sub_txt_elems = {},       -- KEY: ID, VALUE: name

    visible = true
}



function Panel:new(name, def)
    local panel = {}
    local metapanel = clone_table(Panel)

    setmetatable(panel, metapanel)
    metapanel.__index = metapanel

  --v------------------ LEGACY UPDATE, to remove in 3.0 -------------------v
    if type(name) == "table" and def == nil then
      minetest.log("warning", "[PANEL_LIB] Panel declaration deprecated. Please put the panel name outside of the def table as it follows -> Panel:new(name, def)")
      def = clone_table(name)
      name = def.name
    end

    if def.is_shown ~= nil then
      minetest.log("warning", "[PANEL_LIB] `is_shown` is deprecated. Use `visible` instead")
      def.visible = def.is_shown
    end
    --^------------------ LEGACY UPDATE, to remove in 3.0 -------------------^

    if not name or type(name) ~= "string" then
      minetest.log("warning", "[PANEL_LIB] Can't create a panel without a proper name, aborting")
      return
    else
      panel.name = name
    end

    if def.position then
      panel.background_def.position = def.position
      panel.title_def.position = def.position
    end

    if def.alignment then
      panel.background_def.alignment = def.alignment
    end

    if def.offset then
      panel.background_def.offset = def.offset
      panel.title_def.offset = def.offset
    end

    if def.z_index then
      panel.background_def.z_index = def.z_index
      panel.title_def.z_index = def.z_index
    end

    if def.bg then
      panel.background_def.text = def.bg
    end

    if def.bg_scale then
      panel.background_def.scale = def.bg_scale
    end

    if def.title then
      panel.title_def.text = def.title
    end

    if def.title_alignment then
      panel.title_def.alignment = def.title_alignment
    end

    if def.title_offset then
      if not def.offset then
        panel.title_def.offset = def.title_offset
      else
        panel.title_def.offset = {x = panel.title_def.offset.x + (def.title_offset.x or 0), y = panel.title_def.offset.y + (def.title_offset.y or 0)}
      end
    end

    if def.title_color then
      panel.title_def.number = def.title_color
    end

    if def.title_size then
      panel.title_def.size = def.title_size
    end

    if def.player then
      panel.player_name = def.player
    end

    if def.visible ~= nil and type(def.visible) == "boolean" then
      panel.visible = def.visible
    end

    panel.hud_text.bg_hud_txt = panel.background_def.text
    panel.hud_text.text_hud_txt = panel.title_def.text

    -- se il pannello non è mostrato di base, svuoto sfondo e titolo
    if panel.visible == false then
      panel.background_def.text = ""
      panel.title_def.text = ""
    end

    local player = minetest.get_player_by_name(def.player)

    -- assegno sfondo e titolo
    panel.hud_id.bg_hud_id = player:hud_add(panel.background_def)
    panel.hud_id.text_hud_id = player:hud_add(panel.title_def)

    -- controllo sottoelementi
    if def.sub_img_elems then
      for subname, HUD_elem in pairs(def.sub_img_elems) do
        add_sub_elem(panel, "image", subname, HUD_elem)
      end
    end

    if def.sub_txt_elems then
      for subname, HUD_elem in pairs(def.sub_txt_elems) do
        add_sub_elem(panel, "text", subname, HUD_elem)
      end
    end

    -- salvo in memoria
    if not panels[def.player] then
      panels[def.player] = {}
    end
    panels[def.player][name] = panel

    return panel
end



function Panel:show()
	local player = minetest.get_player_by_name(self.player_name)

  if self.hud_text.bg_hud_txt ~= "" then
    player:hud_change(self.hud_id.bg_hud_id, "text", self.hud_text.bg_hud_txt)
  end
  if self.hud_text.text_hud_txt ~= "" then
    player:hud_change(self.hud_id.text_hud_id, "text", self.hud_text.text_hud_txt)
  end

  --check for custom elements
  for _, name in pairs(self.sub_img_elems) do
    player:hud_change(self.hud_id[name], "text", self.hud_text[name])
  end

  for _, name in pairs(self.sub_txt_elems) do
    player:hud_change(self.hud_id[name], "text", self.hud_text[name])
  end

  self.visible = true
end



function Panel:hide()

  if (self.hud_id) then
    local player = minetest.get_player_by_name(self.player_name)

    for k, v in pairs(self.hud_id) do
      player:hud_change(self.hud_id[k], "text", "")
    end
	end

  self.visible = false
end



function Panel:update(def, txt_elems, img_elems)

  if def ~= nil then
    local player = minetest.get_player_by_name(self.player_name)

    for k, v in pairs(def) do
      -- aggiorno eventuale posizione, influenzando anche i vari sottoelementi
      if k == "position" then
        self.background_def.position = v
        self.title_def.position = v

        for _, elem in pairs(self.sub_img_elems) do
          local HUD_ID = self.hud_id[elem]
          player:hud_change(HUD_ID, k, v)
        end

        for _, elem in pairs(self.sub_txt_elems) do
          local HUD_ID = self.hud_id[elem]
          player:hud_change(HUD_ID, k, v)
        end

        player:hud_change(self.hud_id.bg_hud_id, k, v)
        player:hud_change(self.hud_id.text_hud_id, k, v)

      -- aggiorno eventuale scostamento, influenzando anche i vari sottoelementi
      elseif k == "offset" then
        self.background_def.offset = v
        self.title_def.offset = v

        for _, elem in pairs(self.sub_img_elems) do
          local HUD_ID = self.hud_id[elem]
          local offset = { x = (v.x or 0) + (self[elem].offset.x or 0), y = (v.y or 0) + (self[elem].offset.y or 0)}
          player:hud_change(HUD_ID, k, offset)
        end

        for _, elem in pairs(self.sub_txt_elems) do
          local HUD_ID = self.hud_id[elem]
          local offset = { x = (v.x or 0) + (self[elem].offset.x or 0), y = (v.y or 0) + (self[elem].offset.y or 0)}
          player:hud_change(HUD_ID, k, offset)
        end

        player:hud_change(self.hud_id.bg_hud_id, k, v)
        player:hud_change(self.hud_id.text_hud_id, k, v)

      -- aggiorno eventuale sfondo
      elseif k == "bg" then
        self.hud_text.bg_hud_txt = v
        self.background_def.text = v

        if self:is_visible() then
          player:hud_change(self.hud_id.bg_hud_id, "text", v)
        end

      -- aggiorno eventuali proprietà titolo
      elseif k == "title" or k == "title_color" then

        if k == "title" then
          self.hud_text.text_hud_txt = v
          self.title_def.text = v
          if self:is_visible() then
            player:hud_change(self.hud_id.text_hud_id, "text", v)
          end
        else
          self.title_def.number = v
          player:hud_change(self.hud_id.text_hud_id, "number", v)
        end

      else
        error("[PANEL_LIB] Invalid or unsupported element type, check DOCS and spelling")
        return
      end
    end
  end

  if txt_elems ~= nil then
    update_sub_elems(self, txt_elems)
  end

  if img_elems ~= nil then
    update_sub_elems(self, img_elems)
  end
end



function Panel:remove()
  panels[self.player_name][self.name] = nil

  local player = minetest.get_player_by_name(self.player_name)

  for k, v in pairs(self.hud_id) do
    player:hud_remove(self.hud_id[k])
  end

  self = nil
end



function Panel:get_info()
  local info = {}
  info.bg       = table.copy(self.background_def)
  info.title    = table.copy(self.title_def)

  return info
end



function Panel:is_visible()
  return self.visible
end



function Panel:add_sub_elem(type, name, HUD_elem)
  add_sub_elem(self, type, name, HUD_elem)
end



function Panel:remove_sub_elem(name)
  self.sub_txt_elems[name] = nil
  self.sub_img_elems[name] = nil

  if self.visible then
    minetest.get_player_by_name(self.player_name):hud_remove(self.hud_id[name])
  end
  self.hud_id[name] = nil
  self.hud_text[name] = nil

  self[name] = nil
end





-------------------------------------
---------------UTILITÀ---------------
-------------------------------------

function panel_lib.has_panel(p_name, panel_name)
  return panels[p_name] and panels[p_name][panel_name]
end



-- internal use only
function panel_lib.remove_all(p_name)
  panels[p_name] = nil
end





----------------------------------------------
-----------------GETTERS----------------------
----------------------------------------------

function panel_lib.get_panel(p_name, panel_name)
  return panels[p_name][panel_name]
end





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

-- code from => http://lua-users.org/wiki/CopyTable
function clone_table(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[clone_table(orig_key)] = clone_table(orig_value)
        end
        setmetatable(copy, clone_table(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end



function add_sub_elem(panel, type, name, HUD_elem)

  local sub_elems
  local mould

  if type == "text" then
    sub_elems = panel.sub_txt_elems
    mould = panel.title_def
  elseif type == "image" then
    sub_elems = panel.sub_img_elems
    mould = panel.background_def
  else
    error("[PANEL_LIB] type must be either 'text' or 'image'!")
  end

  if panel[name] then
    minetest.log("error", "[PANEL_LIB] Attempt to create a sub element with the same name of another. Aborting")
    return end

  -- clono la tabella di riferimento e ne modifico i valori con quelli del sottoelemento
  sub_elems[#sub_elems +1] = name
  panel[name] = clone_table(mould)

  for k, v in pairs(HUD_elem) do
    panel[name][k] = v
  end

  -- mantengo la stessa posizione del corpo del panello, costringendo
  -- l'utente a modificare gli scostamenti se vuole spostare gli elementi
  panel[name].position = mould.position

  -- mostro l'elemento se il pannello era già visibile
  panel[name].text = panel:is_visible() and panel[name].text or ""

  -- salvo
  panel.hud_id[name] = minetest.get_player_by_name(panel.player_name):hud_add(panel[name])
  panel.hud_text[name] = HUD_elem.text

  -- se sia il pannello che il sottoelemento hanno scostamenti personalizzati,
  -- li sommo DOPO aver salvato il pannello, senza che la somma venga salvata in
  -- panel[name]. Questo perché i sottoelementi devono salvare solo il proprio
  -- valore di scostamento (nel for in alto). Vedasi anche Panel:update(), che
  -- appunto ne cambia eventuale scostamento (hud_change) senza andarlo a salvare in tabella
  if HUD_elem.offset and (panel.background_def.offset.x ~= 0 or panel.background_def.offset.y ~= 0) then
    local player = minetest.get_player_by_name(panel.player_name)
    local offset = {x = (panel.background_def.offset.x or 0) + (HUD_elem.offset.x or 0), y = (panel.background_def.offset.y or 0) + (HUD_elem.offset.y or 0)}
    player:hud_change(panel.hud_id[name], "offset", offset)
  end
end



function update_sub_elems(panel, elems)

  local player = minetest.get_player_by_name(panel.player_name)

  for elem, _ in pairs(elems) do
    for k, v in pairs(elems[elem]) do
      if k == "offset" and (panel.background_def.offset.x ~= 0 or panel.background_def.offset.y ~= 0) then
        panel[elem][k] = { x = panel.background_def.offset.x + (v.x or 0), y = panel.background_def.offset.y + (v.y or 0)}
      else
        panel[elem][k] = v
      end

      if k == "text" then
        panel.hud_text[elem] = v
        -- aggiorno il testo solo se visibile
        if panel:is_visible() then
          player:hud_change(panel.hud_id[elem], k, v)
        end
      else
        player:hud_change(panel.hud_id[elem], k, v)
      end
    end
  end
end





----------------------------------------------
------------------DEPRECATED------------------
----------------------------------------------

-- to remove in 3.0
function Panel:is_shown()
  minetest.log("warning", "[PANEL_LIB] `is_shown()` is deprecated. Use `is_visible()` instead")
  return self:is_visible()
end

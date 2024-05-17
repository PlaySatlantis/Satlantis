local S = minetest.get_translator("arena_lib")
local NS = function(s) return s end

local F = minetest.formspec_escape

local NAMES_DIST = 0.64

local function add_sign() end
local function remove_sign() end
local function update_sign() end
local function in_game_txt() end
local function get_infobox_formspec() end

local displaying_infobox = {}                   -- KEY: player name, VALUE: {(string) mod, (int) arena_id}; si svuota con `close_formspec`

--------------------------------------------------------------------------------
-- There is no reliable way to know when someone closes a formspec, thus I override
-- the basic `minetest.close_formspec` function, also calling it in `fields.quit` down below
local original_close = minetest.close_formspec
function minetest.close_formspec(p_name, formname)
  if formname == "arena_lib:infobox" or formname == "" then
    displaying_infobox[p_name] = nil
  end
  original_close(p_name, formname)
end

-- se un formspec si sovrappone a quello del cartello
local original_show = minetest.show_formspec
function minetest.show_formspec(p_name, formname, formspec)
  if formname ~= "arena_lib:infobox" and displaying_infobox[p_name] then
    displaying_infobox[p_name] = nil
  end
  original_show(p_name, formname, formspec)
end
--------------------------------------------------------------------------------



arena_lib.register_entrance_type("arena_lib", "sign", {
  name = S("Sign"),

  editor_settings = {
    name = S("Signs"),
    icon = "arenalib_editor_signs.png",
    description = S("One sign per arena"),
    items = function(p_name, mod, arena) return arena_lib.give_signs_tools(p_name) end,
    on_enter = function(p_name, mod, arena) arena_lib.editor_reset_sign_values(p_name) end
  },

  on_add = function(sender, mod, arena, pos) return add_sign(sender, mod, arena, pos) end,
  on_remove = function(mod, arena) remove_sign(mod, arena) end,
  on_load = function(mod, arena) update_sign(mod, arena) end,
  on_update = function(mod, arena) update_sign(mod, arena) end,

  debug_output = function(entrance) return minetest.pos_to_string(entrance) end
})



signs_lib.register_sign("arena_lib:sign", {
  description = S("Arena sign"),
  tiles = {
    { name = "arenalib_sign.png", backface_culling = true},
    "arenalib_sign_edge.png"
    },
  use_texture_alpha = "opaque",
  inventory_image = "arenalib_sign_icon.png",
  default_color = "8",
  entity_info = "standard",
  sounds = minetest.global_exists("default") and default.node_sound_wood_defaults() or nil,
  groups = {cracky = 3, oddly_breakable_by_hand = 3},
  allow_widefont = true,
  chars_per_line = 40,
  horiz_scaling = 0.95,
  vert_scaling = 1.38,
  number_of_lines = 5,

  -- forza carattere espanso
  on_construct = function(pos)
    minetest.get_meta(pos):set_int("widefont", 1)
    end,

  -- cartello indistruttibile se c'è un'arena assegnata
  on_dig = function(pos, node, digger)
    if minetest.get_meta(pos):get_int("arenaID") ~= 0 then return end

    minetest.node_dig(pos,node,digger)
  end,

  -- click dx apre la finestra d'informazioni
  on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
    if minetest.get_meta(pos):get_int("arenaID") == 0 then return end

    local mod = minetest.get_meta(pos):get_string("mod")
    local arenaID = minetest.get_meta(pos):get_int("arenaID")
    local mod_ref =  arena_lib.mods[mod]
    local p_name = clicker:get_player_name()


    if not mod_ref then
      arena_lib.print_error(p_name, S("This minigame doesn't exist anymore!") .. " (" .. mod .. ")")
      return end

    if not mod_ref.arenas[arenaID] then
      arena_lib.print_error(p_name, S("This arena doesn't exist anymore!") .. " (" .. mod .. ")")
      return end

    displaying_infobox[p_name] = {mod = mod, arena_id = arenaID}
    minetest.show_formspec(p_name, "arena_lib:infobox", get_infobox_formspec(mod, arenaID, clicker))
  end,


  on_punch = function(pos, node, puncher, pointed_thing)
    local arenaID = minetest.get_meta(pos):get_int("arenaID")
    if arenaID == 0 then return end

    local mod = minetest.get_meta(pos):get_string("mod")
    local p_name = puncher:get_player_name()

    if not arena_lib.mods[mod] then
      arena_lib.print_error(p_name, S("This minigame doesn't exist anymore!") .. " (" .. mod .. ")")
      return end

    local arena = arena_lib.mods[mod].arenas[arenaID]

    if not arena then
      arena_lib.print_error(p_name, S("This arena doesn't exist anymore!") .. " (" .. mod .. ")")
      return end

    -- se il cartello è stato spostato tipo con WorldEdit, lo aggiorno alla nuova posizione (e se c'è una partita in corso, la interrompo)
    if not vector.equals(arena.entrance, pos) then
      local arena_name = arena.name
      arena_lib.force_end(p_name, mod, arena)
      arena_lib.disable_arena("", mod, arena_name)
      remove_sign("", mod, arena)
      add_sign("", mod, arena, pos)
      arena_lib.enable_arena("", mod, arena_name)
      arena_lib.print_error(p_name, S("Uh-oh, it looks like this sign has been misplaced: well, fixed, hit it again!"))
      return end

    -- se si è già in coda nella stessa arena, esci, sennò prova ad aggiungere il giocatore
    if arena_lib.is_player_in_queue(p_name, mod) and arena_lib.get_arenaID_by_player(p_name) == arenaID then
      arena_lib.remove_player_from_queue(p_name)
    else
      if arena.in_game then
        arena_lib.join_arena(mod, p_name, arenaID)
      else
        arena_lib.join_queue(mod, arena, p_name)
      end
    end
  end
})





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function add_sign(sender, mod, arena, pos)
  if not pos or type(pos) ~= "table" then
    arena_lib.print_error(sender, S("Parameters don't seem right!"))
    return end

  -- se non ha trovato niente, esco
  if minetest.get_node(pos).name ~= "arena_lib:sign" then
    arena_lib.print_error(sender, S("That's not an arena_lib sign!"))
    return end

  local id = arena_lib.get_arena_by_name(mod, arena.name)

  -- salvo il nome della mod e l'ID come metadato nel cartello
  minetest.get_meta(pos):set_string("mod", mod)
  minetest.get_meta(pos):set_int("arenaID", id)

  return pos
end



function remove_sign(mod, arena)
  minetest.load_area(arena.entrance)

  local sign_meta = minetest.get_meta(arena.entrance)
  local id = arena_lib.get_arena_by_name(mod, arena.name)

  -- se il cartello non è stato spostato lo rimuovo, sennò evito di far sparire il blocco che c'è ora
  -- (può capitare se qualcuno sposta un'area con WorldEdit). Le altre condizioni assicurano poi che si stia
  -- cancellando il cartello giusto, nel caso qualcuno con WorldEdit ne abbia spostato un altro appartenente
  -- a un'arena diversa nella stessa posizione
  if minetest.get_node(arena.entrance).name == "arena_lib:sign" and sign_meta:get_string("mod") == mod and
                                                                    sign_meta:get_int("arenaID") == id then
    minetest.set_node(arena.entrance, {name = "air"})
  end
end



function update_sign(mod, arena)
  local mod_ref = arena_lib.mods[mod]
  local p_count = 0

  -- non uso il getter perché dovrei richiamare 2 funzioni (ID e count)
  for pl, stats in pairs(arena.players) do
    p_count = p_count +1
  end

  local curr_max_pl = p_count

  if arena.max_players ~= -1 then
    curr_max_pl = curr_max_pl .. "/".. arena.max_players * #arena.teams
  end

  signs_lib.update_sign(arena.entrance, {text = [[
    ]] .. "\n\n" .. [[
    ]] .. arena.name .. "\n" .. [[
    ]] .. curr_max_pl .. "\n" .. [[
    ]] .. in_game_txt(arena, mod_ref.endless) .. "\n" .. [[
    ]]})

  for pl_name, pl_data in pairs(displaying_infobox) do
    local id = arena_lib.get_arena_by_name(mod, arena.name)
    if pl_data.mod == mod and pl_data.arena_id == id then
      minetest.show_formspec(pl_name, "arena_lib:infobox", get_infobox_formspec(mod, id, minetest.get_player_by_name(pl_name)))
    end
  end
end



function in_game_txt(arena, endless)
  local txt

  -- it's not possible to translate them, as they're entities. Needed https://github.com/minetest/minetest/issues/1367
  if not arena.enabled        then txt = "#dWIP"
  elseif arena.in_loading     then txt = "#4Loading"
  elseif endless              then txt = "#2oo"
  elseif arena.in_queue       then txt = "#2Queueing"
  elseif arena.in_celebration then txt = "#4Terminating"
  elseif arena.in_game        then txt = "#4In progress"
  else                             txt = "#3Waiting" end

  return txt
end



function get_infobox_formspec(mod, arenaID, player)
  local mod_ref = arena_lib.mods[mod]
  local arena = mod_ref.arenas[arenaID]
  local p_name = player:get_player_name()

  local thumbnail = arena.thumbnail ~= "" and arena.thumbnail or "arenalib_infobox_thumbnail.png"
  local list_bg, inside_col, pl_list

  -- se c'è una partita o qualcunə in coda...
  if arena.in_game or arena.players_amount > 0 then
    list_bg = "arenalib_infobox_list.png"
    inside_col = "#5a5353"
    pl_list = ""

    local i = 1
    -- renderizzo lɜ giocatorɜ
    for pl_name, _ in pairs(arena.players) do
      local y = 0.46 + (NAMES_DIST * i)
      if i > 7 then
        local txt = arena.players_amount > 8 and "..." or pl_name
        pl_list = pl_list .. "hypertext[0.7," .. y .. ";3.9,1;name;<style size=17 font=mono color=#ffffff>" .. txt .. "</style>]"
        break
      else
        pl_list = pl_list .. "hypertext[0.7," .. y .. ";3.9,1;name;<style size=17 font=mono color=#ffffff>" .. pl_name .. "</style>]"
      end
      i = i+1
    end

    -- renderizzo eventualmente lɜ spettatorɜ
    if arena.players_amount < 9 then
      for sp_name, _ in pairs(arena.spectators) do
        local y = 0.46 + (NAMES_DIST * i)
        if i > 7 then
          local txt = arena.players_amount + arena.spectators_amount > 8 and "..." or sp_name
          pl_list = pl_list .. "hypertext[0.7," .. y .. ";3.9,1;name;<style size=17 font=mono color=#453f40>" .. txt .. "</style>]"
          break
        else
          pl_list = pl_list .. "hypertext[0.7," .. y .. ";3.9,1;name;<style size=17 font=mono color=#453f40>" .. sp_name .. "</style>]"
        end
        i = i+1
      end
    end

  -- sennò
  else
    list_bg = "arenalib_infobox_list_off.png"
    inside_col = "#d7ded7"
    pl_list = "hypertext[0.7,2.22;3.6,2;name;<global halign=center valign=middle><style size=17 font=mono color=#d7ded7>" .. S("No ongoing activity") .. "</style>]"
  end

  local bgm_info

  if arena.bgm then
    local title = arena.bgm.title or "???"
    local author = arena.bgm.author or "???"
    bgm_info = title .. " - " .. author
  else
    bgm_info = "---"
  end

  local play_btn, spec_btn, play_tip, spec_tip

  if not arena.enabled then
    play_btn = "arenalib_infobox_play_off.png"
    spec_btn = "arenalib_infobox_spectate_off.png"
    play_tip = NS("The arena is not enabled")
    spec_tip = NS("The arena is not enabled")
  else
    -- tasto "gioca"
    if arena_lib.is_player_in_queue(p_name, mod) and arena_lib.get_arenaID_by_player(p_name) == arenaID then
      play_btn = "arenalib_infobox_play_leave.png"
      play_tip = NS("Leave the queue (you can also left-click the sign)")
    elseif arena.players_amount == arena.max_players * #arena.teams and (arena.in_queue or (arena.in_game and (mod_ref.join_while_in_progress or mod_ref.endless))) then
      play_btn = "arenalib_infobox_play_full.png"
      play_tip = NS("Full")
    elseif arena.in_game then
      if mod_ref.join_while_in_progress or mod_ref.endless then
        play_btn = "arenalib_infobox_play_go.png"
        play_tip = NS("Play (you can also left-click the sign)")
      else
        play_btn = "arenalib_infobox_play_wait.png"
        play_tip = NS("This minigame can't be joined whilst a game is in progress")
      end
    else
      play_btn = "arenalib_infobox_play_go.png"
      play_tip = NS("Play (you can also left-click the sign)")
    end
    -- tasto "assisti"
    if not mod_ref.spectate_mode then
      spec_btn = "arenalib_infobox_spectate_off.png"
      spec_tip = NS("Spectate mode not supported")
    elseif arena.in_game then
      spec_btn = "arenalib_infobox_spectate_go.png"
      spec_tip = NS("Spectate")
    else
      spec_btn = "arenalib_infobox_spectate_wait.png"
      spec_tip = NS("Spectate (there must be a game in progress)")
    end
  end

  local admin_options = ""

  if minetest.check_player_privs(p_name, "arenalib_admin") then
    local admin_elems = {
      "tooltip[edit;" .. S("Edit") .. "]",
      "tooltip[forcestart;" .. S("Force start") .. "]",
      "image_button[-0.1,1;0.8,0.8;arenalib_infobox_edit.png;edit;]",
      "image_button[-0.05,1.88;0.8,0.8;arenalib_infobox_forcestart.png;forcestart;]"
    }

    admin_options = table.concat(admin_elems, "")
  end

  local formspec = {
    "formspec_version[4]",
    "size[20,7]",
    "no_prepend[]",
    "bgcolor[;true]",
    "style_type[image_button;border=false;bgimg=blank.png]",
    "image[0.82,0.75;8,5.49;" .. thumbnail .. "]",
    "image[0,0;20,7;arenalib_infobox_bg.png;]",
    "image[0,0;20,7;" .. list_bg .. ";]",
    -- corpo sx
    "container[9.2,0.7]",
    -- immagini
    "image[-0.3,0;1,1;arenalib_infobox_name.png]",
    "image[0,1.7;0.9,0.65;arenalib_infobox_author.png]",
    "image[0,2.8;0.9,0.9;arenalib_infobox_bgm.png]",
    -- scritte
    "hypertext[0.76,0.08;3.63,1;name;<global valign=middle><style size=23 font=mono color=#ffffff>" .. F(arena.name) .. "</style>]",
    "hypertext[1,1.59;3.45,1;author;<global valign=middle><style size=19 font=mono color=#5a5353>" .. F(arena.author) .. "</style>]",
    "hypertext[1,2.67;3.45,1;bgm;<global valign=middle><style size=19 font=mono color=#5a5353>" .. F(bgm_info) .. "</style>]",
    -- suggerimenti e pulsanti
    "tooltip[play;" .. S(play_tip) .. "]",
    "tooltip[spectate;" .. S(spec_tip) .. "]",
    "image_button[0,4.52;2.1,1.1;" .. play_btn .. ";play;]",
    "image_button[2.1,4.52;2.1,1.1;" .. spec_btn .. ";spectate;]",
    "container_end[]",
    -- corpo dx
    "container[14.1,0.3]",
    "image[0,0;0.92,0.92;arenalib_editor_players.png;]",
    "hypertext[1,-0.03;3.7,1;name;<global valign=middle><style size=20 font=mono color=" .. inside_col .. ">" .. S("Now inside") .. "</style>]",
    pl_list,
    "container_end[]",
    -- pulsanti esterni
    "container[19.3,0.1]",
    "tooltip[quit;" .. S("Close") .. "]",
    "image_button[0,0.19;0.6,0.6;arenalib_infobox_quit.png;quit;]",
    admin_options,
    "container_end[]"
  }

  return table.concat(formspec, "")
end





----------------------------------------------
---------------GESTIONE CAMPI-----------------
----------------------------------------------

minetest.register_on_player_receive_fields(function(player, formname, fields)
  if formname ~= "arena_lib:infobox" then return end

  local p_name = player:get_player_name()

  -- TEMP: il secondo controllo è stato messo a causa di crash sporadici che non
  -- riusciamo a capire. Considerando che questa è una pezza in attesa di
  -- https://github.com/minetest/minetest/issues/13142  e che potrebbe essere dovuto
  -- a un problema di Minetest, tanto vale non dannarsi e aspettare che venga
  -- implementato come si deve lato motore di gioco
  if not displaying_infobox[p_name] then return end

  local mod = displaying_infobox[p_name].mod
  local arenaID = displaying_infobox[p_name].arena_id
  local arena = arena_lib.mods[mod].arenas[arenaID]

  if fields.quit then
    minetest.close_formspec(p_name, formname) -- necessario per chiamare la funzione sovrascritta qui sopra, rimuovendo p_name da displaying_infobox
    return

  elseif fields.edit then
    if not minetest.get_player_privs(p_name).arenalib_admin then return end -- sanity check
    arena_lib.enter_editor(p_name, mod, arena.name)
    minetest.close_formspec(p_name, formname)
    return

  elseif fields.forcestart then
    if not minetest.get_player_privs(p_name).arenalib_admin then return end -- sanity check
    arena_lib.force_start(p_name, mod, arena)
    return

  elseif fields.play then
    if arena.in_game then
      arena_lib.join_arena(mod, p_name, arenaID)
    else
      if arena_lib.is_player_in_queue(p_name, mod) and arena_lib.get_arenaID_by_player(p_name) == arenaID then
        arena_lib.remove_player_from_queue(p_name)
      else
        arena_lib.join_queue(mod, arena, p_name)
      end
    end

  elseif fields.spectate then
    arena_lib.join_arena(mod, p_name, arenaID, true)
  end
end)



-- TEMP: da rimuovere con https://github.com/minetest/minetest/issues/13142
minetest.register_on_leaveplayer(function(player)
  if displaying_infobox[player:get_player_name()] then
    displaying_infobox[player:get_player_name()] = nil
  end
end)

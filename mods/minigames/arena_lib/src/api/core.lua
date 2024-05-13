-- in here: whatever needs to access the storage (minigames and arenas management)
local S = minetest.get_translator("arena_lib")
local NS = function(s) return s end
local storage = minetest.get_mod_storage()

local function load_settings() end
local function init_storage() end
local function update_storage() end
local function file_exists() end
local function deprecated_chat_settings() end
local function deprecated_spawner_ID_param() end
local function deprecated_sound_table_entry_exists() end
local function check_for_properties() end
local function next_available_ID() end
local function delete_schematic_if_exists() end
local function is_arena_name_allowed() end
local function initialise_map_storage() end

local arena_default = {
  name = "",
  author = "???",
  thumbnail = "",
  entrance_type = arena_lib.DEFAULT_ENTRANCE,
  players = {},                       -- KEY: player name, VALUE: {deaths, teamID, <player_properties>}
  spectators = {},                    -- KEY: player name, VALUE: true
  players_and_spectators = {},        -- KEY: pl/sp name,  VALUE: true
  past_present_players = {},          -- KEY: player_name, VALUE: true
  past_present_players_inside = {},   -- KEY: player_name, VALUE: true
  teams = {-1},
  teams_enabled = false,
  players_amount = 0,
  spectators_amount = 0,
  spawn_points = {},
  max_players = 4,
  min_players = 2,
  in_queue = false,
  in_loading = false,
  in_game = false,
  in_celebration = false,
  enabled = false
}

-- these fields are `nil` by default; this list is only used in check_for_properties
-- local function, to be sure no minigame uses any of these fields as a custom
-- arena property
local arena_optional_fields = {
  entrance = true,
  custom_return_point = true,
  players_amount_per_team = true,
  spectators_amount_per_team = true,
  spectate_entities_amount = true,
  spectate_areas_amount = true,
  pos1 = true,
  pos2 = true,
  celestial_vault = true,               -- sky = {...}, sun = {...}, moon = {...}, stars = {...}, clouds = {...}
  weather = true,
  lighting = true,                      -- light = override_day_night_ratio
  bgm = true,
  matchID = true,
  initial_time = true,
  current_time = true,
  is_resetting = true,
}





----------------------------------------------
---------------REGISTRAZIONI------------------
----------------------------------------------

function arena_lib.register_minigame(mod, def)
  local highest_arena_ID = storage:get_int(mod .. ".HIGHEST_ARENA_ID")

  --v------------------ LEGACY UPDATE, to remove in 8.0 -------------------v
  if def.show_minimap then
    minetest.log("warning", "[ARENA_LIB] (" .. mod .. ") show_minimap is deprecated. Use disabled_huds = {\"minimap\"} instead")
    if def.disabled_huds then
      local skip
      for _, prop in pairs(def.disabled_huds) do
        if prop == "minimap" then
          skip = true
          break
        end
      end

      if not skip then
        def.disabled_huds = {"minimap"}
      end
    else
      def.disabled_huds = {"minimap"}
    end
  end
  --^------------------ LEGACY UPDATE, to remove in 8.0 -------------------^

  --v------------------ LEGACY UPDATE, to remove in 9.0 -------------------v
  if def.disabled_huds then
    minetest.log("warning", "[ARENA_LIB] (" .. mod .. ") disabled_huds is deprecated. Use hud_flags = {hud_name = true/false} instead")

    if not def.hud_flags then
      def.hud_flags = {}
    end

    local hud_table = table.key_value_swap(def.disabled_huds)
    for k, _ in pairs(hud_table) do
      def.hud_flags[k] = false
    end
  end

  def.chat_settings = def.chat_settings or {}

  if def.chat_all_prefix then
    def.chat_settings.prefix_all = def.chat_all_prefix
    minetest.log("warning", "[ARENA_LIB] (" .. mod .. ") chat_all_prefix is deprecated. Use chat_settings = {prefix_all = \"some prefix\"} instead")
  end

  if def.chat_team_prefix then
    def.chat_settings.prefix_team = def.chat_team_prefix
    minetest.log("warning", "[ARENA_LIB] (" .. mod .. ") chat_team_prefix is deprecated. Use chat_settings = {prefix_team = \"some prefix\"} instead")
  end

  if def.chat_spectate_prefix then
    def.chat_settings.prefix_spectate = def.chat_spectate_prefix
    minetest.log("warning", "[ARENA_LIB] (" .. mod .. ") chat_spectate_prefix is deprecated. Use chat_settings = {prefix_spectate = \"some prefix\"} instead")
  end

  if def.chat_all_color then
    def.chat_settings.color_all = def.chat_all_color
    minetest.log("warning", "[ARENA_LIB] (" .. mod .. ") chat_all_color is deprecated. Use chat_settings = {color_all = \"some color\"} instead")
  end

  if def.chat_team_color then
    def.chat_settings.color_team = def.chat_team_color
    minetest.log("warning", "[ARENA_LIB] (" .. mod .. ") chat_team_color is deprecated. Use chat_settings = {color_team = \"some color\"} instead")
  end

  if def.chat_spectate_color then
    def.chat_settings.color_spectate = def.chat_spectate_color
    minetest.log("warning", "[ARENA_LIB] (" .. mod .. ") chat_spectate_color is deprecated. Use chat_settings = {color_spectate = \"some color\"} instead")
  end
  --^------------------ LEGACY UPDATE, to remove in 9.0 -------------------^

  arena_lib.mods[mod] = {}
  arena_lib.mods[mod].arenas = {}                                               -- KEY: (int) arenaID , VALUE: (table) arena properties
  arena_lib.mods[mod].highest_arena_ID = highest_arena_ID

  local mod_ref = arena_lib.mods[mod]

  -- /arenas settings
  load_settings(mod)

  --default parameters
  mod_ref.name = def.name or mod
  mod_ref.prefix = "[" .. mod_ref.name .. "] "
  mod_ref.icon = def.icon or "arenalib_icon_unknown.png"
  mod_ref.min_version = -1
  mod_ref.teams = {-1}
  mod_ref.can_disable_teams = false
  mod_ref.variable_teams_amount = false
  mod_ref.teams_color_overlay = nil
  mod_ref.friendly_fire = false
  mod_ref.chat_settings = {
    prefix_all = "[" .. S("arena") .. "] ",
    prefix_team = "[" .. S("team") .. "] ",
    prefix_spectate = "[" .. S("spectator") .. "] ",
    color_all = "#ffffff",
    color_team = "#ddfdff",
    color_spectate = "#dddddd",
    is_team_chat_default = false
  }
  mod_ref.messages = {
    eliminated = NS("@1 has been eliminated"),
    eliminated_by = NS("@1 has been eliminated by @2"),                             -- I won't include `kicked` and `kicked_by` as it's more of a maintenance function
    last_standing = NS("You're the last player standing: you win!"),
    last_standing_team = NS("There are no other teams left, you win!"),
    quit = NS("@1 has quit the match"),
    celebration_one_player = NS("@1 wins the game"),
    celebration_one_team = NS("Team @1 wins the game"),
    celebration_more_players = NS("@1 win the game"),
    celebration_more_teams = NS("Teams @1 win the game"),
    celebration_nobody = NS("There are no winners"),
  }
  mod_ref.custom_messages = {}     -- used internally to check whether a custom message has been registered (so to call the minigame translator rather than arena_lib's); KEY = msg name, VALUE = true
  mod_ref.sounds = {
    join = "arenalib_match_join",
    quit = "arenalib_match_leave",
    kick = "arenalib_match_leave",
    eliminate = "arenalib_match_leave",
    disconnect = "arenalib_match_leave",
  }
  mod_ref.player_aspect = nil
  mod_ref.fov = nil
  mod_ref.camera_offset = nil
  mod_ref.hotbar = nil
  mod_ref.min_players = 1
  mod_ref.endless = false
  mod_ref.end_when_too_few = true
  mod_ref.eliminate_on_death = false
  mod_ref.join_while_in_progress = false
  mod_ref.spectate_mode = true
  mod_ref.regenerate_map = false
  mod_ref.can_build = false
  mod_ref.can_drop = true
  mod_ref.disable_inventory = false
  mod_ref.keep_inventory = false
  mod_ref.keep_attachments = false
  mod_ref.show_nametags = false
  mod_ref.time_mode = "none"
  mod_ref.load_time = 5           -- time in the loading phase (the pre-match)
  mod_ref.celebration_time = 5    -- time in the celebration phase
  mod_ref.in_game_physics = nil
  mod_ref.damage_modifiers = {}
  mod_ref.disabled_damage_types = {}
  mod_ref.hud_flags = {}
  mod_ref.properties = {}
  mod_ref.temp_properties = {}
  mod_ref.player_properties = {}
  mod_ref.spectator_properties = {}
  mod_ref.team_properties = {}

  if def.prefix then
    mod_ref.prefix = def.prefix
  end

  if def.min_version then
    mod_ref.min_version = def.min_version
  end

  if def.teams and type(def.teams) == "table" then
    mod_ref.teams = def.teams

    if def.variable_teams_amount == true then
      mod_ref.variable_teams_amount = true
    end

    if def.can_disable_teams then
      mod_ref.can_disable_teams = true
    end

    if def.teams_color_overlay then
      mod_ref.teams_color_overlay = def.teams_color_overlay
    end

    if def.friendly_fire == true then
      mod_ref.friendly_fire = true
    end
  end

  if def.chat_settings and type(def.chat_settings) == "table" then
    local settings = mod_ref.chat_settings
    local new_settings = def.chat_settings

    if new_settings.prefix_all then
      settings.prefix_all = new_settings.prefix_all
    end

    if new_settings.prefix_team then
      settings.prefix_team = new_settings.prefix_team
    end

    if new_settings.prefix_spectate then
      settings.prefix_spectate = new_settings.prefix_spectate
    end

    if new_settings.color_all then
      settings.color_all = new_settings.color_all
    end

    if new_settings.color_team then
      settings.color_team = new_settings.color_team
    end

    if new_settings.color_spectate then
      settings.color_spectate = new_settings.color_spectate
    end

    if new_settings.is_team_chat_default == true then
      settings.is_team_chat_default = true
    end
  end

  deprecated_chat_settings(mod_ref)

  if def.custom_messages then
    for k, msg in pairs(def.custom_messages) do
      mod_ref.messages[k] = msg
      mod_ref.custom_messages[k] = true
    end
  end

  if def.sounds then
    local mod_sounds = mod_ref.sounds
    if def.sounds.leave ~= nil then
      local leave_sound = def.sounds.leave
      local leave_name

      deprecated_sound_table_entry_exists(leave_sound)

      if type(leave_sound) == "table" then
        leave_name = leave_sound.name
        audio_lib.register_sound("notifications", leave_name, leave_sound.description, leave_sound.params)
      else  -- o `false`
        leave_name = leave_sound
      end

      mod_sounds.quit = leave_name
      mod_sounds.kick = leave_name
      mod_sounds.eliminate = leave_name
      mod_sounds.disconnect = leave_name
      def.sounds.leave = nil
    end

    for k, audio in pairs(def.sounds) do
      deprecated_sound_table_entry_exists(audio)

      if type(audio) == "table" then
        local audio_name = audio.name
        audio_lib.register_sound("notifications", audio.name, audio.description, audio.params)
        mod_ref.sounds[k] = audio.name
      else  -- o `false`
        mod_ref.sounds[k] = audio
      end
    end
  end

  if def.player_aspect then
    local aspect = def.player_aspect
    mod_ref.player_aspect = { visual = aspect.visual, mesh = aspect.mesh, textures = aspect.textures, visual_size = aspect.visual_size, collisionbox = aspect.collisionbox, selectionbox = aspect.selectionbox }
  end

  if def.fov then
    mod_ref.fov = def.fov
  end

  if def.camera_offset and type(def.camera_offset) == "table" then
    mod_ref.camera_offset = def.camera_offset
  end

  if def.hotbar and type(def.hotbar) == "table" then
    mod_ref.hotbar = {}
    mod_ref.hotbar.slots = def.hotbar.slots
    mod_ref.hotbar.background_image = def.hotbar.background_image
    mod_ref.hotbar.selected_image = def.hotbar.selected_image
  end

  if def.min_players then
    mod_ref.min_players = def.min_players
  end

  if def.endless == true then
    mod_ref.endless = true
    mod_ref.join_while_in_progress = true
    mod_ref.min_players = 0
  end

  if def.end_when_too_few == false then
    mod_ref.end_when_too_few = false
  end

  if def.eliminate_on_death == true then
    mod_ref.eliminate_on_death = true
  end

  if def.join_while_in_progress == true then
    mod_ref.join_while_in_progress = true
  end

  if def.spectate_mode == false then
    mod_ref.spectate_mode = false
  end

  if def.regenerate_map == true then
    mod_ref.regenerate_map = true
  end

  if def.can_build == true then
    mod_ref.can_build = true
  end

  if def.can_drop == false then
    mod_ref.can_drop = false
  end

  if def.disable_inventory == true then
    mod_ref.disable_inventory = true
  end

  if def.keep_inventory == true then
    mod_ref.keep_inventory = true
  end

  if def.keep_attachments == true then
    mod_ref.keep_attachments = true
  end

  if def.show_nametags == true then
    mod_ref.show_nametags = true
  end

  if def.time_mode then
    assert(not def.endless or def.time_mode ~= "decremental", "[ARENA_LIB] (" .. mod_ref.name .. ") endless minigames can't have a timer! (time_mode = \"decremental\")")
    minetest.after(0.1, function()  -- deve caricare la registrazione del richiamo
      assert(def.time_mode ~= "decremental" or mod_ref.on_timeout ~= nil, "[ARENA_LIB] (" .. mod_ref.name ..") on_timeout callback is mandatory when time_mode = \"decremental\"!")
    end)
    mod_ref.time_mode = def.time_mode
  end

  if def.load_time then
    mod_ref.load_time = def.load_time
  end

  if def.celebration_time then
    assert(def.celebration_time > 0 or def.endless, "[ARENA_LIB] (" .. mod_ref.name .. ") celebration_time must be greater than 0 (everyone deserves to celebrate!)")
    mod_ref.celebration_time = def.celebration_time
  end

  if def.in_game_physics and type(def.in_game_physics) == "table" then
    mod_ref.in_game_physics = def.in_game_physics
  end

  if def.damage_modifiers and type(def.damage_modifiers) == "table" then
    mod_ref.damage_modifiers = def.damage_modifiers
  end

  if def.disabled_damage_types and type(def.disabled_damage_types) == "table" then
    mod_ref.disabled_damage_types = def.disabled_damage_types
  end

  if def.hud_flags and type(def.hud_flags) == "table" then
    mod_ref.hud_flags = def.hud_flags
  end

  if def.properties then
    mod_ref.properties = def.properties
  end

  if def.temp_properties then
    mod_ref.temp_properties = def.temp_properties
  end

  if def.player_properties then
    mod_ref.player_properties = def.player_properties
  end

  if def.spectator_properties then
    mod_ref.spectator_properties = def.spectator_properties
  end

  if def.team_properties then
    mod_ref.team_properties = def.team_properties
  end

  init_storage(mod, mod_ref)
end



function arena_lib.register_entrance_type(mod, entrance, def)
  local editor = def.editor_settings

  arena_lib.entrances[entrance] = {
    mod           = mod,
    name          = def.name,
    load          = def.on_load   or function() end,
    add           = def.on_add    or function() end,
    update        = def.on_update or function() end,
    remove        = def.on_remove or function() end,
    enter_editor  = editor.on_enter or function() end,
    print         = def.debug_output
  }

  minetest.register_tool( mod ..":editor_entrance", {

    description = editor.name,
    inventory_image = editor.icon,
    groups = {not_in_creative_inventory = 1},
    on_place = function() end,
    on_drop = function() end,

    on_use = function(itemstack, user)
      local p_name = user:get_player_name()
      local mod = user:get_meta():get_string("arena_lib_editor.mod")
      local arena_name = user:get_meta():get_string("arena_lib_editor.arena")
      local _, arena = arena_lib.get_arena_by_name(mod, arena_name)
      local items = editor.items and editor.items(p_name, mod, arena) or editor.tools

      table.insert(items, 9, "arena_lib:editor_return")
      table.insert(items, 10, "arena_lib:editor_quit")

      user:get_inventory():set_list("main", items)
    end
  })
end



function arena_lib.change_mod_settings(sender, mod, setting, new_value)
  local mod_settings = arena_lib.mods[mod].settings

  -- se la proprietà non esiste
  if mod_settings[setting] == nil then
    arena_lib.print_error(sender, S("Parameters don't seem right!"))
    return end

  ----- v inizio conversione stringa nel tipo corrispettivo v -----
  local func, error_msg = loadstring("return (" .. new_value .. ")")

  -- se non ritorna una sintassi corretta
  if not func then
    arena_lib.print_error(sender, "[SYNTAX!] " .. error_msg)
    return end

  setfenv(func, {})

  local good, result = pcall(func)

  -- se le operazioni della funzione causano errori
  if not good then
    arena_lib.print_error(sender, "[RUNTIME!] " .. result)
    return end

  new_value = result
  ----- ^ fine conversione stringa nel tipo corrispettivo ^ -----

  -- se il tipo è diverso dal precedente
  if type(mod_settings[setting]) ~= type(new_value) then
    arena_lib.print_error(sender, S("Property type doesn't match, aborting!"))
    return end

  mod_settings[setting] = new_value
  storage:set_string(mod .. ".SETTINGS", minetest.serialize(mod_settings))

  -- in caso sia stato cambiato il punto di ritorno
  if setting == "return_point" then
    for _, arena in pairs(arena_lib.mods[mod].arenas) do
      if arena_lib.is_arena_in_edit_mode(arena.name) and not arena.custom_return_point then
        arena_lib.update_waypoints(arena_lib.get_player_in_edit_mode(arena.name), mod, arena)
      end
    end
  end

  arena_lib.print_info(sender, S("Parameter @1 successfully overwritten", setting))
end





----------------------------------------------
---------------GESTIONE ARENA-----------------
----------------------------------------------

function arena_lib.create_arena(sender, mod, arena_name, min_players, max_players)
  local mod_ref = arena_lib.mods[mod]

  if not mod_ref then
    arena_lib.print_error(sender, S("This minigame doesn't exist!"))
    return end

  -- controllo nome
  if not is_arena_name_allowed(sender, mod, arena_name) then return end

  -- controllo che non abbiano messo parametri assurdi per lɜ giocatorɜ minimɜ/massimɜ
  if min_players and max_players then
    if min_players > max_players or min_players == 0 or max_players < 2 then
      arena_lib.print_error(sender, S("Parameters don't seem right!"))
      return end

    if min_players < mod_ref.min_players then
      arena_lib.print_error(sender, S("This minigame needs at least @1 players!"))
      return end

    if mod_ref.endless and min_players ~= 0 then
      arena_lib.print_error(sender, S("In endless minigames, the minimum amount of players must always be 0!"))
      return end
  end

  local ID = next_available_ID(mod_ref)

  -- creo l'arena
  mod_ref.arenas[ID] = table.copy(arena_default)

  local arena = mod_ref.arenas[ID]

  arena.name = arena_name
  arena.min_players = math.max(arena.min_players, mod_ref.min_players)
  arena.max_players = math.max(arena.max_players, mod_ref.min_players)

  -- numero giocatorɜ
  if mod_ref.endless then
    arena.min_players = 0
  end

  if min_players and max_players then
    arena.min_players = min_players
    arena.max_players = max_players
  end

  -- eventuali squadre
  if #mod_ref.teams > 1 then
    arena.teams = {}
    arena.teams_enabled = true
    arena.players_amount_per_team = {}

    for i, t_name in pairs(mod_ref.teams) do
      arena.spawn_points[i] = {}
      arena.teams[i] = {name = t_name}
      arena.players_amount_per_team[i] = 0
    end

    if mod_ref.spectate_mode then
      arena.spectators_amount_per_team = {}
      for i = 1, #mod_ref.teams do
        arena.spectators_amount_per_team[i] = 0
      end
    end
  end

  -- eventuale tempo
  if mod_ref.time_mode == "incremental" then
    arena.initial_time = 0
  elseif mod_ref.time_mode == "decremental" then
    arena.initial_time = 300
  end

  -- aggiungo eventuali proprietà
  for property, value in pairs(mod_ref.properties) do
    arena[property] = value
  end

  mod_ref.highest_arena_ID = table.maxn(mod_ref.arenas)

  -- aggiungo allo spazio d'archiviazione
  update_storage(false, mod, ID, arena)
  -- aggiorno l'ID globale nello spazio d'archiviazione
  storage:set_int(mod .. ".HIGHEST_ARENA_ID", mod_ref.highest_arena_ID)

  arena_lib.print_info(sender, mod_ref.prefix .. S("Arena @1 successfully created", arena_name))
end



function arena_lib.remove_arena(sender, mod, arena_name, in_editor)
  local id, arena = arena_lib.get_arena_by_name(mod, arena_name)

  if not in_editor then
    if not ARENA_LIB_EDIT_PRECHECKS_PASSED(sender, arena) then return end
  end

  -- rimozione eventuale entrata
  if arena.entrance then
    arena_lib.entrances[arena.entrance_type].remove(mod, arena)
  end

  delete_schematic_if_exists(sender, mod, id)

  local mod_ref = arena_lib.mods[mod]

  -- rimozione arena e aggiornamento highest_arena_ID
  mod_ref.arenas[id] = nil
  mod_ref.highest_arena_ID = table.maxn(mod_ref.arenas)

  -- rimozione nello storage
  update_storage(true, mod, id)

  arena_lib.print_info(sender, mod_ref.prefix .. S("Arena @1 successfully removed", arena_name))
end



function arena_lib.rename_arena(sender, mod, arena_name, new_name, in_editor)
  local id, arena = arena_lib.get_arena_by_name(mod, arena_name)

  if not in_editor then
    if not ARENA_LIB_EDIT_PRECHECKS_PASSED(sender, arena) then return end
  end

  -- controllo nome
  if not is_arena_name_allowed(sender, mod, new_name) then return end

  local old_name = arena.name

  arena.name = new_name

  -- aggiorno l'entrata, se esiste
  if arena.entrance then
    arena_lib.entrances[arena.entrance_type].update(mod, arena)
  end

  update_storage(false, mod, id, arena)

  arena_lib.print_info(sender, arena_lib.mods[mod].prefix .. S("Arena @1 successfully renamed in @2", old_name, new_name))
  return true
end



function arena_lib.set_author(sender, mod, arena_name, author, in_editor)
  local id, arena = arena_lib.get_arena_by_name(mod, arena_name)

  if not in_editor then
    if not ARENA_LIB_EDIT_PRECHECKS_PASSED(sender, arena) then return end
  end

  if type(author) ~= "string" then
    arena_lib.print_error(sender, S("Parameters don't seem right!"))
    return
  elseif author == nil or not string.match(author, "[%w%p]+") then
    arena.author = "???"
    arena_lib.print_info(sender, arena_lib.mods[mod].prefix .. S("@1's author successfully removed", arena.name))
  else
    arena.author = author
    arena_lib.print_info(sender, arena_lib.mods[mod].prefix .. S("@1's author successfully changed to @2", arena.name, arena.author))
  end

  update_storage(false, mod, id, arena)
end



function arena_lib.set_thumbnail(sender, mod, arena_name, thumbnail, in_editor)
  local id, arena = arena_lib.get_arena_by_name(mod, arena_name)

  if not in_editor then
    if not ARENA_LIB_EDIT_PRECHECKS_PASSED(sender, arena) then return end
  end

  if type(thumbnail) ~= "string" then
    arena_lib.print_error(sender, S("Parameters don't seem right!"))
    return
  elseif thumbnail == nil or thumbnail == "" then
    arena.thumbnail = ""
    arena_lib.print_info(sender, arena_lib.mods[mod].prefix .. S("@1's thumbnail successfully removed", arena.name))
  else
    local thmb_dir = minetest.get_worldpath() .. "/arena_lib/Thumbnails/"
    if not file_exists(thmb_dir, thumbnail) then
      arena_lib.print_error(sender, S("File not found!"))
      return end

    arena.thumbnail = thumbnail
    arena_lib.print_info(sender, arena_lib.mods[mod].prefix .. S("@1's thumbnail successfully changed to @2", arena.name, arena.thumbnail))
  end

  update_storage(false, mod, id, arena)
end



function arena_lib.change_arena_property(sender, mod, arena_name, property, new_value, in_editor_ui)
  local id, arena = arena_lib.get_arena_by_name(mod, arena_name)

  -- non passo in_editor perché, al contrario delle altre funzioni, questa è esposta
  -- all'API e potrebbe essere lanciata da una sezione personalizzata dell'editor
  if not arena_lib.is_player_in_edit_mode(sender) or arena_lib.get_player_in_edit_mode(arena_name) ~= sender then
    if not ARENA_LIB_EDIT_PRECHECKS_PASSED(sender, arena) then return end
  end

  -- se la proprietà non esiste
  if arena[property] == nil then
    arena_lib.print_error(sender, S("Parameters don't seem right!"))
    return end

  -- se si sta usando l'UI base dell'editor, converto la stringa nel tipo corrispettivo
  if in_editor_ui then
    local func, error_msg = loadstring("return (" .. new_value .. ")")

    -- se non ritorna una sintassi corretta
    if not func then
      arena_lib.print_error(sender, "[SYNTAX!] " .. error_msg)
      return end

    setfenv(func, {})
    local good, result = pcall(func)

    -- se le operazioni della funzione causano errori
    if not good then
      arena_lib.print_error(sender, "[RUNTIME!] " .. result)
      return end

    new_value = result
  end

  -- se il tipo è diverso dal precedente
  if type(arena[property]) ~= type(new_value) then
    arena_lib.print_error(sender, S("Property type doesn't match, aborting!"))
    return end

  arena[property] = new_value
  update_storage(false, mod, id, arena)

  arena_lib.print_info(sender, S("Parameter @1 successfully overwritten", property))
end



function arena_lib.change_players_amount(sender, mod, arena_name, min_players, max_players, in_editor)
  local id, arena = arena_lib.get_arena_by_name(mod, arena_name)

  if not in_editor then
    if not ARENA_LIB_EDIT_PRECHECKS_PASSED(sender, arena) then return end
  end

  local mod_ref = arena_lib.mods[mod]

  -- se il minigioco è infinito e si prova a modificare lɜ giocanti minimɜ
  if mod_ref.endless and min_players and min_players ~= 0 then
    arena_lib.print_error(sender, S("In endless minigames, the minimum amount of players must always be 0!"))
    return end

  -- salvo i vecchi parametri così da poterne modificare anche solo uno senza if lunghissimi
  local old_min_players = arena.min_players
  local old_max_players = arena.max_players

  arena.min_players = min_players or arena.min_players
  arena.max_players = max_players or arena.max_players

  -- se ha parametri assurdi, annullo
  if (arena.max_players ~= -1 and arena.min_players > arena.max_players) or (not mod_ref.endless and arena.min_players <= 0) then
    arena_lib.print_error(sender, S("Parameters don't seem right!"))
    arena.min_players = old_min_players
    arena.max_players = old_max_players
    return end

  -- se ha meno giocanti di quellɜ richiestɜ dal minigioco, annullo
  if arena.min_players < mod_ref.min_players then
    arena_lib.print_error(sender, S("This minigame needs at least @1 players!", mod_ref.min_players))
    arena.min_players = old_min_players
    arena.max_players = old_max_players
    return end

  -- aggiorno l'entrata, se esiste
  if arena.entrance then
    arena_lib.entrances[arena.entrance_type].update(mod, arena)
  end

  update_storage(false, mod, id, arena)
  arena_lib.print_info(sender, arena_lib.mods[mod].prefix .. S("Players amount successfully changed ( min @1 | max @2 )", arena.min_players, arena.max_players))

  -- ritorno true per procedere al cambio di quantità nell'editor
  return true
end



function arena_lib.change_teams_amount(sender, mod, arena_name, amount, in_editor)
  local id, arena = arena_lib.get_arena_by_name(mod, arena_name)

  if not in_editor then
    if not ARENA_LIB_EDIT_PRECHECKS_PASSED(sender, arena) then return end
  end

  -- se le squadre non sono abilitate, annullo
  if not arena.teams_enabled then
    arena_lib.print_error(sender, S("Teams are not enabled!"))
    return end

  local mod_ref = arena_lib.mods[mod]

  -- se il numero è minore di 2, o maggiore delle squadre dichiarate nella mod, annullo
  if amount < 2 or amount > #mod_ref.teams then
    arena_lib.print_error(sender, S("Parameters don't seem right!"))
    return end

  local curr_amount = #arena.teams

  -- se il numero inserito è lo stesso delle squadre attuali, annullo
  if curr_amount == amount then
    arena_lib.print_error(sender, S("Nothing to do here!"))
    return end

  -- se ora ci son meno squadre, cancello i punti di rinascita di quelle in eccesso
  if curr_amount > amount then
    local extra_teams = #arena.teams - amount

    for i = 1, extra_teams do
      arena_lib.set_spawner(sender, mod, arena_name, amount + i, "deleteall", nil, in_editor)
      arena.players_amount_per_team[amount + i] = nil
    end
  end

  arena.teams = {}
  for i = 1, amount do
    arena.teams[i] = {name = mod_ref.teams[i]}
    arena.players_amount_per_team[i] = 0
  end

  -- aggiorno l'entrata, se esiste
  if arena.entrance then
    arena_lib.entrances[arena.entrance_type].update(mod, arena)
  end

  update_storage(false, mod, id, arena)
  arena_lib.print_info(sender, arena_lib.mods[mod].prefix .. S("Teams amount successfully changed (@1)", amount))

  -- ritorno true per procedere al cambio di stack nell'editor
  return true
end



function arena_lib.toggle_teams_per_arena(sender, mod, arena_name, enable, in_editor)
  local id, arena = arena_lib.get_arena_by_name(mod, arena_name)

  if not in_editor then
    if not ARENA_LIB_EDIT_PRECHECKS_PASSED(sender, arena) then return end
  end

  local mod_ref = arena_lib.mods[mod]

  -- se non ci sono squadre nella mod, annullo
  if not next(mod_ref.teams) then
    arena_lib.print_error(sender, S("Teams are not enabled!"))
    return end

  if not mod_ref.can_disable_teams then
    arena_lib.print_error(sender, S("Teams cannot be disabled in this minigame!"))
  end

  if type(enable) ~= "boolean" then
    arena_lib.print_error(sender, S("Parameters don't seem right!"))
    return end

  -- se le squadre sono già in quello stato, annullo
  if enable == arena.teams_enabled then
    arena_lib.print_error(sender, S("Nothing to do here!"))
    return end

  -- se abilito
  if enable == true then
    arena.teams = {}
    arena.players_amount_per_team = {}

    for k, t_name in pairs(arena_lib.mods[mod].teams) do
      arena.teams[k] = {name = t_name}
      arena.players_amount_per_team[k] = 0
    end

    arena.teams_enabled = true
    arena_lib.print_info(sender, S("Teams successfully enabled for the arena @1", arena_name))

  -- se disabilito
  else
    arena.teams = {-1}
    arena.players_amount_per_team = nil
    arena.teams_enabled = false
    arena_lib.print_info(sender, S("Teams successfully disabled for the arena @1", arena_name))
  end

  -- svuoto i vecchi punti rinascita per evitare problemi
  arena_lib.set_spawner(sender, mod, arena_name, nil, "deleteall", nil, in_editor)

  -- aggiorno l'entrata, se esiste
  if arena.entrance then
    arena_lib.entrances[arena.entrance_type].update(mod, arena)
  end

  update_storage(false, mod, id, arena)
end



-- I punti rinascita si impostano o prendendo la coordinata del giocatore che lancia
-- il comando o, se lanciato da terminale, tramite `coords`. `param` può essere
-- "delete" o "deleteall"
function arena_lib.set_spawner(sender, mod, arena_name, team_ID, param, coords, in_editor)
  local id, arena = arena_lib.get_arena_by_name(mod, arena_name)

  if type(in_editor) == "number" then
    deprecated_spawner_ID_param(in_editor)
    in_editor = false
  end

  if not in_editor then
    if not ARENA_LIB_EDIT_PRECHECKS_PASSED(sender, arena) then return end
  end

  local mod_ref = arena_lib.mods[mod]

  -- se l'eventuale squadra non esiste, annullo
  if team_ID and not arena.teams[team_ID] then
    arena_lib.print_error(sender, S("This team doesn't exist!"))
    return end

  -- o sto modificando un punto già esistente...
  if param then
    if param == "delete" then
      -- se le squadre son abilitate ma non è specificato l'ID della squadra, annullo
      if arena.teams_enabled and not team_ID then
        arena_lib.print_error(sender, S("A team ID must be specified!"))
        return end

      local spawners = team_ID and table.copy(arena.spawn_points[team_ID]) or table.copy(arena.spawn_points)

      -- se non ci sono punti di rinascita, annullo
      if not next(spawners) then
        arena_lib.print_error(sender, S("There are no spawners to remove!"))
        return end

      local curr_spawner = {ID = 1, pos = spawners[1]}
      local p_pos = minetest.get_player_by_name(sender):get_pos()

      for i, pos in pairs(spawners) do
        if vector.distance(pos, p_pos) < vector.distance(curr_spawner.pos, p_pos) then
          curr_spawner = {ID = i, pos = pos}
        end
      end

      if team_ID then
        table.remove(arena.spawn_points[team_ID], curr_spawner.ID)
      else
        table.remove(arena.spawn_points, curr_spawner.ID)
      end

      arena_lib.print_info(sender, mod_ref.prefix .. S("Spawn point #@1 successfully deleted", curr_spawner.ID))

    elseif param == "deleteall" then
      if team_ID then
        arena.spawn_points[team_ID] = {}
        arena_lib.print_info(sender, S("All the spawn points belonging to team @1 have been removed", mod_ref.teams[team_ID]))
      else
        if arena.teams_enabled then
          for i = 1, #arena.teams do
            arena.spawn_points[i] = {}
          end
        else
          arena.spawn_points = {}
        end
        arena_lib.print_info(sender, S("All spawn points have been removed"))
      end

    else
      arena_lib.print_error(sender, S("Parameters don't seem right!"))
    end

    arena_lib.update_waypoints(sender, mod, arena)
    update_storage(false, mod, id, arena)
    return
  end

  -- ...sennò sto creando un nuovo punto rinascita
  local pos = vector.round(coords or minetest.get_player_by_name(sender):get_pos())       -- tolgo i decimali per immagazzinare un int

  -- se c'è già un punto di rinascita a quelle coordinate, annullo
  if not team_ID then
    for _, spawn in pairs(arena.spawn_points) do
      if vector.equals(pos, spawn) then
        arena_lib.print_error(sender, S("There's already a spawn in this point!"))
        return
      end
    end
  else
    for i = 1, #arena.teams do
      for _, spawn in pairs(arena.spawn_points[i]) do
        if vector.equals(pos, spawn) then
          arena_lib.print_error(sender, S("There's already a spawn in this point!"))
          return
        end
      end
    end
  end

  local spawn_points = team_ID and arena.spawn_points[team_ID] or arena.spawn_points
  local next_available_spawnID = #spawn_points +1

  -- imposto il punto di rinascita
  if team_ID then
    arena.spawn_points[team_ID][next_available_spawnID] = pos
  else
    arena.spawn_points[next_available_spawnID] = pos
  end

  arena_lib.update_waypoints(sender, mod, arena)
  arena_lib.print_info(sender, mod_ref.prefix .. S("Spawn point #@1 successfully set", next_available_spawnID))

  update_storage(false, mod, id, arena)
end



function arena_lib.set_entrance_type(sender, mod, arena_name, type)
  local id, arena = arena_lib.get_arena_by_name(mod, arena_name)

  if not arena_lib.is_player_in_edit_mode(sender) then
    if not ARENA_LIB_EDIT_PRECHECKS_PASSED(sender, arena) then return end
  end

  if arena.entrance_type == type then return end

  if not arena_lib.entrances[type] then
    arena_lib.print_error(sender, S("There is no entrance type with this name!"))
    return end

  -- se esiste, rimuovo l'entrata attuale onde evitare danni
  if arena.entrance then
    arena_lib.entrances[arena.entrance_type].remove(mod, arena)
    arena.entrance = nil
  end

  arena.entrance_type = type
  arena_lib.print_info(sender, arena_lib.mods[mod].prefix .. S("Entrance type of arena @1 successfully changed (@2)", arena_name, type))

  update_storage(false, mod, id, arena)
end



-- `action` = "add", "remove"
-- `...` è utile per "add", in quanto si vorrà passare perlomeno una posizione (nodi) o una stringa (entità) da salvare in arena.entrance
function arena_lib.set_entrance(sender, mod, arena_name, action, ...)
  local id, arena = arena_lib.get_arena_by_name(mod, arena_name)

  if not arena_lib.is_player_in_edit_mode(sender) then
    if not ARENA_LIB_EDIT_PRECHECKS_PASSED(sender, arena) then return end
  end

  local entrance = arena_lib.entrances[arena.entrance_type]

  if action == "add" then
    if arena.entrance then
      arena_lib.print_error(sender, S("There is already an entrance for this arena!"))
      return end

    local new_entrance = entrance.add(sender, mod, arena, ...)
    if not new_entrance then return end

    arena.entrance = new_entrance
    entrance.update(mod, arena)
    arena_lib.print_info(sender, arena_lib.mods[mod].prefix .. S("Entrance of arena @1 successfully set", arena_name))

  elseif action == "remove" then
    if not arena.entrance then
      arena_lib.print_error(sender, S("There is no entrance to remove assigned to @1!", arena_name))
      return end

    entrance.remove(mod, arena)
    arena.entrance = nil
    arena_lib.print_info(sender, arena_lib.mods[mod].prefix .. S("Entrance of arena @1 successfully removed", arena_name))

  else
    arena_lib.print_error(sender, S("Parameters don't seem right!"))
    return
  end

  update_storage(false, mod, id, arena)
end



function arena_lib.set_custom_return_point(sender, mod, arena_name, pos, in_editor)
  local id, arena = arena_lib.get_arena_by_name(mod, arena_name)

  if not in_editor then
    if not ARENA_LIB_EDIT_PRECHECKS_PASSED(sender, arena) then return end
  end

  if pos ~= nil and not vector.check(pos) then
    arena_lib.print_error(sender, S("Parameters don't seem right!"))
    return end

  if arena.custom_return_point == pos then
    arena_lib.print_error(sender, S("Nothing to do here!"))
    return end

  arena.custom_return_point = pos
  arena_lib.update_waypoints(sender, mod, arena)

  local msg = arena.custom_return_point and NS("Custom return point of arena @1 succesfully set")
                                         or NS("Custom return point of arena @1 succesfully removed")

  update_storage(false, mod, id, arena)
  arena_lib.print_info(sender, arena_lib.mods[mod].prefix .. S(msg, arena_name))
end



function arena_lib.set_region(sender, mod, arena_name, pos1, pos2, in_editor)
  local id, arena = arena_lib.get_arena_by_name(mod, arena_name)

  if not in_editor then
    if not ARENA_LIB_EDIT_PRECHECKS_PASSED(sender, arena) then return end
  end

  if not pos1 and not pos2 then
    arena.pos1 = nil
    arena.pos2 = nil

  else
    -- controllo che i parametri siano corretti
    if not pos1 or not pos2 or not vector.check(pos1) or not vector.check(pos2) then
      arena_lib.print_error(sender, S("Parameters don't seem right!"))
      return end

    local p1_sort, p2_sort = vector.sort(pos1, pos2)
    local areas = {}
    local ar_store = AreaStore()

    for mg, mg_data in pairs(arena_lib.mods) do
      for _, ar in pairs(mg_data.arenas) do
        if ar.pos1 and (ar.name ~= arena_name or mg ~= mod) then
          local ppos1_sort, ppos2_sort = vector.sort(ar.pos1, ar.pos2)
          local uuid = mg .. "_" .. ar.name
          areas[uuid] = ar_store:insert_area(ppos1_sort, ppos2_sort, "")
        end
      end
    end

    -- se l'area si interseca con l'area di un'altra arena
    if next(ar_store:get_areas_in_area(p1_sort, p2_sort, true, true)) then
      arena_lib.print_error(sender, S("Regions of different arenas can't overlap!"))
      for _, ar_id in pairs(areas) do
        ar_store:remove_area(ar_id)
      end
      return
    end

    for _, ar_id in pairs(areas) do
      ar_store:remove_area(ar_id)
    end

    arena.pos1 = vector.round(pos1)
    arena.pos2 = vector.round(pos2)
  end

  arena_lib.update_waypoints(sender, mod, arena)
  delete_schematic_if_exists(sender, mod, id)
  update_storage(false, mod, id, arena)
  arena_lib.print_info(sender, arena_lib.mods[mod].prefix .. S("Region of arena @1 successfully overwritten", arena_name))
end



function arena_lib.set_lighting(sender, mod, arena_name, light_table, in_editor)
  local id, arena = arena_lib.get_arena_by_name(mod, arena_name)

  if not in_editor then
    if not ARENA_LIB_EDIT_PRECHECKS_PASSED(sender, arena) then return end
  end

  if light_table ~= nil and type(light_table) ~= "table" then
    arena_lib.print_error(sender, S("Parameters don't seem right!"))
    return end

  arena.lighting = light_table

  update_storage(false, mod, id, arena)
  arena_lib.print_info(sender, arena_lib.mods[mod].prefix .. S("Lighting of arena @1 successfully overwritten", arena_name))
end



function arena_lib.set_celestial_vault(sender, mod, arena_name, element, params, in_editor)
  local id, arena = arena_lib.get_arena_by_name(mod, arena_name)

  if not in_editor then
    if not ARENA_LIB_EDIT_PRECHECKS_PASSED(sender, arena) then return end
  end

  if params ~= nil and type(params) ~= "table" then
    arena_lib.print_error(sender, S("Parameters don't seem right!"))
    return end

  -- sovrascrivi tutti
  if element == "all" then
    arena.celestial_vault = params

  -- sovrascrivine uno specifico
  elseif element == "sky" or element == "sun" or element == "moon" or element == "stars" or element == "clouds" then
    if not arena.celestial_vault then
      arena.celestial_vault = {}
    end
    arena.celestial_vault[element] = params

  -- oppure type non è un parametro contemplato
  else
    arena_lib.print_error(sender, S("Parameters don't seem right!"))
    return
  end

  element = element:gsub("^%l", string.upper) -- per non tradurre sia Sky che sky

  update_storage(false, mod, id, arena)
  arena_lib.print_info(sender, arena_lib.mods[mod].prefix .. S("(@1) Celestial vault of arena @2 successfully overwritten", S(element), arena_name))
end



function arena_lib.set_weather_condition(sender, mod, arena_name, particles, in_editor)
  local id, arena = arena_lib.get_arena_by_name(mod, arena_name)

  if not in_editor then
    if not ARENA_LIB_EDIT_PRECHECKS_PASSED(sender, arena) then return end
  end

  if particles ~= nil and type(particles) ~= "table" then
    arena_lib.print_error(sender, S("Parameters don't seem right!"))
    return end

  if not particles then
    arena.weather = nil

  else
    arena.weather = {
      amount = 100 * particles.amount,
      time = 0,
      pos = {
        min = {x = -50, y = particles.height - 3.5, z = -50},
        max = {x = 50, y = particles.height + 3.5, z = 50}
      },
      vel = {
        min = vector.new(0, particles.vel - 0.15, 0),
        max = vector.new(0, particles.vel + 0.15, 0),
      },
      minsize = particles.scale - 1.5,
      maxsize = particles.scale + 1.5,
      texture = {
        name = particles.texture,
        alpha_tween = particles.opacity,
        scale_tween = {
          {x = 1, y = 1},
          {x = 0.2, y = 0.2},
        },
      },
      collisiondetection = particles.collide,
      collision_removal = particles.remove_on_coll,
      minexptime = 3,
      maxexptime = 5,
    }
  end

  update_storage(false, mod, id, arena)
  arena_lib.print_info(sender, arena_lib.mods[mod].prefix .. S("Weather condition of arena @1 successfully overwritten", arena_name))
end




function arena_lib.set_bgm(sender, mod, arena_name, bgm_table, in_editor)
  local id, arena = arena_lib.get_arena_by_name(mod, arena_name)

  if not in_editor then
    if not ARENA_LIB_EDIT_PRECHECKS_PASSED(sender, arena) then return end
  end

  if not bgm_table then
    arena.bgm = nil

  else
    if not bgm_table.track then
      arena_lib.print_error(sender, S("parameter `@1` is mandatory!", "track"))
      return end


    if not audio_lib.is_sound_registered(bgm_table.track, "bgm") then
      arena_lib.print_error(sender, S("File not found!"))
      return end

    arena.bgm = bgm_table
    audio_lib.register_sound("bgm", bgm_table.track, bgm_table.description or S("-- missing description --"), { gain = bgm_table.gain, pitch = bgm_table.pitch })
  end

  update_storage(false, mod, id, arena)
  arena_lib.print_info(sender, arena_lib.mods[mod].prefix .. S("Background music of arena @1 successfully overwritten", arena_name))
end



function arena_lib.set_timer(sender, mod, arena_name, timer, in_editor)
  local id, arena = arena_lib.get_arena_by_name(mod, arena_name)

  if not in_editor then
    if not ARENA_LIB_EDIT_PRECHECKS_PASSED(sender, arena) then return end
  end

  local mod_ref = arena_lib.mods[mod]

  -- se la mod non supporta i timer
  if mod_ref.time_mode ~= "decremental" then
    arena_lib.print_error(sender, S("Timers are not enabled in this mod!") .. " (time_mode = 'decremental')")
    return end

  -- se è inferiore a 1
  if timer < 1 then
    arena_lib.print_error(sender, S("Parameters don't seem right!"))
    return end

  arena.initial_time = timer
  update_storage(false, mod, id, arena)

  arena_lib.print_info(sender, mod_ref.prefix .. S("Arena @1's timer is now @2 seconds", arena_name, timer))
end



function arena_lib.enable_arena(sender, mod, arena_name, in_editor)
  local id, arena = arena_lib.get_arena_by_name(mod, arena_name)

  if not in_editor then
    if not ARENA_LIB_EDIT_PRECHECKS_PASSED(sender, arena) then return end
  end

  local has_sufficient_spawners = true

  if arena.teams_enabled then
    for i = 1, #arena.teams do
      if #arena.spawn_points[i] == 0 then
        has_sufficient_spawners = false
        break
      end
    end
  elseif #arena.spawn_points == 0 then
    has_sufficient_spawners = false
  end

  -- se non ci sono abbastanza punti rinascita
  if not has_sufficient_spawners then
    arena_lib.print_error(sender, S("Insufficient spawners, the arena can't be enabled!"))
    arena.enabled = false
    return end

  -- se non c'è l'entrata
  if not arena.entrance then
    arena_lib.print_error(sender, S("Entrance not set, the arena can't be enabled!"))
    arena.enabled = false
    return end

  -- se c'è una regione ma qualche punto rinascita sta al di fuori
  if arena.pos1 then
    local v1, v2  = vector.sort(arena.pos1, arena.pos2)

    if not arena.teams_enabled then
      for _, spawner in pairs(arena.spawn_points) do
        if not vector.in_area(spawner, v1, v2) then
          arena_lib.print_error(sender, S("If the arena region is declared, all the existing spawn points must be placed inside it!"))
          return end
      end
    else
      for _, team_table in pairs(arena.spawn_points) do
        for _, spawner in pairs(team_table) do
          if not vector.in_area(spawner, v1, v2) then
            arena_lib.print_error(sender, S("If the arena region is declared, all the existing spawn points must be placed inside it!"))
            return end
        end
      end
    end
  end

  local mod_ref = arena_lib.mods[mod]

  if mod_ref.regenerate_map then
    if not arena.pos1 then
      arena_lib.print_error(sender, S("Region not declared!"))
      return end

    initialise_map_storage(mod, id)
  end

  -- eventuali controlli personalizzati
  if mod_ref.on_enable then
    if not mod_ref.on_enable(arena, sender) then return end
  end

  for _, callback in ipairs(arena_lib.registered_on_enable) do
    if not callback(mod, arena, sender) then return end
  end


  -- se sono nell'editor, vengo buttato fuori
  if arena_lib.is_player_in_edit_mode(sender) then
    arena_lib.quit_editor(minetest.get_player_by_name(sender))
  end

  -- abilito
  arena.enabled = true
  arena_lib.entrances[arena.entrance_type].update(mod, arena)
  update_storage(false, mod, id, arena)

  if mod_ref.endless then
    arena_lib.load_arena(mod, id)
  end

  arena_lib.print_info(sender, mod_ref.prefix .. S("Arena @1 successfully enabled", arena_name))
  return true
end



function arena_lib.disable_arena(sender, mod, arena_name)
  local mod_ref = arena_lib.mods[mod]
  local id, arena = arena_lib.get_arena_by_name(mod, arena_name)

  if not ARENA_LIB_EDIT_PRECHECKS_PASSED(sender, arena, true) then return end

  -- se è già disabilitata, annullo
  if not arena.enabled then
    arena_lib.print_error(sender, S("The arena is already disabled!"))
    return end

  -- se il minigioco è infinito e non ci son giocatorɜ, forzo il termine
  -- (rilancerà questa funzione ma con in_game = false)
  if mod_ref.endless and arena.in_game and arena.players_amount == 0 then
    arena_lib.force_end(sender, mod, arena)
    return end

  -- se una partita è in corso, annullo
  if arena.in_game then
    arena_lib.print_error(sender, S("You can't disable an arena during an ongoing game!"))
    return end

  -- eventuali controlli personalizzati
  if mod_ref.on_disable then
    if not mod_ref.on_disable(arena, sender) then return end
  end

  for _, callback in ipairs(arena_lib.registered_on_disable) do
    if not callback(mod, arena, sender) then return end
  end

  -- se c'è gente rimasta è in coda: annullo la coda e li avviso della disabilitazione
  for pl_name, stats in pairs(arena.players) do
    arena_lib.remove_player_from_queue(pl_name)
    arena_lib.print_error(pl_name, S("The arena you were queueing for has been disabled... :("))
  end

  -- disabilito
  arena.enabled = false
  arena_lib.entrances[arena.entrance_type].update(mod, arena)
  update_storage(false, mod, id, arena)

  arena_lib.print_info(sender, mod_ref.prefix .. S("Arena @1 successfully disabled", arena_name))
  return true
end





----------------------------------------------
--------------------UTILS---------------------
----------------------------------------------

-- ALL INTERNAL USE ONLY --- v
function arena_lib.store_inventory(player)
  local p_inv = player:get_inventory()
  local stored_inv = {}

  -- itero ogni lista non vuota per convertire tutti gli itemstack in tabelle (sennò non li serializza)
  for listname, content in pairs(p_inv:get_lists()) do
    if not p_inv:is_empty(listname) then
      stored_inv[listname] = {}
      for i_name, i_def in pairs(content) do
        stored_inv[listname][i_name] = i_def:to_table()
      end
    end
  end

  storage:set_string(player:get_player_name() .. ".INVENTORY", minetest.serialize(stored_inv))

  player:get_inventory():set_list("main",{})
  player:get_inventory():set_list("craft",{})
end



-- internal use only
function arena_lib.restore_inventory(p_name)

  if storage:get_string(p_name .. ".INVENTORY") ~= "" then

    local stored_inv = minetest.deserialize(storage:get_string(p_name .. ".INVENTORY"))
    local current_inv = minetest.get_player_by_name(p_name):get_inventory()

    -- ripristino l'inventario
    for listname, content in pairs(stored_inv) do
      -- se una lista non esiste più (es. son cambiate le mod), la rimuovo
      if not current_inv:get_list(listname) then
        stored_inv[listname] = nil
      else
        for i_name, i_def in pairs(content) do
          stored_inv[listname][i_name] = ItemStack(i_def)
        end
      end
    end

    -- quando una lista viene salvata, la sua grandezza equivarrà all'ultimo slot contenente
    -- un oggetto. Per evitare quindi che reimpostando la lista, l'inventario si rimpicciolisca,
    -- salvo prima la grandezza dell'inventario immacolato, applico la lista e poi reimposto la grandezza.
    -- Questo mi evita di dover salvare nel database la grandezza di ogni lista.
    for listname, _ in pairs (current_inv:get_lists()) do
      local list_size = current_inv:get_size(listname)
      current_inv:set_list(listname, stored_inv[listname])
      current_inv:set_size(listname, list_size)
    end

    storage:set_string(p_name .. ".INVENTORY", "")
  end
end



function arena_lib.load_maps_from_db()
  local map = minetest.deserialize(storage:get_string("maps"))

  if map == "" or map == nil then
    map = {}
  end

  return map
end



function arena_lib.save_maps_onto_db(table)
  storage:set_string("maps", minetest.serialize(table))
end
-- ^ ------------------------------------ ^




----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function load_settings(mod)
  -- primo avvio
  if storage:get_string(mod .. ".SETTINGS") == "" then
    local default_settings = {
      return_point = { x = 0, y = 20, z = 0},
      queue_waiting_time = 10
    }
    arena_lib.mods[mod].settings = default_settings
    storage:set_string(mod .. ".SETTINGS", minetest.serialize(default_settings))
  else
    arena_lib.mods[mod].settings = minetest.deserialize(storage:get_string(mod .. ".SETTINGS"))
  end
end



function init_storage(mod, mod_ref)
  arena_lib.mods[mod] = mod_ref

  -- aggiungo le arene
  for i = 1, arena_lib.mods[mod].highest_arena_ID do
    local arena_str = storage:get_string(mod .. "." .. i)

    -- se c'è una stringa con quell'ID, aggiungo l'arena e inizializzo l'entrata
    if arena_str ~= "" then
      local arena = minetest.deserialize(arena_str)
      local to_update = false

      --v------------------ LEGACY UPDATE, to remove in 8.0 -------------------v
      if arena.spawn_points[1] and arena.spawn_points[1].pos then
        local spawn_points = {}

        if arena.spawn_points[1].teamID then
          for j = 1, #arena.teams do
            spawn_points[j] = {}
          end
          for _, spawner in pairs(arena.spawn_points) do
            table.insert(spawn_points[spawner.teamID], spawner.pos)
          end
          arena.spawn_points = spawn_points

        else
          for _, spawner in pairs(arena.spawn_points) do
            table.insert(spawn_points, spawner.pos)
          end
          arena.spawn_points = spawn_points
        end
        minetest.log("action", "[ARENA_LIB] spawn points of arena " .. arena.name ..
          " has been converted into the new format")
        to_update = true
      end
      --^------------------ LEGACY UPDATE, to remove in 8.0 -------------------^

      --v------------------ LEGACY UPDATE, to remove in 9.0 -------------------v
      if arena.celestial_vault and arena.celestial_vault.sky and not arena.celestial_vault.sky.fog then
        arena.celestial_vault.sky.fog = {}
        to_update = true
      end

      -- guarda anche nella gestione squadre più in basso
      --^------------------ LEGACY UPDATE, to remove in 9.0 -------------------^

      -- gestione mappa
      if mod_ref.regenerate_map then
        if arena.is_resetting == nil then
          arena.is_resetting = false
          to_update = true
        end

        if arena.enabled and not arena.pos1 then
          arena.enabled = false
          to_update = true
        end
      elseif not mod_ref.regenerate_map and arena.is_resetting ~= nil then
        arena.is_resetting = nil
        to_update = true
      end

      -- gestione squadre
      -- se avevo abilitato le squadre e ora le ho rimosse dalla mod
      if arena.teams_enabled and not (#mod_ref.teams > 1) then
        arena.teams = {-1}
        arena.teams_enabled = false
        arena.players_amount_per_team = nil
        arena.spectators_amount_per_team = nil
        arena.spawn_points = {}
        arena.enabled = false
        to_update = true

      -- se la mod ha le squadre non disattivabili e l'arena non ha squadre, le forzo
      elseif #mod_ref.teams > 1 and not mod_ref.can_disable_teams and not arena.teams_enabled then
        arena.enabled = false

        arena.players_amount_per_team = {}
        arena.spectators_amount_per_team = {}
        arena.teams = {}
        arena.spawn_points = {}

        for id, t_name in pairs(mod_ref.teams) do
          arena.players_amount_per_team[id] = 0
          arena.spectators_amount_per_team[id] = 0
          arena.teams[id] = {name = t_name}
          arena.spawn_points[id] = {}
        end

        arena.teams_enabled = true
        to_update = true

      -- se l'arena ha le squadre, non supporta n° variabile e il n° non coincide, le aggiorno
      elseif arena.teams_enabled and not mod_ref.variable_teams_amount and #mod_ref.teams ~= #arena.teams then
        for id, t_name in pairs(mod_ref.teams) do
          arena.players_amount_per_team[id] = 0
          arena.spectators_amount_per_team[id] = 0
          arena.teams[id] = {name = t_name}
          arena.spawn_points[id] = {}
        end

        arena.enabled = false
        to_update = true
        minetest.log("action", "[ARENA_LIB] teams amount of arena " .. arena.name .. " has changed: resetting arena spawn points")

      -- se l'arena ha le squadre ma il numero max di squadre del minigioco è ora minore di quello dell'arena, abbasso
      elseif arena.teams_enabled and #arena.teams > #mod_ref.teams then
        local extra_teams = #mod_ref.teams - #arena.teams

        for j = 1, extra_teams do
          arena.teams[j] = nil
          arena.spawn_points[j] = nil
          arena.players_amount_per_team[j] = nil
          arena.spectators_amount_per_team[j] = nil
        end

        arena.enabled = false
        to_update = true

      -- LEGACY UPDATE, REMOVE IN 9.0
      -- se l'arena ha le squadre ma players_amount_per_team è maggiore (vecchia struttura), sistema
      elseif arena.teams_enabled and #arena.teams > #arena.players_amount_per_team then
        local extra_teams = #arena.players_amount_per_team - #arena.teams

        for j = 1, extra_teams do
          arena.players_amount_per_team[j] = nil
          arena.spectators_amount_per_team[j] = nil
        end

        to_update = true
      end

      -- aggiorna lɜ giocatorɜ minimɜ in caso di conflitto
      if mod_ref.endless and arena.min_players > 0 then
        arena.min_players = 0
        to_update = true
      end

      if arena.min_players < mod_ref.min_players then
        arena.min_players = mod_ref.min_players
        if arena.max_players < mod_ref.min_players then
          arena.max_players = mod_ref.min_players
        end
        to_update = true
      end

      -- gestione spettatore
      if mod_ref.spectate_mode and arena.teams_enabled and not arena.spectators_amount_per_team then
        arena.spectators_amount_per_team = {}

        for id, _ in pairs(arena.teams) do
          arena.spectators_amount_per_team[id] = 0
        end

        to_update = true
      end

      -- gestione tempo
      if mod_ref.time_mode == "none" and arena.initial_time then                     -- se avevo abilitato il tempo e ora l'ho rimosso, lo tolgo dalle arene
        arena.initial_time = nil
        to_update = true
      elseif mod_ref.time_mode ~= "none" and not arena.initial_time then             -- se li ho abilitati ora e le arene non ce li hanno, glieli aggiungo
        arena.initial_time = mod_ref.time_mode == "incremental" and 0 or 300
        to_update = true
      elseif mod_ref.time_mode == "incremental" and arena.initial_time > 0 then      -- se ho disabilitato i timer e le arene ce li avevano, porto il tempo a 0
        arena.initial_time = 0
        to_update = true
      elseif mod_ref.time_mode == "decremental" and arena.initial_time == 0 then     -- se ho abilitato i timer e le arene partivano da 0, imposto il timer a 5 minuti
        arena.initial_time = 300
        to_update = true
      end

      -- registro sottofondo
      if arena.bgm then
        local bgm = arena.bgm
        audio_lib.register_sound("bgm", bgm.track, bgm.title or S("-- missing description --"), { gain = bgm.gain, pitch = bgm.pitch })
      end

      arena_lib.mods[mod].arenas[i] = arena

      if to_update then
        update_storage(false, mod, i, arena)
      end

      -- Contrariamente alle entità, i nodi non hanno un richiamo `on_activate`,
      -- ergo se si vogliono aggiornare all'avvio serve per forza un `on_load`
      minetest.after(0.01, function()
        if arena.entrance then                                                  -- signs_lib ha bisogno di un attimo per caricare sennò tira errore. Se
          arena_lib.entrances[arena.entrance_type].load(mod, arena)             -- non è ancora stato registrato nessun nodo per l'arena, evito il crash
        end
      end)
    end
  end

  check_for_properties(mod, mod_ref)

  -- se il minigioco è infinito, avvia tutte le arene non disabilitate
  if mod_ref.endless then
    for id, arena in pairs(mod_ref.arenas) do
      if arena.enabled then
        minetest.after(0.1, function()
          arena_lib.load_arena(mod, id)
        end)
      end
    end
  end

  minetest.log("action", "[ARENA_LIB] Mini-game " .. mod .. " loaded")
end



function update_storage(erase, mod, id, arena)
  -- ogni mod e ogni arena vengono salvate seguendo il formato mod.ID
  local entry = mod .."." .. id

  if erase then
    storage:set_string(entry, "")
    storage:set_string(mod .. ".HIGHEST_ARENA_ID", arena_lib.mods[mod].highest_arena_ID)
  else
    storage:set_string(entry, minetest.serialize(arena))
  end
end



function file_exists(src_dir, name)
  local function iterate_dirs(dir)
    for _, f_name in pairs(minetest.get_dir_list(dir, false)) do
      if name == f_name then
        return true
      end
    end

    for _, subdir in pairs(minetest.get_dir_list(dir, true)) do
       if iterate_dirs(dir .. "/" .. subdir) then
         return true
       end
    end
  end

  return iterate_dirs(src_dir)
end


-- le proprietà vengono salvate nello spazio d'archiviazione senza valori, in una coppia id-proprietà. Sia per leggerezza, sia perché non c'è bisogno di paragonarne i valori
function check_for_properties(mod, mod_ref)
  local old_properties = storage:get_string(mod .. ".PROPERTIES")
  local has_old_properties = old_properties ~= ""
  local has_new_properties = next(mod_ref.properties) ~= nil

  -- se non ce n'erano prima e non ce ne sono ora, annullo
  if not has_old_properties and not has_new_properties then
    return

  -- se non c'erano prima e ora ci sono, proseguo
  elseif not has_old_properties and has_new_properties then
    minetest.log("action", "[ARENA_LIB] Properties have been declared. Proceeding to add them")

  -- se c'erano prima e ora non ci sono più, svuoto e annullo
  elseif has_old_properties and not has_new_properties then

    for property, _ in pairs(minetest.deserialize(old_properties)) do
      for id, arena in pairs(mod_ref.arenas) do
        arena[property] = nil
        update_storage(false, mod, id, arena)
      end
    end

    minetest.log("action", "[ARENA_LIB] There are no properties left in the declaration of the mini-game. They've been removed from arenas")
    storage:set_string(mod .. ".PROPERTIES", "")
    return

  -- se c'erano sia prima che ora, le confronto
  else
    local new_properties_table = {}
    local old_properties_table = minetest.deserialize(old_properties) -- chiave: num,       valore: proprietà
    local old_swapped = table.key_value_swap(old_properties_table)    -- chiave: proprietà, valore: num

    for property, _ in pairs(mod_ref.properties) do
      table.insert(new_properties_table, property)  -- se non invertissi e usassi direttamente `mod_ref.properties` sotto, `#` non funzionerebbe perché le chiavi sono stringhe
      old_swapped[property] = nil
    end

    -- se sono uguali in tutto e per tutto, termino qui. Uso `old_swapped` per verificare
    -- che oltre che a essere di numero uguali, siano anche le stesse chiavi (che
    -- rimuovo nel ciclo sovrastante)
    if #old_properties_table == #new_properties_table and not next(old_swapped) then
      return
    else
      minetest.log("action", "[ARENA_LIB] Properties have changed. Proceeding to modify old arenas")
    end
  end

  local old_table = minetest.deserialize(old_properties)
  local old_properties_table = {}

  -- converto la tabella dello storage in modo che sia compatibile con mod_ref, spostando le proprietà sulle chiavi
  if old_table then
    for _, property in pairs(old_table) do
      old_properties_table[property] = true
    end
  end

  -- aggiungo le nuove proprietà
  for property, v in pairs(mod_ref.properties) do
    if old_properties_table[property] == nil then
      assert(arena_default[property] == nil and arena_optional_fields[property] == nil, "[ARENA_LIB] Custom property " .. property ..
              " of mod " .. mod_ref.name .. " can't be added as it has got the same name of an arena default property. Please rename it")
      minetest.log("action", "[ARENA_LIB] Adding property " .. property)

      for id, arena in pairs(mod_ref.arenas) do
        arena[property] = v
        update_storage(false, mod, id, arena)
      end
    end
  end

  -- rimuovo quelle non più presenti
  for old_property, _ in pairs(old_properties_table) do
    if mod_ref.properties[old_property] == nil then
      minetest.log("action", "[ARENA_LIB] Removing property " .. old_property)

      for id, arena in pairs(mod_ref.arenas) do
        arena[old_property] = nil
        update_storage(false, mod, id, arena)
      end
    end

  end

  local new_properties_table = {}

  -- inverto le proprietà di mod_ref da chiavi a valori per registrarle nello spazio d'archiviazione
  for property, _ in pairs(mod_ref.properties) do
    table.insert(new_properties_table, property)
  end

  storage:set_string(mod .. ".PROPERTIES", minetest.serialize(new_properties_table))
end



-- l'ID di base parte da 1 (n+1). Se la sequenza è 1, 3, 4, grazie a ipairs la
-- funzione vede che manca 2 nella sequenza e ritornerà 2
function next_available_ID(mod_ref)
  local id = 0
  for k, v in ipairs(mod_ref.arenas) do
    id = k
  end
  return id +1
end



function delete_schematic_if_exists(sender, mod, id)
  local schem_path = minetest.get_worldpath() .. ("/arena_lib/Schematics/%s_%d.mts"):format(mod, id)
  local schem = io.open(schem_path, "r")

  if schem then
    local mod_ref = arena_lib.mods[mod]
    local arena_name = mod_ref.arenas[id].name

    schem:close()
    minetest.rmdir(schem_path, true)
    arena_lib.print_info(sender, mod_ref.prefix .. S("Schematic of arena @1 deleted", arena_name))
  end
end



function is_arena_name_allowed(sender, mod, arena_name)
  -- se esiste già un'arena con quel nome, annullo
  if arena_lib.get_arena_by_name(mod, arena_name) then
    arena_lib.print_error(sender, S("An arena with that name exists already!"))
    return end

  local matched_string = string.match(arena_name, "([%w%p%s]+)")

  -- se contiene caratteri non supportati da signs_lib o termina con uno spazio, annullo
  if arena_name ~= matched_string or string.match(arena_name, "#") ~= nil or arena_name:sub(#arena_name, -1) == " " then
    arena_lib.print_error(sender, S("The name contains unsupported characters!"))
    return end

  return true
end



function initialise_map_storage(mod, id)
  local maps = arena_lib.load_maps_from_db()
  local idx = mod .. "_" .. id

  if not maps then maps = {} end
  if not maps[idx] then maps[idx] = {} end
  if not maps[idx].changed_nodes then maps[idx].changed_nodes = {} end

  arena_lib.save_maps_onto_db(maps)
end





----------------------------------------------
------------------DEPRECATED------------------
----------------------------------------------

-- to remove in 9.0
function deprecated_sound_table_entry_exists(audio)
  assert(type(audio) ~= "string", "[ARENA_LIB] since arena_lib 7.0 `sounds` entries must be tables. Check the new format in the arena_lib docs!")
end

function deprecated_chat_settings(mod_ref)
  local chat_settings = mod_ref.chat_settings
  mod_ref.chat_all_prefix = chat_settings.prefix_all
  mod_ref.chat_team_prefix = chat_settings.prefix_team
  mod_ref.chat_spectate_prefix = chat_settings.prefix_spectate
  mod_ref.chat_all_color = chat_settings.color_all
  mod_ref.chat_team_color = chat_settings.color_team
  mod_ref.chat_spectate_color = chat_settings.color_spectate
  mod_ref.is_team_chat_default = chat_settings.is_team_chat_default
end

function arena_lib.force_arena_ending(mod, arena, sender)
  minetest.log("warning", "[ARENA_LIB] (" .. mod .. ") force_arena_ending is deprecated. Please use force_end instead")
  arena_lib.force_end(sender, mod, arena)
end



function arena_lib.get_player_spectated(sp_name)
  local mod = arena_lib.get_mod_by_player(sp_name) or "???"
  minetest.log("warning", "[ARENA_LIB] (" .. mod .. ") get_player_spectated is deprecated. Please use get_spectated_target instead")
  return arena_lib.is_player_spectating(sp_name) and arena_lib.get_spectated_target(sp_name).name
end



function arena_lib.get_spectate_entities(mod, arena_name)
  minetest.log("warning", "[ARENA_LIB] (" .. mod .. ") get_spectate_entities is deprecated. Please use get_spectatable_entities instead")
  return arena_lib.get_spectatable_entities(mod, arena_name)
end

function arena_lib.get_spectate_areas(mod, arena_name)
  minetest.log("warning", "[ARENA_LIB] (" .. mod .. ") get_spectate_areas is deprecated. Please use get_spectatable_areas instead")
  return arena_lib.get_spectatable_areas(mod, arena_name)
end

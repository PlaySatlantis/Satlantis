local S = minetest.get_translator("arena_lib")



function ARENA_LIB_EDIT_PRECHECKS_PASSED(sender, arena, skip_enabled)
  -- se non esiste l'arena, annullo
  if arena == nil then
    arena_lib.print_error(sender, S("This arena doesn't exist!"))
    return end

  -- se non è disabilitata, annullo
  if arena.enabled and not skip_enabled then
    arena_lib.print_error(sender, S("You must disable the arena first!"))
    return end

  -- se è in modalità edit, annullo
  if arena_lib.is_arena_in_edit_mode(arena.name) then
    local p_name_inside = arena_lib.get_player_in_edit_mode(arena.name)
    arena_lib.print_error(sender, S("There must be no one inside the editor of the arena to perform this command! (now inside: @1)", p_name_inside))
    return end

  return true
end



function ARENA_LIB_JOIN_CHECKS_PASSED(mod, arena, p_name)
  -- se si è nell'editor
  if arena_lib.is_player_in_edit_mode(p_name) then
    arena_lib.print_error(p_name, S("You must leave the editor first!"))
    return end

  -- se non è abilitata
  if not arena.enabled then
    arena_lib.print_error(p_name, S("The arena is not enabled!"))
    return end

  local kicked, sec_left = arena_lib.has_player_been_kicked(p_name)

  -- se si è statɜ cacciatɜ di recente
  if kicked then
    arena_lib.print_error(p_name, S("You've recently been kicked from a game! Time left before being able to join a new match: @1s", sec_left))
    return end

  -- se c'è `parties` e si è in gruppo...
  if minetest.get_modpath("parties") and parties.is_player_in_party(p_name) then
    -- se non si è il capo gruppo
    if not parties.is_player_party_leader(p_name) then
      arena_lib.print_error(p_name, S("Only the party leader can enter the queue!"))
      return end

    local party_members = parties.get_party_members(p_name, true)
    local min_version = arena_lib.mods[mod].min_version

    -- per tutti i membri...
    for _, pl_name in pairs(party_members) do
      kicked, sec_left = arena_lib.has_player_been_kicked(pl_name)

      -- se unə è statə cacciatə di recente
      if kicked then
        arena_lib.print_error(p_name, S("One of your party members has recently been kicked from a game! Time left before being able to join a new match: @1s", sec_left))
        return end

      -- se unə è in partita
      if arena_lib.is_player_in_arena(pl_name) and not arena_lib.is_player_spectating(pl_name) then
        arena_lib.print_error(p_name, S("You must wait for all your party members to finish their ongoing games before entering a new one!"))
        return end

      -- se si è attaccatɜ a qualcosa
      if minetest.get_player_by_name(pl_name):get_attach() and not arena_lib.is_player_spectating(pl_name) then
        arena_lib.print_error(p_name, S("Can't enter a game if some of your party members are attached to something! (e.g. boats, horses etc.)"))
        return end

      -- se unə non ha una versione abbastanza recente
      if minetest.get_player_information(pl_name).protocol_version < min_version then
        arena_lib.print_error(p_name, S("@1 is running a Minetest version too old to play this minigame!", pl_name))
        return end
    end

    --se non c'è spazio (a prescindere dalle squadre)
    if arena.max_players ~= -1 and #party_members > (arena.max_players * #arena.teams) - arena.players_amount then
      arena_lib.print_error(p_name, S("There is not enough space for the whole party!"))
      return end

    -- se ci son le squadre e non c'è nessuna squadra con abbastanza spazio
    if arena.teams_enabled then -- TODO futuro: e se NON num. squadre responsivo
      local free_space = false
      for _, amount in pairs(arena.players_amount_per_team) do
        if #party_members <= arena.max_players - amount then
          free_space = true
          break
        end
      end

      if not free_space then
        arena_lib.print_error(p_name, S("There is no team with enough space for the whole party!"))
        return end
    end
  end

  local player = minetest.get_player_by_name(p_name)

  -- se si è attaccatɜ a qualcosa
  if player:get_attach() and not arena_lib.is_player_spectating(p_name) then
    arena_lib.print_error(p_name, S("You must detach yourself from the entity you're attached to before entering!"))
    return end

  -- se non si ha una versione abbastanza recente
  if minetest.get_player_information(p_name).protocol_version < arena_lib.mods[mod].min_version then
    arena_lib.print_error(p_name, S("Your version of Minetest is too old to play this minigame! Please update it"))
    return end

  -- se l'arena è piena
  if arena.players_amount == arena.max_players * #arena.teams then
    arena_lib.print_error(p_name, S("The arena is already full!"))
    return end

  return true
end



function AL_property_to_string(property)
  if type(property) == "string" then
    return "\"" .. property .. "\""
  elseif type(property) == "table" then
    return tostring(dump(property)):gsub("\n", "")
  else
    return tostring(property)
  end
end

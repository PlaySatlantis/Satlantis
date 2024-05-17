local S = fbrawl.T



arena_lib.on_load("fantasy_brawl", function(arena)
   for pl_name in pairs(arena.players) do
      local player = minetest.get_player_by_name(pl_name)
      player:set_physics_override({speed = 0.01, acceleration_default = 0, acceleration_air = 0})
   end
end)



arena_lib.on_start("fantasy_brawl", function(arena)
   for pl_name in pairs(arena.players) do
      fbrawl.join_player(arena, pl_name)
      minetest.sound_play({name="fbrawl_match_start"}, {to_player = pl_name})
   end

   arena.match_started = true
   arena_lib.HUD_send_msg_all("broadcast", arena, S("The player with the most kills wins"), 5) 
end)



arena_lib.on_join("fantasy_brawl", function(pl_name, arena, as_spectator, was_spectator)
   if not as_spectator then
      fbrawl.join_player(arena, pl_name)
      if was_spectator then
         fbrawl.generate_stats(minetest.get_player_by_name(pl_name), pl_name)
         fbrawl.generate_controls_hud(arena, pl_name)
      end
   end

   fbrawl.init_HUD(arena, pl_name, as_spectator)
end)



arena_lib.on_end("fantasy_brawl", function(arena, winners, is_forced)
   for psp_name, _ in pairs(arena.players_and_spectators) do
      fbrawl.out_of_match_operations(psp_name)
   end
end)



arena_lib.on_celebration("fantasy_brawl", function(arena, winners)
   arena_lib.HUD_hide("title", arena)

   for pl_name, _ in pairs(arena.players) do
      local player = minetest.get_player_by_name(pl_name)
      fbrawl.stop_skills(pl_name)
      player:get_inventory():set_list("main", {})
   end

   for pl_name, _ in pairs(arena.players_and_spectators) do
      fbrawl.show_podium_HUD(pl_name)
   end
end)



arena_lib.on_death("fantasy_brawl", function(arena, pl_name, reason)
   arena.classes[pl_name]:on_death(arena, pl_name, reason)
   fbrawl.respawn_player(pl_name)
end)



arena_lib.on_timeout("fantasy_brawl", function(arena)
   arena_lib.load_celebration("fantasy_brawl", arena, "")
end)



arena_lib.on_time_tick("fantasy_brawl", function(arena)
   fbrawl.update_timer_hud(arena)
end)



minetest.register_allow_player_inventory_action(function(player, action, inventory, inventory_info)
   local pl_name = player:get_player_name()
   local mod = arena_lib.get_mod_by_player(pl_name)
   local arena = arena_lib.get_arena_by_player(pl_name)

   if mod == "fantasy_brawl" and arena.in_game and action == "move" then
      return 0
   end
end)



arena_lib.on_quit("fantasy_brawl", function(arena, pl_name, is_spectator, reason)
   fbrawl.out_of_match_operations(pl_name)
end)

arena_lib.on_prequit("fantasy_brawl", function(arena, pl_name)
   if arena.in_loading then return false end
   fbrawl.stop_skills(pl_name)
end)

local S = fbrawl.T



function fbrawl.is_player_playing(pl_name)
   local arena = arena_lib.get_arena_by_player(pl_name)
   local mod = arena_lib.get_mod_by_player(pl_name) == "fantasy_brawl"
   local player = minetest.get_player_by_name(pl_name)
   local respawning = fbrawl.get_weapon(player):get_name() == "fantasy_brawl:respawn_hand"

   return
   mod and arena and not arena.in_celebration 
   and not arena.in_loading and arena.in_game 
   and not respawning 
   and arena.classes[pl_name] -- in case it's spectacting or the class hasn't been assigned yet
   and not arena_lib.is_player_spectating(pl_name)
end



function fbrawl.out_of_match_operations(pl_name)
   fbrawl.stop_sounds(pl_name)
   fbrawl.remove_huds(pl_name)

   for skill_name, def in pairs(skills.get_unlocked_skills(pl_name, "fbrawl")) do
      pl_name:remove_skill(skill_name)
   end

   local player = minetest.get_player_by_name(pl_name)

   player:set_properties({hp_max = minetest.PLAYER_MAX_HP_DEFAULT})
   player:set_hp(minetest.PLAYER_MAX_HP_DEFAULT)
end



function fbrawl.stop_skills(pl_name)
   for skill_name, def in pairs(skills.get_unlocked_skills(pl_name, "fbrawl")) do
      pl_name:stop_skill(skill_name)
   end
end



function fbrawl.join_player(arena, pl_name)
   local pl_meta = minetest.get_player_by_name(pl_name):get_meta()
   local pl_data = minetest.deserialize(pl_meta:get_string("fbrawl:data")) or {}
   local pl_class = table.copy(fbrawl.get_class_by_name(pl_data.chosen_class or "warrior"))

   arena.classes[pl_name] = pl_class
   arena.classes[pl_name]:on_start(arena, pl_name)

   fbrawl.add_hp_bar(minetest.get_player_by_name(pl_name))
end

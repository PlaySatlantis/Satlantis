skills.register_skill("fbrawl:hp_regen", {
   name = "Hp Regen",
	can_be_blocked_by_other_skills = false,
   loop_params = {
      cast_rate = 0.1,
   },
   data = {
		last_hit_timestamp = 0,
		custom_cast_rate = 0.1,
	},
	out_of_fight_min_seconds = 4,
	on_start = function(self)
		self.loop_params.cast_rate = self.data.custom_cast_rate
	end,
	cast = function(self)
		local seconds_since_last_hit = fbrawl.get_time_in_seconds() - self.data.last_hit_timestamp
		
		if self.player:get_hp() > 0 and seconds_since_last_hit >= self.out_of_fight_min_seconds then
			local arena = arena_lib.get_arena_by_player(self.pl_name)

			self.player:set_hp(self.player:get_hp() + 1 * 10)
			arena.players[self.pl_name].hit_by = {}
		end
	end
})



minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
   local pl_name = player:get_player_name()
   local hp_regen = pl_name:get_skill("fbrawl:hp_regen")

	if not hp_regen or not hp_regen.is_active then return end

	hp_regen.data.last_hit_timestamp = fbrawl.get_time_in_seconds()
end)
fbrawl.min_kills_to_use_ultimate = 5



skills.register_layer("fbrawl:ulti_layer", {
	name = "Ultimate Template",
	can_cast = function (self)
		if not fbrawl.can_cast_ultimate(self.pl_name) then
			return false
		end

		return true
	end
})



function fbrawl.can_cast_ultimate(pl_name)
   local arena = arena_lib.get_arena_by_player(pl_name)
   return arena.players[pl_name].ultimate_recharge >= fbrawl.min_kills_to_use_ultimate
end



function fbrawl.cast_ultimate(pl_name, skill_name, args)
   local skill = pl_name:get_skill(skill_name)
   if not skill then return false end

   local arena = arena_lib.get_arena_by_player(pl_name)
   local props = arena.players[pl_name]

   if not fbrawl.can_cast_ultimate(pl_name) then return end

   props.ultimate_recharge = 0

   if skill.loop_params then
      pl_name:start_skill(skill_name, args)
   else
      pl_name:cast_skill(skill_name, args)
   end
end
minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
   local pl_name = player:get_player_name()
   local hp_regen = pl_name:get_skill("fbrawl:hp_regen")

	if not hp_regen or not hp_regen.is_active then return end

	fbrawl.spawn_blood_particle(player, damage)
end)



function fbrawl.spawn_blood_particle(player, damage)
	minetest.add_particlespawner({
      amount = damage / 2,
      time = 0.4,
      minvel = {x = -1, y = 0.5, z = -1},
      maxvel = {x = 1, y = -2, z = 1},
      minsize = 4,
      maxsize = 6,
      texture = {
         name = "fbrawl_blood_particle.png",
			scale_tween = {
				{x = 1, y = 1},
				{x = 0, y = 0},
			}
      },
      collisiondetection = true,
      minexptime = 0.2,
      maxexptime = 0.4,
      pos = {
			max = vector.add(player:get_pos(), {x=0.3, y=1.5, z=0.3}),
			min = vector.add(player:get_pos(), {x=-0.3, y=0, z=-0.3}),
		}
   })
end
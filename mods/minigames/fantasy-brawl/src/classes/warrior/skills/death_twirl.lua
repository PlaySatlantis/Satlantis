local S = fbrawl.T



skills.register_skill("fbrawl:death_twirl", {
	name = S("Death Twirl"),
	icon = "fbrawl_death_twirl_skill.png",
	description = S("Sprint damaging whoever gets in the way."),
	cooldown = 7,
	damage = 4,
	force = 26,
	max_damage = 4,
	loop_params = {
		cast_rate = 0,
		duration = 1
	},
	data = {
		hit_players = {},  -- {"pl_name1" = true, "pl_name2" = true, ...}
		time_passed = 0,
		damage_inflicted = 0
	},
	sounds = {
		start = {name="fbrawl_death_twirl", object = true, max_hear_distance = 12},
	},
	attachments = {
      particles = {{
         amount = 35,
         time = 0,
         minpos = {x = -0.3, y =  0, z = -0.3},
         maxpos = {x = 0.3, y = 1.5, z = 0.3},
         minvel = {x = 0, y =  0, z = -1},
         maxvel = {x = 0, y = 0, z = -2},
         minsize = 4,
         maxsize = 9,
         texture = {
            name = "fbrawl_smoke_particle.png",
            alpha_tween = {0.8, 0},
				scale = {x=1, y=1, z=1}, {x=1.5, y=1.5, z=1.5}
         },
         minexptime = 1,
         maxexptime = 1.5,
      }}
	},
	on_start = function(self)
		local dir = minetest.get_player_by_name(self.pl_name):get_look_dir()
		local velocity = vector.multiply(dir, self.force)
		velocity.y = 0
		
		self.player:add_velocity(velocity)

		self.data.hit_players = {}
		self.data.damage_inflicted = 0
	end,
	cast = function(self)
		if self.data.damage_inflicted >= self.max_damage then 
			self:stop()
			return
		end

		local pl = self.player
		local hit_pl_name
		fbrawl.damage_players_near(pl, pl:get_pos(), 2, self.damage, nil, function(pl_name)
			hit_pl_name = pl_name
		end)
		
		if hit_pl_name then
			local has_been_hit_already = self.data.hit_players[hit_pl_name]

			self.data.damage_inflicted = self.data.damage_inflicted + self.damage

			if not has_been_hit_already then
				self.data.hit_players[hit_pl_name] = true

				hit_pl_name:unlock_skill("fbrawl:twirl")
				hit_pl_name:start_skill("fbrawl:twirl")
			end
		end
	end
})



skills.register_skill("fbrawl:twirl", {
	name = "Twirl",
	speed = 0.2,
	loop_params = {
		cast_rate = 0,
		duration = 1
	},
	data = {
		hit_players = {}  -- {"pl_name1" = true, "pl_name2" = true, ...}
	},
	cast = function(self)
		local pl = self.player
		pl:set_look_horizontal(pl:get_look_horizontal() + self.speed)
	end
})
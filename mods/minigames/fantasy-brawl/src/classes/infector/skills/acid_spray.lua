local S = fbrawl.T
local spray_particles = {
	amount = 140,
	time = 0,
	pos = {
		min = {x = 0.25, y = 1.4, z = 0},
		max = {x = 0.35, y = 1.6, z = 0.1}
	},
	vel = {
		min = vector.new(-4,-6, 30),
		max = vector.new(2, 6, 40),
	},
	minacc = {x=0, y=-2, z=10},
	minsize = 1,
	maxsize = 3,
	glow = 12,
	texture = {
		name = "fbrawl_poison_particle.png",
		alpha_tween = {1, 0.1},
		scale_tween = {
			{x = 1, y = 1},
			{x = 0.5, y = 0.5},
		},
		animation = {
			type = "vertical_frames",
			aspect_w = 16, aspect_h = 16,
			length = 0.15,
		},
	},

	collisiondetection = true,
	object_collision = true,
	collision_removal = true,
	minexptime = 0.1,
	maxexptime = 0.2,
}


skills.register_skill("fbrawl:acid_spray", {
	name = S("Acid Spray"),
	icon = "fbrawl_acid_spray.png",
	damage = 0.25,
	dmg_multiplier = 1,
	cooldown = 0.2,
	slowing_factor = 1.3,
	range = 7,
	radius = 0.5,
	loop_params = {
		cast_rate = 0.2
	},
	sounds = {
		bgm = {name = "fbrawl_acidspray"}
	},
	data = {
		players_being_hit = {}, -- "name" = true,
		particlesID = 0,
	},
	regen_particles = function(self)
		minetest.delete_particlespawner(self.data.particlesID)

		local new_particles = table.copy(spray_particles)

		-- modifying particles y direction according to the look vertical
		local vertical = self.player:get_look_vertical()
		new_particles.vel.min = vector.rotate_around_axis(new_particles.vel.min, vector.new(1,0,0), -vertical)
		new_particles.vel.max = vector.rotate_around_axis(new_particles.vel.max, vector.new(1,0,0), -vertical)

		new_particles.attached = self.player

		self.data.particlesID = minetest.add_particlespawner(new_particles)
	end,
	on_start = function(self)
		self.data.players_being_hit = {}
		self:regen_particles()
	end,
	cast = function(self)
		local pointed_things = fbrawl.grid_raycast(self.player, self.range, self.radius, 3, true)
		local objs = {}
		local hit_this_frame = {}

		-- insert pointed ObjectRefs in objs
		for i, thing in ipairs(pointed_things) do
			if thing.type == "object" then
				table.insert(objs, thing.ref)
			end
		end

		-- damage players
		for i, obj in ipairs(objs) do
			if obj:is_player() and obj:get_player_name() ~= self.pl_name then
				local pl_name = obj:get_player_name()
				local arena = arena_lib.get_arena_by_player(pl_name)

				if not arena or not arena.match_started then return end

				if pl_name ~= self.pl_name and not hit_this_frame[pl_name] and not arena.players[pl_name].is_invulnerable then
					fbrawl.hit_player(self.player, obj, self.damage * self.dmg_multiplier)

					if not self.data.players_being_hit[pl_name] then
						pl_name:divide_physics("speed", self.slowing_factor)
					end

					hit_this_frame[pl_name] = true
					self.data.players_being_hit[pl_name] = true
				end
			end
		end

		-- removing players not hit this frame from players_being_hit
		for pl_name, _ in pairs(self.data.players_being_hit) do
			if not hit_this_frame[pl_name] then
				self.data.players_being_hit[pl_name] = nil
				pl_name:multiply_physics("speed", self.slowing_factor)
			end
		end

		self:regen_particles()
	end,
	on_stop = function(self)
		for pl_name, _ in pairs(self.data.players_being_hit) do
			pl_name:multiply_physics("speed", self.slowing_factor)
		end
		minetest.delete_particlespawner(self.data.particlesID)
	end
})



controls.register_on_release(function(player, control_name)
	local pl_name = player:get_player_name()
	local acid_spray = pl_name:get_skill("fbrawl:acid_spray")

   if acid_spray and acid_spray.is_active and control_name == "LMB" then
      pl_name:stop_skill("fbrawl:acid_spray")
   end
end)

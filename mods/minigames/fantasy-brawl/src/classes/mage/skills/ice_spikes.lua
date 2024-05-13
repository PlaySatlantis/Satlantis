local S = fbrawl.T



skills.register_skill("fbrawl:ice_spikes", {
   name = S("Ice Spikes"),
	description = S("Creates a wall of ice spikes that damages anyone who walks over it."),
	cooldown = 8,
	spikes = 7,
	icon = "fbrawl_ice_spikes_skill.png",
	can_cast = function (self)
		return fbrawl.is_on_the_ground(self.player)
	end,
	cast = function(self)
		local pitch = 0
		local yaw = self.player:get_look_horizontal()
		local pl_left_dir = vector.new(math.cos(pitch) * math.cos(yaw), math.sin(pitch), math.cos(pitch) * math.sin(yaw))
		
		local look_dir = self.player:get_look_dir()
		look_dir.y = 0

		local spike_base_pos = vector.subtract(self.player:get_pos(), vector.multiply(pl_left_dir, self.spikes/2))
		spike_base_pos = vector.add(spike_base_pos, {x=0, y=-1, z=0})
		spike_base_pos = vector.add(spike_base_pos, vector.multiply(look_dir, 2))

		for i = 0, self.spikes, 1 do
			minetest.after(i*0.1, function ()
				local offset = vector.multiply(pl_left_dir, i)
				local entity1 = minetest.add_entity(vector.add(spike_base_pos, offset), "fantasy_brawl:ice_spikes", self.pl_name)
				local entity2 = minetest.add_entity(vector.add(spike_base_pos, offset), "fantasy_brawl:ice_spikes", self.pl_name)
				
				if not entity1 then return end -- in case the spikes spawned in the air

				entity1:set_rotation({x=0, y=0.7853982, z=0})
				entity2:set_rotation({x=0, y=-0.7853982, z=0})
			end)
		end
   end
})



local ice_spikes = {
   initial_properties = {
      hp_max = 999,
      physical = false,
      collide_with_objects = false,
      visual = "wielditem",
		wield_item = "fantasy_brawl:ice_spikes",
      visual_size = {x = 0.55, y = 0.7, z = 0.01},
   },
   _pl_name = "",
	_time_passed = 0,
	_lifetime = 5,
	_damage = 1.5 / 2,
	_tick_buffer = 0,
	_speed = 9,
	_damage_inflicted = 0,
	_to_remove = false
}



-- staticdata = player's username.
function ice_spikes:on_activate(pl_name, dtime_s)
   local obj = self.object

	if pl_name and fbrawl.are_there_nodes_in_area(obj:get_pos(), 0.5) then
		local sound = {name = "fbrawl_ice_spike_spawn", pos = self.object:get_pos(), max_hear_distance = 8}

		minetest.sound_play(sound, sound, true)

		self._pl_name = pl_name
		self._spike_base = vector.add(self.object:get_pos(), {x=0, y=1.4, z=0})
	else
		obj:remove()
	end
end



function ice_spikes:remove()
   local sound = {name = "fbrawl_ice_break", pos = self.object:get_pos(), max_hear_distance = 8}
	
	self._to_remove = false

   minetest.sound_play(sound, sound, true)

	minetest.add_particlespawner({
		amount = 20,
		time = 0.5,
		pos = {
			min = vector.add(self.object:get_pos(), {x=0.5, y=-0.5, z=0.5}),
			max = vector.add(self.object:get_pos(), {x=-0.5, y=0.5, z=-0.5}),
		},
		velocity = {x=0, y=1, z=0},
		minacc = {x=-6, y=-8, z=-6},
		maxacc = {x=6, y=-8, z=6},
		minsize = 0.8,
		maxsize = 1.3,
		texpool = {"fbrawl_ice_particle.png","fbrawl_ice_particle_2.png"},
		collisiondetection = true,
		object_collision = true,
		collision_removal = true
	})

   self.object:remove()
end



function ice_spikes:on_step(dtime)
   local player = minetest.get_player_by_name(self._pl_name)
	self._time_passed = self._time_passed + dtime
	self._tick_buffer = self._tick_buffer + dtime

	if (not player) or self._to_remove or (self._time_passed >= self._lifetime) then
      self:remove()
      return
   end

	self.object:move_to(self._spike_base, true)
	
	fbrawl.damage_players_near(player, self.object:get_pos(), 1.7, self._damage, nil, function()
		self._to_remove = true
	end)
end



minetest.register_node("fantasy_brawl:ice_spikes", {
	drawtype = "plantlike",
	tiles = {"fbrawl_ice_spike.png"},
	on_drop = function() return end,
	on_use = function(itemstack, player)
		local pl_name = player:get_player_name()
		local bubble_beam = pl_name:get_skill("fbrawl:bubble_beam")
 
		if bubble_beam then
			bubble_beam:cast()
		end
	end
 })



 minetest.register_entity("fantasy_brawl:ice_spikes", ice_spikes)

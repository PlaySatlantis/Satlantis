local function move_towards_center() end
local function move_towards_crush_point() end
local function rotate_randomly() end
local function set_crush_point() end
local function go_towards() end



skills.register_layer("fbrawl:meteors_layer", {
   name = "Meteor Template",
	max_range = 200,

	-- PROPERTIES TO OVERRIDE --
	meteor_texture = "",
	meteor_size = 0,
	meteor_center_offset = {},
	impact_range = 0,
	speed = 0,
	damage = 0,
	when_thrown_speed_multiplier = 0,
	meteors_origin = {
		-- each 3D vector is a meteor spawn point
	},
	waiting_time_before_throwing = 0,
	particle_trail = {},
	particle_crush = {},
	throw_sound = {},
	crush_sound = {},
	knockback = nil,
	----------------------------

	get_meteor_center = function(self)
		local look_dir = self.player:get_look_dir()
		local o = self.meteor_center_offset
		local offset = {x = look_dir.x * o[1], y = o[2], z = look_dir.z * o[3]}
		self.data.meteor_center = self.data.meteor_center or vector.add(offset, self.player:get_pos())

		return self.data.meteor_center
	end,

   cast = function(self)
		self.data.meteor_center = nil
		local entity_data = {
			pl_name = self.pl_name,
			skill_name = self.internal_name,
			hits_mid_air = self.hits_mid_air,
			impact_range = self.impact_range,
			speed = self.speed,
			damage = self.damage,
			when_thrown_speed_multiplier = self.when_thrown_speed_multiplier,
			waiting_time_before_throwing = self.waiting_time_before_throwing,
			texture = self.meteor_texture,
			particle_crush = self.particle_crush,
			particle_trail = self.particle_trail,
			throw_sound = self.throw_sound,
			crush_sound = self.crush_sound,
			meteor_size = self.meteor_size,
			knockback = self.knockback
		}

		for _, pos in ipairs(self.meteors_origin) do
			minetest.add_entity(vector.add(pos, self.player:get_pos()), "fantasy_brawl:meteor", minetest.serialize(entity_data))
		end
   end
})



-- The meteor entity declaration.
local tex = "fbrawl_transparent.png"
local meteor = {
   initial_properties = {
      hp_max = 999,
      physical = false,
      collide_with_objects = false,
      visual = "cube",
      visual_size = {x = 1.9, y = 1.9},
      textures = {tex,tex,tex,tex,tex,tex},
		automatic_face_movement_dir = false,
   },
	_pl_name = "",
	_impact_range = 0,
	_speed = 0,
	_damage = 0,
	_when_thrown_speed_multiplier = 0,
	_waiting_time_before_throwing = 0,
	_particle_crush = {},
	_crush_sound = {},
	_skill_name = "",

	_positioned = false,
	_crush_point = {},
	_time_passed = 0,
}



-- staticdata = player's username.
function meteor:on_activate(staticdata, dtime_s)
   local obj = self.object

   if staticdata and staticdata ~= "" then
		local data = minetest.deserialize(staticdata)

		self._pl_name = data.pl_name
		self._visual_size = data.visual_size
		self._hits_mid_air = data.hits_mid_air
		self._impact_range = data.impact_range
		self._speed = data.speed
		self._damage = data.damage
		self._when_thrown_speed_multiplier = data.when_thrown_speed_multiplier
		self._waiting_time_before_throwing = data.waiting_time_before_throwing
		self._particle_crush = data.particle_crush
		self._crush_sound = data.crush_sound
		self._throw_sound = data.throw_sound
		self._skill_name = data.skill_name
		self._meteor_size = data.meteor_size
		self._knockback = data.knockback or 0

		local player = minetest.get_player_by_name(self._pl_name)
		local skill = self._pl_name:get_skill(data.skill_name)

		local tex = data.texture
		local textures = {tex,tex,tex,tex,tex,tex}
		self.object:set_properties({
			textures = textures,
			visual_size = vector.new(data.meteor_size, data.meteor_size, data.meteor_size)
		})

      if not player or not set_crush_point(self) then
         obj:remove()
         return
      end

		go_towards(self, skill:get_meteor_center(), self._speed)

		data.particle_trail.attached = self.object
		minetest.add_particlespawner(data.particle_trail)
   else
      obj:remove()
      return
   end
end



function meteor:on_step(dtime)
   local player = minetest.get_player_by_name(self._pl_name)

	if not player then
      self.object:remove()
      return
   end

	if not self._positioned then
		move_towards_center(self)
	else
		local is_arrived = move_towards_crush_point(self, dtime)
		local hit = false

		if is_arrived or fbrawl.are_there_nodes_in_area(self.object:get_pos(), 1) then
			self:crush()
			return
		end

		if self._hits_mid_air then
			-- if hits players mid-air then call crush() when colliding
			fbrawl.damage_players_near(player, self.object:get_pos(), self._impact_range, 0, nil, function ()
				hit = true
			end)

			if hit then
				self:crush()
				return
			end
		end
	end

	rotate_randomly(self, dtime)
end



function meteor:crush()
	self._crush_sound.pos = self.object:get_pos()
   local player = minetest.get_player_by_name(self._pl_name)
	local knockback = vector.normalize(self.object:get_velocity()) * self._knockback

   minetest.sound_play(self._crush_sound, self._crush_sound, true)

	self._particle_crush.pos = {
		min = vector.add(self.object:get_pos(), -self._meteor_size),
		max = vector.add(self.object:get_pos(), self._meteor_size),
	}
	minetest.add_particlespawner(self._particle_crush)

	fbrawl.damage_players_near(player, self.object:get_pos(), self._impact_range, self._damage, knockback)

   self.object:remove()
end



minetest.register_entity("fantasy_brawl:meteor", meteor)



function move_towards_center(meteor)
	local skill = meteor._pl_name:get_skill(meteor._skill_name)
	local obj = meteor.object

	local is_positioned = vector.distance(obj:get_pos(), skill:get_meteor_center()) <= 2

	if is_positioned then
		obj:set_velocity({x = 0, y = 0, z = 0})
		meteor._positioned = true

		meteor._throw_sound.pos = obj:get_pos()
		minetest.sound_play(meteor._throw_sound, meteor._throw_sound, true)
	else
		go_towards(meteor, skill:get_meteor_center(), meteor._speed)
	end
end



function move_towards_crush_point(meteor, dtime)
	local obj = meteor.object
	local distance = vector.distance(obj:get_pos(), meteor._crush_point)
	local is_arrived = distance <= 0.8

	if not is_arrived then
		meteor._time_passed = meteor._time_passed + dtime
		if meteor._time_passed < meteor._waiting_time_before_throwing then
			return
		end

		if distance <= meteor._meteor_size*3 then
			meteor._when_thrown_speed_multiplier = fbrawl.interpolate(meteor._when_thrown_speed_multiplier, 0.1, 0.2)
		end

		go_towards(meteor, meteor._crush_point, meteor._speed * meteor._when_thrown_speed_multiplier)
	else
		return "is_arrived"
	end
end



function rotate_randomly(meteor, dtime)
	meteor._rot_speed = meteor._rot_speed or fbrawl.random(1, 1.5)
	meteor.object:set_rotation(vector.add(meteor.object:get_rotation(), meteor._rot_speed * dtime))
end



function set_crush_point(meteor)
	local player = minetest.get_player_by_name(meteor._pl_name)

	local ray = fbrawl.look_raycast(player, 200)
	local crush_point = ray:next() or {}

	if not crush_point.above then
		return false
	end

	meteor._crush_point = crush_point.above

	return true
end



function go_towards(meteor, pos, speed)
	local dir = vector.direction(meteor.object:get_pos(), pos)

	meteor.object:set_velocity({
		x=(dir.x * speed),
		y=(dir.y * speed),
		z=(dir.z * speed),
	})
end
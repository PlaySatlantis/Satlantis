local S = fbrawl.T
local rock_particles = {
	{
		name = "fbrawl_dirt_particle_1.png",
		scale_tween = {{x = 1, y = 1}, {x = 0.5, y = 0.5}}
	},
	{
		name = "fbrawl_dirt_particle_2.png",
		scale_tween = {{x = 1, y = 1}, {x = 0.5, y = 0.5}}
	},
	{
		name = "fbrawl_dirt_particle_3.png",
		scale_tween = {{x = 1, y = 1}, {x = 0.5, y = 0.5}}
	},
	{
		name = "fbrawl_grass_particle_1.png",
		scale_tween = {{x = 1, y = 1}, {x = 0.5, y = 0.5}}
	},
	{
		name = "fbrawl_grass_particle_2.png",
		scale_tween = {{x = 1, y = 1}, {x = 0.5, y = 0.5}}
	},
	{
		name = "fbrawl_grass_particle_3.png",
		scale_tween = {{x = 1, y = 1}, {x = 0.5, y = 0.5}}
	},
	{
		name = "fbrawl_stone_particle.png",
		scale_tween = {{x = 1, y = 1}, {x = 0.5, y = 0.5}}
	},
}



skills.register_skill_based_on("fbrawl:meteors_layer", "fbrawl:gaia_fist", {
   name = S("Gaia's Fist"),
	icon = "fbrawl_gaia_fist.png",
	description = S("Throw a rock against the enemy and push them away!"),
   slot = 3,
	sounds = {cast =  {name = "fbrawl_rock_rising", max_hear_distance = 7}},
	cooldown = 10.5,

	-- PROPERTIES TO OVERRIDE
	meteor_texture = "fbrawl_rock_entity.png",
	meteor_size = 1,
	meteor_center_offset = {3, 3.5, 3},
	hits_mid_air = true,
	impact_range = 3,
	speed = 7,
	damage = 5,
	when_thrown_speed_multiplier = 8,
	meteors_origin = {
		{x=1, y=-2, z=1},
	},
	waiting_time_before_throwing = 0.1,
	particle_trail = {
		amount = 80,
		time = 0,
		minpos = {x = -1, y = 1, z = -1},
		maxpos = {x = 1, y = -1, z = 1},
		minvel = {x = 0, y = -2, z = 0},
		maxvel = {x = 0, y = -4, z = 0},
		minsize = 1,
		maxsize = 3,
		texpool = rock_particles,
		collisiondetection = true,
		collision_removal = true,
		minexptime = 2,
		maxexptime = 3,
	},
	particle_crush = {
		amount = 300,
		time = 0.5,
		minvel = {x = -5,y = -3, z = -5},
		maxvel = {x = 5, y = 3, z = 5},
		minsize = 1,
		maxsize = 4,
		texpool = rock_particles,
		collisiondetection = true,
		collision_removal = true,
		minexptime = 0.5,
		maxexptime = 0.7,
	},
	throw_sound = {name = "fbrawl_meteor_thrown", max_hear_distance = 7},
	crush_sound = {name = "fbrawl_rock_hit", max_hear_distance = 7},
	knockback = 35
})

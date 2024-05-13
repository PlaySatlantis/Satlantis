local S = fbrawl.T
local area_particle_spawner = {
	amount = 1800,
	radius = 10,
	time = 2,
	minsize = 8,
	maxsize = 9,
	glow = 12,
	texture = {
		 name = "fbrawl_fire_particle.png",
		 alpha_tween = {1, 0},
		 scale_tween = {
			  {x = 1, y = 1},
			  {x = 0, y = 0},
		 },
		 animation = {
			  type = "vertical_frames",
			  aspect_w = 16, aspect_h = 16,
			  length = 0.1,
		 },
	},
	minexptime = 0.3,
	maxexptime = 0.3,
}



skills.register_skill_based_on(
	{"fbrawl:ulti_layer", "fbrawl:proxy_layer", "fbrawl:meteors_layer"}, "fbrawl:cry_of_gaia",
	{
   name = S("Cry of Gaia"),
	description = S("Unleash Gaia's fury: throws a meteor shower wherever you're looking at, damaging all enemies in that area."),
	icon = "fbrawl_cry_of_gaia_skill.png",
   slot = 4,
	sounds = {cast =  {name = "fbrawl_meteor_rising", max_hear_distance = 46}},

	-- proxied_template: PROPERTIES TO OVERRIDE
	proxy = {
		name = "fbrawl:aoe_proxy",
		args = {
         item = "fantasy_brawl:cry_of_gaia",
         broadcast = S("Click to unleash a meteor storm"),
			max_range = 200,
			particlespawner = area_particle_spawner,
			pointer_texture = "fbrawl_smash_item.png"
      }
	},

	-- meteors_template: PROPERTIES TO OVERRIDE
	meteor_texture = "fbrawl_meteor_entity.png",
	meteor_size = 2,
	meteor_center_offset = {7, 14, 7},
	impact_range = 10,
	speed = 20,
	damage = 10,
	when_thrown_speed_multiplier = 5,
	meteors_origin = {
		{x=6, y=-2, z=0},
		{x=-6, y=-2, z=0},
		{x=0, y=-2, z=-6},
		{x=0, y=-2, z=6},
		{x=0, y=-2, z=-6},
		{x=6, y=-2, z=6},
		{x=-6, y=-2, z=-6}
	},
	waiting_time_before_throwing = 0.5,
	particle_trail = {
		amount = 320,
		time = 0,
		minpos = {x = -2, y = 2, z = -2},
		maxpos = {x = 2, y = -2, z = 2},
		minvel = {x = 0, y = -0.2, z = 0},
		maxvel = {x = 0, y = 0.2, z = 0},
		minsize = 4,
		maxsize = 9,
		glow = 12,
		texture = {
			name = "fbrawl_fire_particle.png",
			alpha_tween = {1, 0},
			scale_tween = {
				{x = 1, y = 1},
				{x = 0, y = 0},
			},
			animation = {
				type = "vertical_frames",
				aspect_w = 16, aspect_h = 16,
				length = 0.3,
			},
		},
		minexptime = 1.5,
		maxexptime = 2,
	},
	particle_crush = {
		amount = 300,
		time = 0.5,
		minvel = {x = -10,y = -6, z = -10},
		maxvel = {x = 10, y = 6, z = 10},
		minsize = 10,
		maxsize = 16,
		texture = {
			name = "fbrawl_fire_particle.png",
			alpha_tween = {1, 0},
			scale_tween = {
				{x = 1, y = 1},
				{x = 0, y = 0},
			},
			animation = {
				type = "vertical_frames",
				aspect_w = 16, aspect_h = 16,
				length = 0.3,
			},
	  	},
		glow = 12,
		minexptime = 2,
		maxexptime = 3,
	},
	throw_sound = {name = "fbrawl_meteor_thrown", max_hear_distance = 46},
	crush_sound = {name = "fbrawl_meteor_hit", max_hear_distance = 46},
})

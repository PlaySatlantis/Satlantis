satlantis.register_block("geo:sand", {
	description = "Sand",
	tiles = {"sand.png"},
	groups = {crumbly = 3, falling_node = 1, sand = 1},
})

satlantis.register_block("geo:sandstone", {
	description = "Sandstone",
	tiles = {"sandstone.png"},
	groups = {crumbly = 1, cracky = 3},
})

satlantis.register_block("geo:sandstone_bricks", {
	description = "Sandstone Bricks",
	tiles = {"sandstone_bricks.png"},
	paramtype2 = "facedir",
	place_param2 = 0,
	is_ground_content = false,
	groups = {cracky = 2},
})

satlantis.register_block("geo:sandstone_smooth", {
	description = "Smooth Sandstone",
	tiles = {"sandstone_smooth.png"},
	is_ground_content = false,
	groups = {cracky = 2},
})

satlantis.register_block("geo:red_sand", {
	description = "Red Sand",
	tiles = {"red_sand.png"},
	groups = {crumbly = 3, falling_node = 1, sand = 1},
})

satlantis.register_block("geo:red_sandstone", {
	description = "Red Sandstone",
	tiles = {"red_sandstone.png"},
	groups = {crumbly = 1, cracky = 3},
})

satlantis.register_block("geo:red_sandstone_bricks", {
	description = "Red Sandstone Bricks",
	tiles = {"red_sandstone_bricks.png"},
	paramtype2 = "facedir",
	place_param2 = 0,
	is_ground_content = false,
	groups = {cracky = 2},
})

satlantis.register_block("geo:red_sandstone_smooth", {
	description = "Smooth Red Sandstone",
	tiles = {"red_sandstone_smooth.png"},
	is_ground_content = false,
	groups = {cracky = 2},
})

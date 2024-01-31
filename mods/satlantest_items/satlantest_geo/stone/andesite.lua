minetest.register_alias("geo:stone", "geo:andesite")
minetest.register_alias("geo:stone_cobble", "geo:andesite_cobble")
minetest.register_alias("geo:stone_bricks", "geo:andesite_bricks")
minetest.register_alias("geo:stone_bricks_mossy", "geo:andesite_bricks_mossy")
minetest.register_alias("geo:stone_smooth", "geo:andesite_smooth")
minetest.register_alias("geo:stone_cobble_mossy", "geo:andesite_cobble_mossy")

satlantis.register_block("geo:andesite", {
	description = "Stone",
	tiles = {"stone.png"},
	groups = {cracky = 3, stone = 1},
	drop = "geo:stone_cobble",
})

satlantis.register_block("geo:andesite_cobble", {
	description = "Stone Cobble",
	tiles = {"stone_cobble.png"},
	is_ground_content = false,
	groups = {cracky = 3, stone = 2},
})

satlantis.register_block("geo:andesite_bricks", {
	description = "Stone Bricks",
	paramtype2 = "facedir",
	place_param2 = 0,
	tiles = {"stone_bricks.png"},
	is_ground_content = false,
	groups = {cracky = 2, stone = 1},
})

satlantis.register_block("geo:andesite_bricks_mossy", {
	description = "Mossy Stone Bricks",
	paramtype2 = "facedir",
	place_param2 = 0,
	tiles = {"stone_bricks_mossy.png"},
	is_ground_content = false,
	groups = {cracky = 3, stone = 1},
})

satlantis.register_block("geo:andesite_smooth", {
	description = "Smooth Stone",
	tiles = {"stone_smooth.png"},
	is_ground_content = false,
	groups = {cracky = 2, stone = 1},
})

satlantis.register_block("geo:andesite_cobble_mossy", {
	description = "Mossy Stone Cobble",
	tiles = {"stone_cobble_mossy.png"},
	is_ground_content = false,
	groups = {cracky = 3, stone = 1},
})


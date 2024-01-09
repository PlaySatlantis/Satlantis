satlantis.register_block("geo:dirt", {
	description = "Dirt",
	tiles = {"dirt.png"},
	groups = {crumbly = 3, soil = 1},
})

satlantis.register_block("geo:dirt_grassy", {
	description = "Grassy Dirt",
	tiles = {
        "grass_block_tint.png", "dirt.png",
        {name = "grass_block_side.png", tileable_vertical = false}
    },
	groups = {crumbly = 3, soil = 1, spreading_dirt_type = 1},
	drop = "geo:dirt",
})

satlantis.register_block("geo:dirt_snowy", {
	description = "Snowy Dirt",
	tiles = {
        "snow.png", "dirt.png",
		{name = "grass_block_snow.png", tileable_vertical = false}
    },
	groups = {crumbly = 3, soil = 1, spreading_dirt_type = 1, snowy = 1},
	drop = "geo:dirt",
})

satlantis.register_block("geo:clay", {
	description = "Clay",
	tiles = {"clay.png"},
	groups = {crumbly = 3},
	drop = "geo:clay_lump 4",
})

satlantis.register_item("geo:clay_lump", {
	description = "Clay Lump",
	inventory_image = "clay_lump.png",
})

satlantis.register_item("geo:clay_brick", {
	description = "Clay Brick",
	inventory_image = "clay_brick.png",
})

satlantis.register_block("geo:clay_brick_block", {
	description = "Clay Brick Block",
	paramtype2 = "facedir",
	place_param2 = 0,
	tiles = {
		"clay_brick_block.png^[transformFX",
		"clay_brick_block.png",
	},
	is_ground_content = false,
	groups = {cracky = 3},
})

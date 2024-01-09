satlantis.register_block("geo:iron_ore", {
	description = "Iron Ore",
	tiles = {"stone.png^iron_ore.png"},
	groups = {cracky = 2},
	drop = "geo:iron_lump",
})

satlantis.register_item("geo:iron_lump", {
	description = "Iron Lump",
	inventory_image = "iron_lump.png"
})

satlantis.register_item("geo:iron_ingot", {
	description = "Iron Ingot",
	inventory_image = "iron_ingot.png"
})

satlantis.register_block("geo:iron_block", {
	description = "Iron Block",
	tiles = {"iron_block.png"},
	is_ground_content = false,
	groups = {cracky = 1, level = 2},
})

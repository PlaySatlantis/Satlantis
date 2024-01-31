satlantis.register_block("geo:copper_ore", {
	description = "Copper Ore",
	tiles = {"stone.png^copper_ore.png"},
	groups = {cracky = 2},
	-- drop = "geo:copper_lump",
})

satlantis.register_item("geo:copper_lump", {
	description = "Copper Lump",
	inventory_image = "copper_lump.png"
})

satlantis.register_item("geo:copper_ingot", {
	description = "Copper Ingot",
	inventory_image = "copper_ingot.png"
})

satlantis.register_block("geo:copper_block", {
	description = "Copper Block",
	tiles = {"copper_block.png"},
	is_ground_content = false,
	groups = {cracky = 1, level = 2},
})

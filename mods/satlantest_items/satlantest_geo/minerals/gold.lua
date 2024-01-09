satlantis.register_block("geo:gold_ore", {
	description = "Gold Ore",
	tiles = {"stone.png^gold_ore.png"},
	groups = {cracky = 2},
	drop = "geo:gold_lump",
})

satlantis.register_item("geo:gold_lump", {
	description = "Gold Lump",
	inventory_image = "gold_lump.png"
})

satlantis.register_item("geo:gold_ingot", {
	description = "Gold Ingot",
	inventory_image = "gold_ingot.png"
})

satlantis.register_block("geo:gold_block", {
	description = "Gold Block",
	tiles = {"gold_block.png"},
	is_ground_content = false,
	groups = {cracky = 1},
})

satlantis.register_block("geo:diamond_ore", {
	description = "Diamond Ore",
	tiles = {"stone.png^diamond_ore.png"},
	groups = {cracky = 1},
	drop = "geo:diamond",
})

satlantis.register_item("geo:diamond", {
	description = "Diamond",
	inventory_image = "diamond.png",
})

satlantis.register_block("geo:diamond_block", {
	description = "Diamond Block",
	tiles = {"diamond_block.png"},
	is_ground_content = false,
	groups = {cracky = 1, level = 3},
})

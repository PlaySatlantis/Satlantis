satlantis.register_block("geo:coal_ore", {
	description = "Coal Ore",
	tiles = {"stone.png^coal_ore.png"},
	groups = {cracky = 3},
	drop = "geo:coal_lump",
})

satlantis.register_block("geo:coal_block", {
	description = "Coal Block",
	tiles = {"coal_block.png"},
	is_ground_content = false,
	groups = {cracky = 3},
})

satlantis.register_item("geo:coal_lump", {
	description = "Coal Lump",
	inventory_image = "coal_lump.png",
	groups = {coal = 1, flammable = 1}
})

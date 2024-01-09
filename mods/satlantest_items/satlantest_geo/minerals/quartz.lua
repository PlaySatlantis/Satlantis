satlantis.register_block("quartz:quartz_ore", {
	description = "Quartz Ore",
	tiles = {"stone.png^quartz_ore.png"},
	groups = {cracky=3, stone=1},
	drop = "quartz:quartz_crystal",
})

satlantis.register_item("quartz:quartz_crystal", {
	description = "Quartz Crystal",
	inventory_image = "quartz_crystal.png",
})

satlantis.register_block("quartz:block", {
	description = "Quartz Block",
	tiles = {"quartz_block.png"},
	groups = {cracky=3, oddly_breakable_by_hand=1},
})

satlantis.register_block("quartz:chiseled", {
	description = "Chiseled Quartz Block",
	tiles = {"quartz_block_chiseled.png"},
	groups = {cracky=3, oddly_breakable_by_hand=1},
})

satlantis.register_block("quartz:pillar", {
	description = "Quartz Pillar",
	paramtype2 = "facedir",
	tiles = {"quartz_pillar_top.png", "quartz_pillar_top.png", "quartz_pillar_side.png"},
	groups = {cracky=3, oddly_breakable_by_hand=1},
	on_place = minetest.rotate_node
})

minetest.register_ore({
	ore_type = "scatter",
	ore = "quartz:quartz_ore",
	wherein = "default:stone",
	clust_scarcity = 10*10*10,
	clust_num_ores = 6,
	clust_size = 5,
	y_min = -31000,
	y_max = -5,
})

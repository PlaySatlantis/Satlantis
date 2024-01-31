satlantis.register_block("flora:grass", {
	description = "Grass",
	drawtype = "plantlike",
	waving = 1,
	tiles = {"grass.png"},
	inventory_image = "grass.png",
	wield_image = "grass.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
    drop = {
		max_items = 1,
		items = {
			{items = {"flora:wheat_seeds"}, rarity = 5},
			{items = {"flora:grass"}},
		}
	},
	groups = {snappy = 3, flora = 1, attached_node = 1, grass = 1,
		normal_grass = 1, flammable = 1},
	selection_box = {
		type = "fixed",
		fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, -5 / 16, 6 / 16},
	},
})

satlantis.register_block("flora:cactus", {
	description = "Cactus",
	tiles = {"cactus_top.png", "cactus_bottom.png",
		"cactus_side.png"},
	paramtype2 = "facedir",
	groups = {choppy = 3},
	on_place = minetest.rotate_node,
})

satlantis.register_block("flora:papyrus", {
	description = "Papyrus",
	drawtype = "plantlike",
	tiles = {"papyrus.png"},
	inventory_image = "papyrus.png",
	wield_image = "papyrus.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, 0.5, 6 / 16},
	},
	groups = {snappy = 3, flammable = 2},

	after_dig_node = function(pos, node, _, digger)
        if digger == nil then return end
        local np = {x = pos.x, y = pos.y + 1, z = pos.z}
        local nn = minetest.get_node(np)
        if nn.name == node.name then
            minetest.node_dig(np, nn, digger)
        end
	end,
})

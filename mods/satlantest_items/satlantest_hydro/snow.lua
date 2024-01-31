satlantis.register_block("hydro:snow", {
	description = "Snow",
	tiles = {"snow.png"},
	inventory_image = "snow_ball.png",
	wield_image = "snow_ball.png",
	paramtype = "light",
	buildable_to = true,
	floodable = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.25, 0.5},
		},
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -6 / 16, 0.5},
		},
	},
	groups = {crumbly = 3, falling_node = 1, snowy = 1},
	on_construct = function(pos)
		pos.y = pos.y - 1
		if minetest.get_node(pos).name == "geo:grassy_dirt" then
			minetest.set_node(pos, {name = "geo:snowy_dirt"})
		end
	end,
})

satlantis.register_block("hydro:snow_block", {
	description = "Snow Block",
	tiles = {"snow.png"},
	groups = {crumbly = 3, cools_lava = 1, snowy = 1},
	on_construct = function(pos)
		pos.y = pos.y - 1
		if minetest.get_node(pos).name == "geo:grassy_dirt" then
			minetest.set_node(pos, {name = "geo:snowy_dirt"})
		end
	end,
})

satlantis.register_block("hydro:ice", {
	description = "Ice",
	tiles = {"ice.png"},
	is_ground_content = false,
	paramtype = "light",
	groups = {cracky = 3, cools_lava = 1, slippery = 3},
})

satlantis.register_block("hydro:cave_ice", {
	description = "Ice",
	tiles = {"ice.png"},
	is_ground_content = true,
	paramtype = "light",
    drop = "hydro:ice",
	groups = {cracky = 3, cools_lava = 1, slippery = 3},
})

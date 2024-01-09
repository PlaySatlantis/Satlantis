satlantis.require("glass/panes.lua")
satlantis.require("glass/colors.lua")

satlantis.register_block("geo:glass", {
	description = "Glass",
	drawtype = "glasslike_framed_optional",
	tiles = {"glass.png"},
	use_texture_alpha = "clip",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
})

satlantis.panes.register_pane("glass", {
	description = "Glass Pane",
	textures = {"glass.png", "", "glass_pane_top.png"},
	inventory_image = "glass.png",
	wield_image = "glass.png",
	groups = {snappy=2, cracky=3, oddly_breakable_by_hand=3},
	recipe = {
		{"geo:glass", "geo:glass", "geo:glass"},
		{"geo:glass", "geo:glass", "geo:glass"}
	}
})

satlantis.panes.register_pane("bar", {
	description = "Iron Bars",
	textures = {"iron_bars.png", "", "blank.png"},
	inventory_image = "iron_bars.png",
	wield_image = "iron_bars.png",
	groups = {cracky=2},
	recipe = {
		{"geo:iron_ingot", "geo:iron_ingot", "geo:iron_ingot"},
		{"geo:iron_ingot", "geo:iron_ingot", "geo:iron_ingot"}
	}
})

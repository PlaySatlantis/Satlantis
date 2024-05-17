local S = fbrawl.T

minetest.register_node("fantasy_brawl:book_pedestal", {
	drawtype = "mesh",
	mesh = "fbrawl_book_pedestal.obj",
	tiles = {"fbrawl_book_pedestal.png"},
	visual_scale = 1.4,
	selection_box = {
		type = "fixed",
		fixed  = {-0.3, -0.5, -0.3, 0.3, 0.12, 0.3}
	},
	use_texture_alpha = "clip",
	groups = {crumbly=1, soil=1, oddly_breakable_by_hand=1},
	paramtype2 = "facedir",
	description = S("Fantasy Brawl Class Selector"),
	on_punch = function (pos, node, puncher)
		fbrawl.show_class_selector(puncher:get_player_name())
	end,
	on_rightclick = function (pos, node, clicker)
		fbrawl.show_class_selector(clicker:get_player_name())
	end
})
-- Borrowed from Minetest Game
satlantis.walls.register_fence = function(name, def)
	local default_fields = {
		paramtype = "light",
		drawtype = "nodebox",
		node_box = {
			type = "connected",
			fixed = {-1/8, -1/2, -1/8, 1/8, 1/2, 1/8},
			connect_front = {{-1/16,  3/16, -1/2,   1/16,  5/16, -1/8 }, {-1/16, -5/16, -1/2,   1/16, -3/16, -1/8 }},
			connect_left =  {{-1/2,   3/16, -1/16, -1/8,   5/16,  1/16}, {-1/2,  -5/16, -1/16, -1/8,  -3/16,  1/16}},
			connect_back =  {{-1/16,  3/16,  1/8,   1/16,  5/16,  1/2 }, {-1/16, -5/16,  1/8,   1/16, -3/16,  1/2 }},
			connect_right = {{ 1/8,   3/16, -1/16,  1/2,   5/16,  1/16}, { 1/8,  -5/16, -1/16,  1/2,  -3/16,  1/16}}
		},
		collision_box = {
			type = "connected",
			fixed = {-1/8, -1/2, -1/8, 1/8, 1, 1/8},
			connect_front = {-1/8, -1/2, -1/2,  1/8, 1, -1/8},
			connect_left =  {-1/2, -1/2, -1/8, -1/8, 1,  1/8},
			connect_back =  {-1/8, -1/2,  1/8,  1/8, 1,  1/2},
			connect_right = { 1/8, -1/2, -1/8,  1/2, 1,  1/8}
		},
		connects_to = {"group:fence", "group:wall", "group:solid"},
		-- inventory_image = fence_texture,
		-- wield_image = fence_texture,
		tiles = def.tiles,
		sunlight_propagates = true,
		is_ground_content = false,
		groups = {},
	}

	for k, v in pairs(default_fields) do
		if def[k] == nil then
			def[k] = v
		end
	end

	def.groups.fence = 1

	satlantis.register_block("fence:" .. name, def)
end

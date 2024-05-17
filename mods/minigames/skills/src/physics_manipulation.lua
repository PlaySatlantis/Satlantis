local string_metatable = getmetatable("")



function skills.add_physics(pl_name, property, value)
	local player = minetest.get_player_by_name(pl_name)
	local physics_override = player:get_physics_override()
	physics_override[property] = physics_override[property] + value

	player:set_physics_override(physics_override)
end
string_metatable.__index["add_physics"] = skills.add_physics



function skills.sub_physics(pl_name, property, value)
	skills.add_physics(pl_name, property, -value)
end
string_metatable.__index["sub_physics"] = skills.sub_physics



function skills.multiply_physics(pl_name, property, value)
	local player = minetest.get_player_by_name(pl_name)
	local physics_override = player:get_physics_override()
	physics_override[property] = physics_override[property] * value

	player:set_physics_override(physics_override)
end
string_metatable.__index["multiply_physics"] = skills.multiply_physics



function skills.divide_physics(pl_name, property, value)
	local player = minetest.get_player_by_name(pl_name)
	local physics_override = player:get_physics_override()
	physics_override[property] = physics_override[property] / value

	player:set_physics_override(physics_override)
end
string_metatable.__index["divide_physics"] = skills.divide_physics
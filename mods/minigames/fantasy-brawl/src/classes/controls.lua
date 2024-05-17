local function cast_skill(arena, pl_name, key) end
local function detect_input(pl, control) end


-- mouse and ultimate controls
controls.register_on_hold(function(player, control_name)
	detect_input(player, control_name)
end)



controls.register_on_press(function(player, control_name)
	detect_input(player, control_name)
end)



-- def = {skill_1/2, mesh, texture, wield_scale, groups, tool_capabilities}
-- skill1/2?
function fbrawl.register_weapon(name, def)
	minetest.register_node(name, {
		drawtype = "mesh",
		mesh = def.mesh,
		tiles = {def.texture},
		inventory_image = "fbrawl_transparent.png",
		groups = def.groups,
		wield_scale = def.wield_scale,
		tool_capabilities = def.tool_capabilities or {},
		node_placement_prediction = "",
		use_texture_alpha = "clip",

		on_drop = function(itemstack, player)
			local pl_name = player:get_player_name()

			if fbrawl.is_player_playing(pl_name) then
				local arena = arena_lib.get_arena_by_player(pl_name)
				cast_skill(arena, pl_name, "Q")
			end

			return
		end
	})
end



function cast_skill(arena, pl_name, key)
	local skill_name = arena.classes[pl_name].skills[key]
	local skill = pl_name:get_skill(skill_name)

	if not skill["can_cast"] or skill:can_cast() then
		if skill.loop_params then
			skill:start()
		else
			skill:cast()
		end
	end
end



function detect_input(player, control_name)
	local pl_name = player:get_player_name()
	local arena = arena_lib.get_arena_by_player(pl_name)

	if not fbrawl.is_player_playing(pl_name) then
		return
	end

	if control_name == "LMB" then
		cast_skill(arena, pl_name, "LMB")

	elseif control_name == "RMB" then
		cast_skill(arena, pl_name, "RMB")

	elseif control_name == "sneak" then
		cast_skill(arena, pl_name, "SNEAK")

	elseif control_name == "zoom" then
		cast_skill(arena, pl_name, "ZOOM")
	end
end
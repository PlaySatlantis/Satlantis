function fbrawl.generate_timer_HUD(pl_name)
	local player = minetest.get_player_by_name(pl_name)

	local pos_x = 0.437
	local pos_y = 0
	local scale = 3.5
	local background_width = 32*scale

	local timer_bg = player:hud_add({
		hud_elem_type = "image",
		position  = {x = pos_x, y = pos_y},
		offset = {x = background_width/2, y = 50},
		text      = "fbrawl_hud_timer.png",
		alignment = {x = 1.0},
		scale     = {x = scale, y = scale},
		number    = 0xdff6f5,
	})
	local timer_text = player:hud_add({
		hud_elem_type = "text",
		position  = {x = pos_x, y = pos_y},
		offset = {x = background_width/2 + 37, y = 50+3},
		text      = "-",
		alignment = {x = 0},
		scale     = {x = 100, y = 100},
		number    = 0xdff6f5,
	})

	fbrawl.saved_huds[pl_name] = skills.override_params(fbrawl.saved_huds[pl_name], {
		timer_bg = timer_bg,
		timer = timer_text,
	})
end



function fbrawl.update_timer_hud(arena)
	for pl_name in pairs(arena.players_and_spectators) do
		local player = minetest.get_player_by_name(pl_name)
		player:hud_change(fbrawl.saved_huds[pl_name].timer, "text", arena.current_time)
	end
end


function fbrawl.generate_scoreboard(pl_name)
	local imgs_scale = 4

	local pl_name_y_offset = 80

	local crown_x_offset = 16*imgs_scale + 300 
	local crown_y_offset = 16*imgs_scale

	local scores_scale = imgs_scale - 1
	local score_x_offset = 14*scores_scale + 8
	local score_y_offset = 18*scores_scale + pl_name_y_offset
	local score_value_y_offset = 14
	local score_value_x_offset = 16

	local panel = Panel:new("fbrawl:podium", {
		player = pl_name,
		position = {x=0.5, y=0.15},
		alignment = {x=0, y=0.5},
		bg_scale = {x = 1000, y = 1000},

		-- IMAGES
		sub_img_elems = {
			iron_crown = {
				scale = {x = imgs_scale, y = imgs_scale},
				offset = {x = -crown_x_offset, y = crown_y_offset},
				text = "fbrawl_iron_crown.png",
			},
			iron_kills = {
				scale = {x = scores_scale, y = scores_scale},
				offset = {x = -crown_x_offset - score_x_offset, y = crown_y_offset + score_y_offset},
				text = "fbrawl_hud_kills_score.png",
			},
			iron_deaths = {
				scale = {x = scores_scale, y = scores_scale},
				offset = {x = -crown_x_offset + score_x_offset, y = crown_y_offset + score_y_offset},
				text = "fbrawl_hud_deaths_score.png",
			},

			golden_crown = {
				scale = {x = imgs_scale, y = imgs_scale},
				offset = {x = 0, y = 0},
				text = "fbrawl_golden_crown.png"
			},
			golden_kills = {
				scale = {x = scores_scale, y = scores_scale},
				offset = {x = -score_x_offset, y = score_y_offset},
				text = "fbrawl_hud_kills_score.png",
			},
			golden_deaths = {
				scale = {x = scores_scale, y = scores_scale},
				offset = {x = score_x_offset, y = score_y_offset},
				text = "fbrawl_hud_deaths_score.png",
			},

			bronze_crown = {
				scale = {x = imgs_scale, y = imgs_scale},
				offset = {x = crown_x_offset, y = crown_y_offset},
				text = "fbrawl_bronze_crown.png"
			},
			bronze_kills = {
				scale = {x = scores_scale, y = scores_scale},
				offset = {x = crown_x_offset - score_x_offset, y = crown_y_offset + score_y_offset},
				text = "fbrawl_hud_kills_score.png",
			},
			bronze_deaths = {
				scale = {x = scores_scale, y = scores_scale},
				offset = {x = crown_x_offset + score_x_offset, y = crown_y_offset + score_y_offset},
				text = "fbrawl_hud_deaths_score.png",
			},
		},

		-- TEXTS
		sub_txt_elems = {
			iron_pl_name = {
				offset = {x = -crown_x_offset, y = crown_y_offset + pl_name_y_offset},
				text = "-",
				size = {x=2}
			},
			iron_kills_value = {
				offset = {x = -crown_x_offset - score_x_offset + score_value_x_offset, y = crown_y_offset + score_y_offset + score_value_y_offset},
				text = "-",
			},
			iron_deaths_value = {
				offset = {x = -crown_x_offset + score_x_offset - score_value_x_offset, y = crown_y_offset + score_y_offset + score_value_y_offset},
				text = "-",
			},

			golden_pl_name = {
				offset = {x = 0, y = pl_name_y_offset},
				text = "-",
				size = {x=2}
			},
			golden_kills_value = {
				offset = {x = -score_x_offset + score_value_x_offset, y = score_y_offset + score_value_y_offset},
				text = "-",
			},
			golden_deaths_value = {
				offset = {x = score_x_offset - score_value_x_offset, y = score_y_offset + score_value_y_offset},
				text = "-",
			},

			bronze_pl_name = {
				offset = {x = crown_x_offset, y = crown_y_offset + pl_name_y_offset},
				text = "-",
				size = {x=2}
			},
			bronze_kills_value = {
				offset = {x = crown_x_offset - score_x_offset + score_value_x_offset, y = crown_y_offset + score_y_offset + score_value_y_offset},
				text = "-",
			},
			bronze_deaths_value = {
				offset = {x = crown_x_offset + score_x_offset - score_value_x_offset, y = crown_y_offset + score_y_offset + score_value_y_offset},
				text = "-",
			},
		}
	})
	panel:hide()
end
 

function fbrawl.show_podium_HUD(pl_name)
	if not panel_lib.has_panel(pl_name, "fbrawl:podium") then return end

	local panel = panel_lib.get_panel(pl_name, "fbrawl:podium")  

	fbrawl.update_score_hud(pl_name)
	panel:show()
end



controls.register_on_press(function(player, control_name)
	local pl_name = player:get_player_name()
	local mod = arena_lib.get_mod_by_player(pl_name)
	local arena = arena_lib.get_arena_by_player(pl_name)

	if mod == "fantasy_brawl" and arena.in_game and control_name == "aux1" then
   	fbrawl.show_podium_HUD(pl_name)
	end
end)



controls.register_on_release(function(player, control_name)
	local pl_name = player:get_player_name()
	local mod = arena_lib.get_mod_by_player(pl_name)
	local arena = arena_lib.get_arena_by_player(pl_name)

	if 
   	mod == "fantasy_brawl" and arena.in_game 
   	and not arena.in_celebration and control_name == "aux1" 
	then
		if not panel_lib.has_panel(pl_name, "fbrawl:podium")  then return end
		local panel = panel_lib.get_panel(pl_name, "fbrawl:podium")
		panel:hide()
	end
end)

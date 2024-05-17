local S = fbrawl.T



function fbrawl.generate_controls_hud(arena, pl_name)
	local player = minetest.get_player_by_name(pl_name)

	if not player or not arena_lib.is_player_in_arena(pl_name) then
		if player then hud_fs.close_hud(player, "fantasy_brawl:controls") end
		return false
	end

	local class = arena.classes[pl_name]
	local skill_RMB = pl_name:get_skill(class.skills.RMB)
	local skill_LMB = pl_name:get_skill(class.skills.LMB)
	local skill_Q = pl_name:get_skill(class.skills.Q)
	local skill_ZOOM = pl_name:get_skill(class.skills.ZOOM)
	local skill_SNEAK = pl_name:get_skill(class.skills.SNEAK)

	local skills_order = {skill_SNEAK, skill_Q, skill_LMB, skill_RMB}

	local function get_overlay(skill)
		local black_overlay = "fbrawl_hud_skill_dark_overlay.png"

		-- ultimate overlay
		if skill.internal_name == skill_ZOOM.internal_name then
			if arena.players[pl_name].ultimate_recharge >= fbrawl.min_kills_to_use_ultimate then
				return "fbrawl_transparent.png"
			else
				return "fbrawl_hud_ulti_dark_overlay.png"
			end
		end

		-- normal skill overlay
		if skill.cooldown_timer <= 0 then
			return "fbrawl_transparent.png"
		else 
			return black_overlay
		end
	end
	local function get_key_overlay(skill)
		local dark_overlay = "^[colorize:#302c2e:175"

		-- ultimate overlay
		if skill.internal_name == skill_ZOOM.internal_name then
			if arena.players[pl_name].ultimate_recharge >= fbrawl.min_kills_to_use_ultimate then
				return ""
			else
				return "^[colorize:#302c2e:120"
			end
		end

		local cd = skill.cooldown_timer
		if cd > 0 then
			return dark_overlay
		else
			return ""
		end
	end
	local function get_cooldown(skill)
		-- ultimate cooldown
		if skill.internal_name == skill_ZOOM.internal_name then
			if arena.players[pl_name].ultimate_recharge < fbrawl.min_kills_to_use_ultimate then
				return arena.players[pl_name].ultimate_recharge .. "/" .. fbrawl.min_kills_to_use_ultimate
			else
				return ""
			end
		end

		-- normal cooldown
		if skill.cooldown_timer > 0 then
			return math.floor(skill.cooldown_timer+0.5) .. "s"
		else
			return ""
		end
	end
	local function scale_hp_to_16()
		local function round(v)
			if 0 < v and v < 1 then return 1 end
			return math.floor(v + 0.5)
		end
		local current = player["get_hp"](player)
		local max_display = math.max(player:get_properties()["hp_max"], current)
		return round(current / max_display * 16)
	end

	
	--[[
		FORMSPEC

		formspec_version[3]
		size[10,4]
		position[0.299,0.92]
		no_prepend[]
		bgcolor[#FF00FF00]

		style[mid_label;border=false;font_size=*2]
		style[big_label;border=false;font_size=*3]
		style[small_label;border=false;font_size=*1]

		image[5.9,1.5;1.25,1.25;fbrawl_hud_skill_slot.png;]
		image[7.5,1.5;1.25,1.25;fbrawl_hud_skill_slot.png;]
		image[12,1.5;1.25,1.25;fbrawl_hud_skill_slot.png;]
		image[13.6,1.5;1.25,1.25;fbrawl_hud_skill_slot.png;]
		image[9.25,0.5;2.25,2.25;fbrawl_hud_ulti_slot.png;]

		"image[6.15,1.75;0.75,0.75;" .. skills_order[1].icon .. ";]"..
		"image[7.75,1.75;0.75,0.75;" .. skills_order[2].icon .. ";]"..
		"image[12.25,1.75;0.75,0.75;" .. skills_order[3].icon .. ";]"..
		"image[13.85,1.75;0.75,0.75;" .. skills_order[4].icon .. ";]"..
		"image[9.63,0.86;1.5,1.5;" .. skill_ZOOM.icon .. ";]"..

		"image[5.9,1.5;1.25,1.25;" .. get_overlay(skills_order[1]) .. "]" ..
		"image[7.5,1.5;1.25,1.25;" .. get_overlay(skills_order[2]) .. "]" ..
		"image[12,1.5;1.25,1.25;" .. get_overlay(skills_order[3]) .. "]" ..
		"image[13.6,1.5;1.25,1.25;" .. get_overlay(skills_order[4]) .. "]" ..
		"image[9.311,0.55;2.15,2.15;" .. get_overlay(skill_ZOOM) .. "]" ..

		"image_button[6.08,1.7;1,1;fbrawl_transparent.png;mid_label;" .. get_cooldown(skills_order[1]) .. "]" ..
		"image_button[7.68,1.7;1,1;fbrawl_transparent.png;mid_label;" .. get_cooldown(skills_order[2]) .. "]" ..
		"image_button[12.18,1.65;1,1;fbrawl_transparent.png;mid_label;" .. get_cooldown(skills_order[3]) .. "]" ..
		"image_button[13.78,1.65;1,1;fbrawl_transparent.png;mid_label;" .. get_cooldown(skills_order[4]) .. "]" ..
		"image_button[9.93,0.95;1,1;fbrawl_transparent.png;big_label;" .. get_cooldown(skill_ZOOM) .. "]"

		local kills = get_cooldown(skill_ZOOM) == "" and "" or minetest.colorize("#cfc6b8", S("Kills"))
		formspec = formspec ..
		"image_button[9.91,1.45;1,1;fbrawl_transparent.png;small_label;" .. kills .. "]" ..

		"image[5.68,2.29;0.8125,0.65;fbrawl_hud_btnSHIFT.png".. get_key_overlay(skills_order[1]) .. ";]" ..
		"image[7.28,2.29;0.65,0.65;fbrawl_hud_btnQ.png" .. get_key_overlay(skills_order[2]) .. ";]" ..
		"image[11.78,2.29;0.65,0.65;fbrawl_hud_btnSX.png" .. get_key_overlay(skills_order[3]) .. ";]" ..
		"image[13.38,2.29;0.65,0.65;fbrawl_hud_btnDX.png" .. get_key_overlay(skills_order[4]) .. ";]" ..
		"image[9.16,2.101;0.65,0.65;fbrawl_hud_btnZ.png" .. get_key_overlay(skill_ZOOM) .. ";]" ..
		
		"image[9.02,0.1;2.717,1.3;fbrawl_health_" .. scale_hp_to_16() ..".png^[colorize:#302c2e:40;]"
	]]

	local formspec_ast = {
		{
			w = 10,
			h = 4,
			type = "size"
		},
		{
			x = 0.299,
			y = 0.92,
			type = "position"
		},
		{
			type = "no_prepend"
		},
		{
			bgcolor = "#FF00FF00",
			type = "bgcolor"
		},
		{
			selectors = {
				"mid_label"
			},
			props = {
				border = "false",
				font_size = "*2"
			},
			type = "style"
		},
		{
			selectors = {
				"big_label"
			},
			props = {
				border = "false",
				font_size = "*3"
			},
			type = "style"
		},
		{
			selectors = {
				"small_label"
			},
			props = {
				border = "false",
				font_size = "*1"
			},
			type = "style"
		},
		{
			texture_name = "fbrawl_hud_skill_slot.png",
			type = "image",
			y = 1.5,
			x = 5.9,
			h = 1.25,
			w = 1.25
		},
		{
			texture_name = "fbrawl_hud_skill_slot.png",
			type = "image",
			y = 1.5,
			x = 7.5,
			h = 1.25,
			w = 1.25
		},
		{
			texture_name = "fbrawl_hud_skill_slot.png",
			type = "image",
			y = 1.5,
			x = 12,
			h = 1.25,
			w = 1.25
		},
		{
			texture_name = "fbrawl_hud_skill_slot.png",
			type = "image",
			y = 1.5,
			x = 13.6,
			h = 1.25,
			w = 1.25
		},
		{
			texture_name = "fbrawl_hud_ulti_slot.png",
			type = "image",
			y = 0.5,
			x = 9.25,
			h = 2.25,
			w = 2.25
		},
		{
			texture_name = skills_order[1].icon,
			type = "image",
			y = 1.75,
			x = 6.15,
			h = 0.75,
			w = 0.75
		},
		{
			texture_name = skills_order[2].icon,
			type = "image",
			y = 1.75,
			x = 7.75,
			h = 0.75,
			w = 0.75
		},
		{
			texture_name = skills_order[3].icon,
			type = "image",
			y = 1.75,
			x = 12.25,
			h = 0.75,
			w = 0.75
		},
		{
			texture_name = skills_order[4].icon,
			type = "image",
			y = 1.75,
			x = 13.85,
			h = 0.75,
			w = 0.75
		},
		{
			texture_name = skill_ZOOM.icon,
			type = "image",
			y = 0.86,
			x = 9.63,
			h = 1.5,
			w = 1.5
		},
		{
			texture_name = get_overlay(skills_order[1]),
			type = "image",
			y = 1.5,
			x = 5.9,
			h = 1.25,
			w = 1.25
		},
		{
			texture_name = get_overlay(skills_order[2]),
			type = "image",
			y = 1.5,
			x = 7.5,
			h = 1.25,
			w = 1.25
		},
		{
			texture_name = get_overlay(skills_order[3]),
			type = "image",
			y = 1.5,
			x = 12,
			h = 1.25,
			w = 1.25
		},
		{
			texture_name = get_overlay(skills_order[4]),
			type = "image",
			y = 1.5,
			x = 13.6,
			h = 1.25,
			w = 1.25
		},
		{
			texture_name = get_overlay(skill_ZOOM),
			type = "image",
			y = 0.55,
			x = 9.311,
			h = 2.15,
			w = 2.15
		},
		{
			name = "mid_label",
			label = get_cooldown(skills_order[1]),
			texture_name = "fbrawl_transparent.png",
			type = "image_button",
			y = 1.7,
			x = 6.08,
			h = 1,
			w = 1
		},
		{
			name = "mid_label",
			label = get_cooldown(skills_order[2]),
			texture_name = "fbrawl_transparent.png",
			type = "image_button",
			y = 1.7,
			x = 7.68,
			h = 1,
			w = 1
		},
		{
			name = "mid_label",
			label = get_cooldown(skills_order[3]),
			texture_name = "fbrawl_transparent.png",
			type = "image_button",
			y = 1.65,
			x = 12.18,
			h = 1,
			w = 1
		},
		{
			name = "mid_label",
			label = get_cooldown(skills_order[4]),
			texture_name = "fbrawl_transparent.png",
			type = "image_button",
			y = 1.65,
			x = 13.78,
			h = 1,
			w = 1
		},
		{
			name = "big_label",
			label = get_cooldown(skill_ZOOM),
			texture_name = "fbrawl_transparent.png",
			type = "image_button",
			y = 0.95,
			x = 9.93,
			h = 1,
			w = 1
		},
		{
			name = "small_label",
			label = get_cooldown(skill_ZOOM) ~= "" and minetest.colorize("#cfc6b8", S("Kills")) or "",
			texture_name = "fbrawl_transparent.png",
			type = "image_button",
			y = 1.45,
			x = 9.91,
			h = 1,
			w = 1
		},
		{
			texture_name = "fbrawl_hud_btnSHIFT.png"..get_key_overlay(skills_order[1]),
			type = "image",
			y = 2.29,
			x = 5.68,
			h = 0.65,
			w = 0.8125
		},
		{
			texture_name = "fbrawl_hud_btnQ.png"..get_key_overlay(skills_order[2]),
			type = "image",
			y = 2.29,
			x = 7.28,
			h = 0.65,
			w = 0.65
		},
		{
			texture_name = "fbrawl_hud_btnSX.png"..get_key_overlay(skills_order[3]),
			type = "image",
			y = 2.29,
			x = 11.78,
			h = 0.65,
			w = 0.65
		},
		{
			texture_name = "fbrawl_hud_btnDX.png"..get_key_overlay(skills_order[4]),
			type = "image",
			y = 2.29,
			x = 13.38,
			h = 0.65,
			w = 0.65
		},
		{
			texture_name = "fbrawl_hud_btnZ.png"..get_key_overlay(skill_ZOOM),
			type = "image",
			y = 2.101,
			x = 9.16,
			h = 0.65,
			w = 0.65
		},
		{
			texture_name = "fbrawl_health_"..scale_hp_to_16()..".png^[colorize:#302c2e:40",
			type = "image",
			y = 0.1,
			x = 9.02,
			h = 1.3,
			w = 2.717
		},
		formspec_version = 3
	}

	hud_fs.show_hud(player, "fantasy_brawl:controls", formspec_ast)

	minetest.after(0.3, function ()
		fbrawl.generate_controls_hud(arena, pl_name)
	end)
end
local function get_classes_tabs() end
local function get_skills_tabs() end

local S = fbrawl.T
local F = minetest.formspec_escape



function fbrawl.show_class_selector(pl_name)
	local pl_meta = minetest.get_player_by_name(pl_name):get_meta()
	local pl_data = minetest.deserialize(pl_meta:get_string("fbrawl:data")) or {}

	pl_data.selected_class_name = pl_data.selected_class_name or "Warrior"          -- v for sanity reason
	local selected_class = fbrawl.get_class_by_name(pl_data.selected_class_name) or fbrawl.get_class_by_name("Warrior")

	pl_data.selected_skill_name = pl_data.selected_skill_name or selected_class.skills.LMB
																									    -- v for sanity reason
	local selected_skill = skills.get_skill_def(pl_data.selected_skill_name) or skills.get_skill_def(selected_class.skills.LMB)

	local formspec =
		"formspec_version[4]"..
		"size[15,15]"..
		"position[0.325,0.18]" ..
		"anchor[0,0]" ..
		"no_prepend[]"..
		"padding[0,0]"..
		"bgcolor[;true]"..
		"style_type[image_button;border=false;size=24;textcolor=#dff6f5;font=mono]"..
		"style_type[image_button;border=false]"..

		-- INFO ABOUT CLASS
		"container[1.3,0]"..
		"image[0,0;9,9.3;fbrawl_gui_selector_bg.png]"..
		"hypertext[1,1;7,1.6;class_name;<global size=32 font=mono color=#472d3c><b>"..F(S(selected_class.name)).."</b>]" ..
		"hypertext[1,2;7,1.6;class_desc;<global size=16 font=mono color=#5e3643>"..F(selected_class.description).."]" ..

		-- SKILLS
		"container[1,4]"..
		get_skills_tabs(pl_data)..
		"hypertext[0,1.7;7,1.5;class_name;<global size=24 font=mono color=#472d3c><b>"..F(selected_skill.name).."</b>]" ..
		"hypertext[0,2.4;7,1.8;class_desc;<global size=16 font=mono color=#472d3c>"..F(selected_skill.description).."]" ..
		"container_end[]" ..
		-- END SKILLS

		"container_end[]" ..
		-- END INFO ABOUT CLASS

		get_classes_tabs(pl_data)..

		-- SELECT BTN
		"image_button_exit[4.2,8.6;2.8,1.3;fbrawl_gui_btn_choose.png;choose_class;"..F(S("Choose")).."]"

	pl_meta:set_string("fbrawl:data", minetest.serialize(pl_data))
	minetest.show_formspec(pl_name, "class_selector", formspec)
end



minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "class_selector" then return false end

	local pl_name = player:get_player_name()
	local pl_meta = minetest.get_player_by_name(pl_name):get_meta()
	local pl_data = minetest.deserialize(pl_meta:get_string("fbrawl:data")) or {}

	-- change the selected class or skill in the formspec
	for skill_or_class, _ in pairs(fields) do
		if string.find(skill_or_class, "unselected_class") then
			pl_data.selected_class_name = skill_or_class:split("|")[2]
			pl_data.selected_skill_name = nil
		elseif string.find(skill_or_class, "unselected_skill") then
			pl_data.selected_skill_name = skill_or_class:split("|")[2]
		else break end

		pl_meta:set_string("fbrawl:data", minetest.serialize(pl_data))
		fbrawl.show_class_selector(pl_name)
	end

	if fields.choose_class then
		pl_data.chosen_class = pl_data.selected_class_name
		pl_meta:set_string("fbrawl:data", minetest.serialize(pl_data))

		minetest.sound_play({name="fbrawl_class_selected"}, {to_player = pl_name})
		minetest.chat_send_player(pl_name, S("You've chosen the @1 class", S(pl_data.selected_class_name)))

		minetest.close_formspec(pl_name, "class_selector")

		return
	end
end)



function get_classes_tabs(pl_data)
	local btns = ""
	local selected_class_name = pl_data.selected_class_name or "Warrior"

	for i, def in pairs(fbrawl.classes) do
		local class = fbrawl.get_class_by_name(def.name)
		local btn_y = 1.5*(i-1)

		if class.name == selected_class_name then
			btns = btns ..
			"set_focus[selected_class;]"..
			"image_button[0,"..btn_y..";1.5,1.5;fbrawl_gui_btn_class_selected.png;selected_class;]"..
			"image[0,"..(btn_y+0.08)..";1.4,1.4;"..class.icon.."]"

		else
			btns = btns ..
			"image_button[0,"..btn_y..";1.5,1.5;fbrawl_gui_btn_class_unselected.png;unselected_class|"..class.name..";]"..
			"image[0,"..(btn_y+0.08)..";1.4,1.4;"..class.icon.."]"
		end
	end

	return btns
end



function get_skills_tabs(pl_data)
	local btns = ""
	local selected_skill_name = pl_data.selected_skill_name
	local selected_class = fbrawl.get_class_by_name(pl_data.selected_class_name)
	local rendered_btns = 1
	local skls = selected_class.skills
	local ordered_skills = {skls.LMB, skls.RMB, skls.SNEAK, skls.Q, skls.ZOOM}

	for _, skill_name in ipairs(ordered_skills) do
		local btn_x = 1.43 * (rendered_btns-1)
		local skill = skills.get_skill_def(skill_name)
		local button_type = "fbrawl_gui_btn_skill"

		if rendered_btns == 5 then button_type = "fbrawl_gui_btn_ultimate" end

		if skill.icon then
			if skill_name == selected_skill_name then
				btns = btns ..
				"image_button["..btn_x..",0.02;1.3,1.3;"..button_type.."_selected.png;selected_skill;]"..
				"image["..(btn_x+0.15)..",0.14;1,1;"..skill.icon.."]"

			else
				btns = btns ..
				"image_button["..btn_x..",-0.05;1.3,1.3;"..button_type.."_unselected.png;unselected_skill|"..skill.internal_name..";]"..
				"image["..(btn_x+0.15)..",0.1;1,1;"..skill.icon.."]"
			end

			rendered_btns = rendered_btns + 1
		end
	end

	return btns
end

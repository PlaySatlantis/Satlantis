local function get_model(skins, pl_name, index, x, y, width, height, rot_y, selected) end
local function get_collection(collect_name, index, txt, x, selected) end

local app_def = {
	icon = "app_skins.png",
	name = "Skins",
	bg_color = "#3153b7",

	get_content = function (self, player, page, collection_name, skin_name)
		local pl_name = player:get_player_name()

		if not skin_name and not collection_name then
			skin_name = collectible_skins.get_player_skin(pl_name).technical_name
			collection_name = collectible_skins.get_player_skin(pl_name).collection
		elseif not skin_name and collection_name then
			skin_name = table.convert_to_num_indexes(collectible_skins.get_skins_by_collection(collection_name))[1].technical_name
		elseif not collection_name then
			collection_name = collectible_skins.get_skin(skin_name).collection
		end

		-- find the collection idx in the ordered list
		local collections = collectible_skins.get_collections()
		collections = table.mergesort(collections, function (a, b)
			return a:upper() < b:upper()
		end)
		local selected_collection_idx = table.indexof(collections, collectible_skins.get_skin(skin_name).collection)

		-- find the skin idx in the ordered list
		local skins = table.convert_to_num_indexes(collectible_skins.get_skins_by_collection(collection_name))
		skins = table.mergesort(skins, function (a, b)
			if a.tier == b.tier then return a.technical_name:upper() < b.technical_name:upper() end
			return a.tier > b.tier
		end)
		local selected_skin_idx = table.find(skins, function (skin)
			return skin.technical_name == skin_name
		end)

		local selected_skin = skins[selected_skin_idx]
		local skin_name = selected_skin.name
		local skin_desc = selected_skin.description

		if not collectible_skins.is_skin_unlocked(pl_name, selected_skin.technical_name) then
			skin_name = "??"
			skin_desc = selected_skin.hint or "??"
		end

		-- generating the 3d models
		local prev_model = get_model(skins, pl_name, selected_skin_idx-1, 0.08, 1.15, 3, 2.1, -160)
		local weared_model = get_model(skins, pl_name, selected_skin_idx, 0.08, 0, 7.35, 4.3, -170, "selected")
		local next_model = get_model(skins, pl_name, selected_skin_idx+1, 4.3, 1.15, 3, 2.1, 160)

		-- generating the collections buttons
		local prev_collection = get_collection(collections, selected_collection_idx-1, "app_skins.png", 1.3)
		local curr_collection = get_collection(collections, selected_collection_idx, "app_skins.png", 3.2, "selected")
		local next_collection = get_collection(collections, selected_collection_idx+1, "app_skins.png", 5.1)

		-- to avoid arrows generating errors when the skin/collection is the first or last one
		skins[#skins+1] = skins[#skins]
		skins[0] = skins[1]
		collections[#collections+1] = collections[#collections]
		collections[0] = collections[1]

		return [[
		container[0.5,0]
		box[-0.5,0;8.5,1.8;#00000066]
		image_button[0,0.4;0.45,0.8;phone_icon_arrow_left.png^[multiply:#859b9b;collect_left|]] .. collections[selected_collection_idx-1] ..[[;]
		image_button[7,0.4;0.45,0.8;phone_icon_arrow_right.png^[multiply:#859b9b;collect_right|]] .. collections[selected_collection_idx+1] ..[[;] ]]..
		prev_collection .. curr_collection .. next_collection .. [[
		container_end[]
		container[0.5,1.5]
		hypertext[0,0.3;7.5,2.5;pname_txt;<global size=35 halign=center valign=middle><b>]] .. skin_name .. [[</b>]
		container[0,2.5] ]] ..
		prev_model ..	next_model .. weared_model ..
		[[image_button[0,1.8;0.45,0.8;phone_icon_arrow_left.png^[multiply:#abc0c0;skin_left|]] .. skins[selected_skin_idx-1].technical_name ..[[;]
		image_button[7,1.8;0.45,0.8;phone_icon_arrow_right.png^[multiply:#abc0c0;skin_right|]] .. skins[selected_skin_idx+1].technical_name ..[[;]
		container_end[]
		image[0,7.3;7.5,2.5;phone_app_mask.png^[multiply:#abc0c0;50]
		image_button[2.4,10.4;2.65,0.9;bl_gui_profile_button_equip.png;skin_btn|]] .. skins[selected_skin_idx].technical_name .. [[;Equip]
		hypertext[0.2,7.5;7.1,2;elem_desc;<global size=17 halign=center valign=middle><i><style color=#283c8c>]] .. skin_desc .. [[</i>]
		container_end[]
		]]
	end

}

smartphone.register_app("phone_skins:skins", app_def)



minetest.register_on_player_receive_fields(function(player, formname, fields)
	local app = smartphone.get_app(formname)

	if not app or not app.technical_name == "phone_skins:skins" then return false end

	for field, _ in pairs(fields) do
		if string.find(field, "skin_btn") then
			local skin_tech_name = string.split(field, "|")[2] or ""

			if collectible_skins.is_skin_unlocked(player:get_player_name(), skin_tech_name) then
				collectible_skins.set_skin(player, skin_tech_name, true)
			else
				minetest.chat_send_player(player:get_player_name(), "You need to unlock this skin first!")
			end

			return true

		elseif string.find(field, "skin_left") or string.find(field, "skin_right") then
			local tech_name = string.split(field, "|")[2] or ""
			local skin = collectible_skins.get_skin(tech_name)

			if skin then
				smartphone.open_app(player, "phone_skins:skins", skin.collection, tech_name)
			end

			return true

		elseif string.find(field, "collect_right") or string.find(field, "collect_left") or string.find(field, "collection_btn") then
			local collect = string.split(field, "|")[2] or ""

			if table.indexof(collectible_skins.get_collections(), collect) then
				smartphone.open_app(player, "phone_skins:skins", collect)
			end

			return true
		end
	end

	return false
end)



function table.convert_to_num_indexes(t)
	local output = {}
	for k, v in pairs(t) do
		table.insert(output, v)
	end
	return output
end



function table.count(table)
	local count = 0
	for k, v in pairs(table) do
		count = count + 1
	end
	return count
end



-- returns the first index of the first element that satisfies the function
function table.find(table, func)
	for k, v in pairs(table) do
		if func(v) then return k end
	end
end



function get_model(skins, pl_name, index, x, y, width, height, rot_y, selected)
	local txt = (skins[index] or {}).texture
	local overlay = selected and "" or "^[multiply:#bbbbbb"

	if not txt then return "" end

	if not collectible_skins.is_skin_unlocked(pl_name, skins[index].technical_name) then
		overlay = "^[multiply:#000000"
	end

	return "model["..x..","..y..";"..width..","..height..";chara;character.b3d;"..txt..overlay..";0,"..rot_y..";false;true]"
end



function get_collection(collections, index, txt, x, selected)
	local collect_name = collections[index]

	if not collect_name then return "" end

	local overlay = selected and "" or "^[multiply:#aaaaaa"
	local btn_name = "collection_btn|"..collect_name

	return
	("image_button[%f,0.25;1,1;%s^[mask:phone_app_mask.png%s;%s;]"):format(x, txt, overlay, btn_name) ..
	("hypertext[%f,1.2;1.3,0.8;sect_txt;<global size=10 halign=center valign=middle><b>%s</b>]"):format(x-0.1, collect_name)
end
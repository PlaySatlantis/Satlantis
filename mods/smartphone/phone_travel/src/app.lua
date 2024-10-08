local function get_destination(y, destination, show_box) end
local function get_invite(y, destination, show_box) end


local app_def = {
	icon = "app_travel.png",
	name = "Travel",
	cmd_name = {"travel",},
	bg_color = "#4116a2",

	get_height = function (self, player)
		return math.max(smartphone.content_height, #phone_travel.get_destinations(player:get_player_name()) * 3)
	end,


	get_destinations = function (self, pl_name)
		return phone_travel.get_destinations(pl_name)
	end,

	get_invites = function (self, pl_name)
		return phone_travel.get_invites(pl_name)
	end,

	get_content = function (self, player, page)
		if not page then
			local pl_name = player:get_player_name()
			local destinations = self:get_destinations(pl_name)
			local destination_elements = ""

			local y = 2.8-smartphone.content_y
			local v_offset = 2.44
			local show_box = true
			for i, d in pairs(destinations) do
				destination_elements = destination_elements .. get_destination(y, d, show_box)
				show_box = not show_box
				y = y + v_offset
			end

			return [[
			container[0.5,0]
			image_button[0,0;3.3,1.2;phone_button_blue2.png;destinations_btn;Destinations]
			image_button[4.2,0;3.3,1.2;phone_button_yellow.png;manage_btn;Manage Orbiter]
			container_end[] ]] ..
			destination_elements
		else
			local pl_name = player:get_player_name()
			local invites = self:get_invites(pl_name)
			local invite_elements = ""

			local y = 2.8-smartphone.content_y
			local v_offset = 2.44
			local show_box = true
			for i, d in pairs(invites) do
				invite_elements = invite_elements .. get_invite(y, d, show_box)
				show_box = not show_box
				y = y + v_offset
			end

			local box = show_box and "box[-0.5,0;8.5,2.44;#00000055]" or ""
			local icon
			local name
			local desc
			
			icon = "image[0,0.32;1.8,1.8;app_travel.png^[mask:phone_app_mask.png]"
			name = "hypertext[2,0.1;5.3,1;pname_txt;<global size=20 valign=middle><b>Instructions</b>]"
			desc = "hypertext[2,0.85;6,1.7;pname_txt;<global size=14><style color=#cfc6b8><i>You can invite players to your island with "..
			"/trust (username). Make sure to trust the people you invite, because they will have access to everything "..
			"on your island!</i>]"

			local invite_instruction = ([[
				container[0.5,%f] ]] ..
				box ..
				icon .. name .. desc .. [[
				container_end[]
				]]):format(y)

			return [[
			container[0.5,0]
			image_button[0,0;3.3,1.2;phone_button_blue2.png;destinations_btn;Destinations]
			image_button[4.2,0;3.3,1.2;phone_button_yellow.png;manage_btn;Manage Orbiter]
			container_end[] ]] .. invite_elements ..
			invite_instruction
		end
	end
}

smartphone.register_app("phone_travel:app_travel", app_def)

function get_destination(y, destination, show_box)
	local d = destination
	local box = show_box and "box[-0.5,0;8.5,2.44;#00000055]" or ""
	local icon
	local name
	local desc
	local button

	if d.type == "lobby" or d.type == "overworld" or d.type == "personal_island" then
		icon = "image[0,0.32;1.8,1.8;app_travel.png^[mask:phone_app_mask.png]"
		name = "hypertext[2,0.1;5.3,1;pname_txt;<global size=20 valign=middle><b>"..d.name.."</b>]"
		desc = "hypertext[2,0.85;3.2,1.1;pname_txt;<global size=14><style color=#cfc6b8><i>"..d.description.."</i>]"
		button = ("image_button_exit[4.2,1.25;3.3,1.2;phone_button_blue2.png;go_"..d.type.."_btn;Go!]")
	else
		icon = "image[0,0.32;1.8,1.8;app_travel.png^[mask:phone_app_mask.png]"
		name = "hypertext[2,0.1;5.3,1;pname_txt;<global size=20 valign=middle><b>"..d.name.."</b>]"
		desc = "hypertext[2,0.85;3.2,1.1;pname_txt;<global size=14><style color=#cfc6b8><i>"..d.description.."</i>]"
		button = ("image_button_exit[4.2,1.25;1.5,1.2;phone_button_yellow.png;go_island_"..d.name.."_btn;Go!]")
	end

	return ([[
		container[0.5,%f] ]] ..
		box ..
		icon .. name .. desc .. button .. [[
		container_end[]
	]]):format(y)
end

function get_invite(y, invite, show_box)
	local i = invite
	local box = show_box and "box[-0.5,0;8.5,2.44;#00000055]" or ""
	local icon
	local name
	local desc
	local button
	
	icon = "image[0,0.32;1.8,1.8;app_travel.png^[mask:phone_app_mask.png]"
	name = "hypertext[2,0.1;5.3,1;pname_txt;<global size=20 valign=middle><b>"..i.."</b>]"
	desc = "hypertext[2,0.85;3.2,1.1;pname_txt;<global size=14><style color=#cfc6b8><i>"..i.." has access to your island!</i>]"
	button = ("image_button_exit[5,1.1;2.5,1.2;phone_button_yellow.png;remove_access_"..i.."_btn;Remove]")

	return ([[
		container[0.5,%f] ]] ..
		box ..
		icon .. name .. desc .. button .. [[
		container_end[]
	]]):format(y)
end

function string:contains(sub)
    return self:find(sub, 1, true) ~= nil
end

function string:startswith(start)
    return self:sub(1, #start) == start
end

function string:endswith(ending)
    return ending == "" or self:sub(-#ending) == ending
end

function string:replace(old, new)
    local s = self
    local search_start_idx = 1

    while true do
        local start_idx, end_idx = s:find(old, search_start_idx, true)
        if (not start_idx) then
            break
        end

        local postfix = s:sub(end_idx + 1)
        s = s:sub(1, (start_idx - 1)) .. new .. postfix

        search_start_idx = -1 * postfix:len()
    end

    return s
end

function string:insert(pos, text)
    return self:sub(1, pos - 1) .. text .. self:sub(pos)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local pl_name = player:get_player_name()
	local app = smartphone.get_app(formname)

	if not app or (app.technical_name ~= "phone_travel:app_travel" and app.technical_name ~= "phone_travel:app_travel.2") then return false end

	if fields.manage_btn then
		smartphone.open_page(player, "phone_travel:app_travel.2")
		return true
	end

	if fields.destinations_btn then
		smartphone.open_app(player, "phone_travel:app_travel")
		return true
	end


	if fields.go_lobby_btn then
		phone_travel.go_to(pl_name, "lobby", "")
		return true
	end

	if fields.go_overworld_btn then
		phone_travel.go_to(pl_name, "overworld", "")
		return true
	end

	if fields.go_personal_island_btn then
		phone_travel.go_to(pl_name, "personal_island", "")
		return true
	end

	for field, _ in pairs(fields) do
		if field:startswith("go_island_") then
			local str
			str = field:replace("go_island_", "")
			str = str:replace("_btn", "")

			local name = str
			phone_travel.go_to(pl_name, "external_island", name)
		elseif field:startswith("remove_access_") then
			local str
			str = field:replace("remove_access_", "")
			str = str:replace("_btn", "")

			local name = str
			phone_travel.remove_access(name, pl_name)
			smartphone.open_page(player, "phone_travel:app_travel.2")
		end
	end

	return false
end)
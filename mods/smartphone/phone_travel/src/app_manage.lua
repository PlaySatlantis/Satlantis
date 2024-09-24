local function get_invite(y, destination, show_box) end

local app_def = {
	icon = "app_travel.png",
	name = "Manage Island",
	cmd_name = {"manage",},
	bg_color = "#4116a2",

	get_height = function (self, player)
		return math.max(smartphone.content_height, #phone_travel.get_invites(player:get_player_name()) * 3)
	end,


	get_invites = function (self, pl_name)
		return phone_travel.get_invites(pl_name)
	end,

	get_content = function (self, player, page, type)
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

		return [[
		container[0.5,0]
		image_button[0,0;3.3,1.2;phone_button_blue2.png;destinations_btn;Destinations]
		image_button[4.2,0;3.3,1.2;phone_button_yellow.png;manage_btn;Manage Island]
		container_end[] ]] ..
		invite_elements
	end

}

smartphone.register_app("phone_travel:manage_island", app_def)

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
	button = ("image_button_exit[4.2,1.25;1.5,1.2;phone_button_yellow.png;remove_access_"..i.."_btn;Remove]")

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

	if not app or app.technical_name ~= "phone_travel:manage_island" then return false end

	if fields.destinations_btn then
		smartphone.open_app(player, "phone_travel:travel_home")
		return true
	end

	for field, _ in pairs(fields) do
		if field:startswith("remove_access_") then
			local str
			str = field:replace("remove_access_", "")
			str = str:replace("_btn", "")

			local name = str
			phone_travel.remove_access(name, pl_name)
			smartphone.open_app(player, "phone_travel:manage_island")
		end
	end

	return false
end)
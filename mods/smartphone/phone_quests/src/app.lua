local function get_quest(y, quest, is_completed, show_box) end
local function days_since_date(date_table) end

local app_def = {
	icon = "app_quests.png",
	name = "Quests",
	bg_color = "#4116a2",

	get_height = function (self, player, page, type)
		type = type or "daily"
		return #self:get_quests(player:get_player_name(), type) * 2.8
	end,

	get_quests = function (self, pl_name, type)
		-- filtering quests based on whether they must be weekly or daily
		local quests = table.filter(awards.get_award_states(pl_name), function (quest)
			local quests_to_show = {}
			local day = days_since_date(phone_quests.start_day)
			if type == "weekly" then
				local week = math.ceil(day / 7)
				local weekly_quests = phone_quests.weekly_quests
				quests_to_show = weekly_quests[week] or weekly_quests[(week % #weekly_quests) + 1]
			else
				local daily_quests = phone_quests.daily_quests
				quests_to_show = daily_quests[day] or daily_quests[(day % #daily_quests) + 1]
			end

			return table.find(quests_to_show, function (valid_quest_name)
				return valid_quest_name == quest.name
			end)
		end)

		-- sorting quests by name
		return table.mergesort(quests, function (a, b)
			return a.name:upper() < b.name:upper()
		end)
	end,

	get_content = function (self, player, page, type)
		local pl_name = player:get_player_name()
		type = type or "daily"
		local quests = self:get_quests(pl_name, type)
		local quest_elements = ""

		local y = 2.8-smartphone.content_y
		local v_offset = 2.44
		local show_box = true
		for i, q in pairs(quests) do
			local is_completed = not q.progress
			quest_elements = quest_elements .. get_quest(y, q, is_completed, show_box)
			show_box = not show_box
			y = y + v_offset
		end

		return [[
		container[0.5,0]
		image_button[0,0;3.3,1.2;phone_button_blue2.png;daily_btn;Daily quests]
		image_button[4.2,0;3.3,1.2;phone_button_blue2.png;weekly_btn;Weekly quests]
		container_end[] ]] ..
		quest_elements
	end

}

smartphone.register_app("phone_quests:quests", app_def)



minetest.register_on_player_receive_fields(function(player, formname, fields)
	local app = smartphone.get_app(formname)

	if not app or not app.technical_name == "phone_quests:quests" then return false end

	if fields.daily_btn then
		smartphone.open_app(player, "phone_quests:quests", "daily")
		return true
	elseif fields.weekly_btn then
		smartphone.open_app(player, "phone_quests:quests", "weekly")
		return true
	end

	return false
end)



-- returns a table with only the elements that satisfy the predicate
function table.filter(t, func)
	local output = {}
	for k, v in pairs(t) do
		if func(v) then
			table.insert(output, v)
		end
	end
	return output
end



-- returns the first index of the first element that satisfies the function
function table.find(table, func)
	for k, v in pairs(table) do
		if func(v) then return k end
	end
end



function get_quest(y, quest, is_completed, show_box)
	local q = quest
	local box = show_box and "box[-0.5,0;8.5,2.44;#00000055]" or ""
	local icon
	local name 
	local desc
	local completed
	local progress
	local points
	local points_icon

	if is_completed then
		icon = "image[0,0.32;1.8,1.8;app_quests.png^[multiply:#aaaaaa^[mask:phone_app_mask.png]"
		name = "hypertext[2,0.1;4,1;pname_txt;<global size=20 valign=middle><style color=#abc0c0><b>"..q.def.title.."</b>]"
		desc = "hypertext[2,0.85;3.1,1.1;pname_txt;<global size=14><style color=#7a9090><i>"..q.def.description.."</i>]"
		progress = ""
		points_icon = "image[5.8,1.75;0.22,0.3;bl_gui_profile_infobox_money.png^[multiply:#aaaaaa]"
		points = ("hypertext[5.3,1.75;2.1,0.4;pname_txt;<global size=14 halign=center><style color=#7a9090><b>%s</b>]"):format(q.def.points or "0")
		completed = "hypertext[5.23,0.9;2.3,0.6;pname_txt;<global size=16 valign=middle halign=center><style color=#5be7b1><b>Completed</b>]"
	else
		icon = "image[0,0.32;1.8,1.8;app_quests.png^[mask:phone_app_mask.png]"
		name = "hypertext[2,0.1;4,1;pname_txt;<global size=20 valign=middle><b>"..q.def.title.."</b>]"
		desc = "hypertext[2,0.85;3.1,1.1;pname_txt;<global size=14><style color=#cfc6b8><i>"..q.def.description.."</i>]"
		points_icon = "image[5.8,1.75;0.22,0.3;bl_gui_profile_infobox_money.png]"
		points = ("hypertext[5.3,1.75;2.1,0.4;pname_txt;<global size=14 halign=center><b>%s</b>]"):format(q.def.points or "0")
		progress = ("hypertext[2,1.75;3.4,0.4;pname_txt;<global size=14 halign=center><b>%s/%s</b>]"):format(q.progress.current, q.progress.target)
		completed = "hypertext[5.23,0.9;2.3,0.6;pname_txt;<global size=16 valign=middle halign=center><style color=#7a9090><b>Not completed</b>]"
	end

	return ([[
		container[0.5,%f] ]] ..
		box ..
		icon .. name .. desc .. progress .. points_icon .. points .. completed .. [[
		container_end[]
	]]):format(y)
end



-- Function to calculate the number of days since a given date
function days_since_date(date_table)
    -- Create a table for the given date
	date_table = date_table or {}
    local given_date = {
        year = date_table.year or 2024,
        month = date_table.month or 1,
        day = date_table.day or 1,
        hour = date_table.hour or 0,
        min = date_table.min or 0,
        sec = date_table.sec or 0
    }

	
    -- Convert the given date to a timestamp
    local given_timestamp = os.time(given_date)
    
    -- Get the current timestamp
    local current_timestamp = os.time()
    
    -- Calculate the difference in seconds and convert to days
    local seconds_in_a_day = 86400
    local difference_in_days = (current_timestamp - given_timestamp) / seconds_in_a_day
    
    return math.floor(difference_in_days)
end

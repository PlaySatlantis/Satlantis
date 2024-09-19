local asic_groups = {
	"s10",
	"s25+",
	"s25",
	"s30+",
	"s30",
	"s35+",
	"s35",
	"s40+",
	"s40",
	"s45+",
	"s45",
	"s50+",
	"s50"
}
local group_count = 13

local app_def = {
	icon = "app_wiki.png",
	name = "ASICs",
	cmd_name = {"asics",},
	bg_color = "#112554",

	hibernate_status = {},
	error_message = {},
	notification = {},

	get_height = function (self, player, page, type)
		return 4.0
	end,

	get_content = function (self, player, page, user_data)

		local player_name = player:get_player_name()
		local user_cache_entry = satlantis.cache_entry_for_user(player_name)

		if not user_cache_entry.asics then
			satlantis.get_asics(player_name, function(succeeded, message, json_data)
				if not succeeded then
					self.error_message[player_name] = tostring(message)
				end
				smartphone.open_app(player, "asics:asics")
			end)
		end

		--
		-- Initialize hibernate_status
		--
		if not self.hibernate_status[player_name] then
			self.hibernate_status[player_name] = {}
			for i = 1, group_count do
				self.hibernate_status[player_name][i] = false
			end
		end

		if not user_cache_entry.joules then
			satlantis.get_user_data(player_name, function(succeeded, message, json_data)
				if not succeeded then
					core.log("error", "Failed to get user data. User: " .. player_name .. " Server message: " .. message)
					self.notification[player_name] = nil
					self.error_message[player_name] = "Failed to get user data. Response: " .. tostring(message)
				end
				smartphone.open_app(player, "asics:asics")
			end)
		end

		if user_cache_entry.asics then
			local formspec_string = [[
				container[0.5,0.0]
				hypertext[0,0;5.3,1;asics_app_title;<global size=20 valign=middle><style color=#abc0c0><b>ASICs</b>]
				container[0.1,1]
			]]

			local asics = user_cache_entry.asics

			local asic_count = #asics

			local line_x_baseline = 0.0
			local line_height = 0.75

			local x = line_x_baseline
			local y = 0.75

			if asic_count > 0 then
				for group_i = 1, group_count do
					
					local current_group = asic_groups[group_i]
					local asic_in_group_count = 0
					local fueled_count = 0

					local i = 1

					for i = 1, #asics do
						local asic_group = "s" .. asics[i].hashRate
						if asics[i].asicType == "PLUS" then
							asic_group = asic_group .. "+"
						end

						if asic_group == current_group then
							asic_in_group_count = asic_in_group_count + 1
							if not asics[i].fuelRemaining == "0" then
								fueled_count = fueled_count + 1
							end
						end
						i = i + 1
					end

					if asic_in_group_count > 0 then
						local percent_filled = (fueled_count / asic_in_group_count) * 100
						local joules_remaining = 0
						local line_contents = current_group .. " - x" .. tostring(asic_in_group_count) .. " - " .. tostring(percent_filled) .. "% filled - " .. joules_remaining .. " joules remaining"

						--
						-- TODO: These are dummy images taken from the phone_rewards mod so that we don't pollute the git
						--       repo with unneccesary binary files. It's expected that they'll be replaced at some point
						-- 
						local fill_image_name = "phone_icon_checkmark.png"
						local hibernate_image_name = "phone_icon_locked.png"

						assert(self.hibernate_status[player_name] ~= nil)
						assert(self.hibernate_status[player_name][group_i] ~= nil)

						local texture_name = (self.hibernate_status[player_name][group_i] and hibernate_image_name or fill_image_name)
						formspec_string = formspec_string .. "image_button[" .. tostring(x) .. "," .. tostring(y - 0.25) .. ";" .. "0.5,0.5;" .. texture_name .. ";fill_image_" .. tostring(group_i) .. ";]"
						x = x + 0.75
						formspec_string = formspec_string .. "label[" .. tostring(x) .. "," .. tostring(y) .. ";" .. line_contents .. "]"

						y = y + line_height
						x = line_x_baseline
					end
				end
			else
				formspec_string = formspec_string .. "label[2.5," .. tostring(y) .. ";No ASICs found]"
				y = y + 0.5
			end

			if user_cache_entry.joules then
				y = y + 0.5
				formspec_string = formspec_string .. "label[" .. tostring(x) .. "," .. tostring(y) .. ";Your Joules: " .. tostring(user_cache_entry.joules) .. "]"
				y = y + line_height
				formspec_string = formspec_string .."field[" .. tostring(x) .. ", " .. tostring(y) .. ";1.5,0.65;fill_amount;;0]"
				x = x + 2.0
				formspec_string = formspec_string .."button[" .. tostring(x) .. ", " .. tostring(y) .. ";1.75,0.65;asics_fill;Fill]"
				x = x + 1.85
				formspec_string = formspec_string .."button[" .. tostring(x) .. ", " .. tostring(y) .. ";1.75,0.65;asics_fill_all;Fill All]"
			end

			local buttons_formspec = "button[2.45,10.75;2.5,0.75;asics_refresh;Refresh Data]"

			formspec_string = formspec_string .. buttons_formspec .. "container_end[]container_end[]"
			return formspec_string
		else
			return [[
				container[0.5,1.0]
				label[0,0.0;Loading..]
				container_end[]
			]]
		end
	end
}

smartphone.register_app("asics:asics", app_def)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local app = smartphone.get_app(formname)

	if not app or app.technical_name ~= "asics:asics" then
		return false 
	end

	local player_name = player:get_player_name()
	local handled_action = false

	if fields.asics_refresh then
		satlantis.cache_invalidate_field_for_user(player_name, "asics")
		smartphone.open_app(player, "asics:asics")
		return true
	end

	if fields.asics_fill then
		-- TODO: Implement
		handled_action = true
	end

	if fields.asics_fill_all then
		-- TODO: Implement
		handled_action = true
	end

	local updated = false

	for i = 1, group_count do
		local field_name = "fill_image_" .. tostring(i)
		if fields[field_name] then
			app.hibernate_status[player_name][i] = not app.hibernate_status[player_name][i]
			updated = true
			handled_action = true
		end
	end

	if updated then
		smartphone.open_app(player, "asics:asics")
	end

	return handled_action
end)
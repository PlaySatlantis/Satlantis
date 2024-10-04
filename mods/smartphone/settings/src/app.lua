-- nil, PENDING_CONFIRM, ENABLED
local user_2fa_state = {}
local user_setup_2fa_err_msg = {}

local app_def = {
	icon = "app_wiki.png",
	name = "Settings",
	bg_color = "#001a33",
	cmd_name = {"settings"},

	get_height = function (self, player, page, type)
		return smartphone.content_height or 2
	end,

	get_content = function (self, player, page, user_data)
		
		local player_name = player:get_player_name()

		if user_2fa_state[player_name] == "PENDING_CONFIRM" then

			local secret_key = satlantis.create_2fa_auth_key(player_name)

			local qrcode_data = string.format("otpauth://totp/Satlantis:%s?secret=%s&issuer=Satlantis", player_name, secret_key)
			local ok, qrcode_image = satlantis.qrcode_from_base32(qrcode_data)

			if not ok then
				core.log("error", "Failed to create qr image")
			end

			local page_formspec_format = [[
				formspec_version[7]
				container[0.5,0.0]
				hypertext[0,0;6,1;security_2fa_title;<global size=20 valign=middle><style color=#ffffff><b>2FA Setup</b>]
				container[0.25,1]
				hypertext[0,0;7,2;security_title;<global size=18 valign=middle><style color=#ffffff><normal>Add the authenication code to your preferred 2FA app and enter in the current code to confirm it</normal>]
				hypertext[0,2;7,1;2fa_code;<global size=18 valign=middle><style color=#ffffff><normal>Auth Key: <b>%s</b></normal>]
				image[1.5,3.5;4,4;[png:%s]
				hypertext[0,8.65;6,1;2fa_pass;<global size=16 valign=middle><style color=#ffffff><b>Pass Code: </b>]
				field[2.5,8.75;2,0.75;security_code_input;;]
				button[5,11;2,0.75;confirm_2fa_code;Confirm]
				container_end[]
				container_end[]
				%s
			]]
			local user_message_formspec = ""
			if user_setup_2fa_err_msg[player_name] then
				local err_formspec_format = [[
					box[0,13.1;9,0.5;#FF0505]
					hypertext[0.5,12.875;6,1;2fa_err_label;<global size=16 valign=middle><style color=#FFFFFF><b>%s</b>]
				]]
				user_message_formspec = string.format(err_formspec_format, user_setup_2fa_err_msg[player_name])
			end
			local page_formspec = string.format(page_formspec_format, secret_key, qrcode_image, user_message_formspec)
			return page_formspec
		elseif user_2fa_state[player_name] == "ENABLED" then
			local page_formspec = [[
				formspec_version[7]
				container[0.5,0.0]
				hypertext[0,0;5.3,1;settings_title;<global size=20 valign=middle><style color=#ffffff><b>Settings</b>]
				container[0.25,1]
				hypertext[0,0;4,1;security_title;<global size=18 valign=middle><style color=#ffffff><b>Security</b>]
				hypertext[0.25,0.75;4,1;security_title;<global size=16 valign=middle><style color=#ffffff><normal>2FA is enabled</normal>]
				container_end[]
				container_end[]
			]]
			return page_formspec
		end

		local page_formspec_format = [[
		    formspec_version[7]
			container[0.5,0.0]
			hypertext[0,0;5.3,1;settings_title;<global size=20 valign=middle><style color=#ffffff><b>Settings</b>]
			container[0.25,1]
			hypertext[0,0;4,1;security_title;<global size=18 valign=middle><style color=#ffffff><b>Security</b>]
			%s
			container_end[]
			container_end[]
		]]

		local security_formspec = ""

		if user_2fa_state[player_name] == nil then
			security_formspec = "button[0,1;2,0.5;enable_2fa_button;Enable 2FA]"
		end

		local page_formspec = string.format(page_formspec_format, security_formspec)
		return page_formspec
	end

}

smartphone.register_app("settings:main", app_def)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local app = smartphone.get_app(formname)

	if not app or app.technical_name ~= "settings:main" then
		return false 
	end

	local player_name = player:get_player_name()
	local user_cache_entry = satlantis.cache_entry_for_user(player_name)

	if fields.smtphone_back and user_2fa_state[player_name] == "PENDING_CONFIRM" then
		user_2fa_state[player_name] = nil
		user_setup_2fa_err_msg[player_name] = nil
		smartphone.open_app(player, "settings:main")
		return true
	end

	if fields.enable_2fa_button then
		user_2fa_state[player_name] = "PENDING_CONFIRM"
		smartphone.open_app(player, "settings:main")
	end

	if fields.input_2fa_code then
		user_2fa_state[player_name] = "PENDING_CONFIRM"
	end

	user_setup_2fa_err_msg[player_name] = nil

	if fields.confirm_2fa_code then
		local user_code = fields.security_code_input

		if user_code == "" then
			user_setup_2fa_err_msg[player_name] = "Enter OTP to confirm 2FA key"
			smartphone.open_app(player, "settings:main")
			return true
		end

		if #user_code ~= 6 then
			user_setup_2fa_err_msg[player_name] = "OTP should be 6 digits long"
			smartphone.open_app(player, "settings:main")
			return true
		end

		if satlantis.check_otp_code(player_name, user_code) then
			user_2fa_state[player_name] = "ENABLED"
			fields.confirm_2fa_code = ""
			smartphone.open_app(player, "settings:main")
		else
			fields.confirm_2fa_code = ""
			user_setup_2fa_err_msg[player_name] = "Incorrect code"
			smartphone.open_app(player, "settings:main")
		end
	end

	return false
end)

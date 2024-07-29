local filename = function(str)
	local i = #str
	while i >= 1 do
		local ch = string.sub(str, i, i)
		if ch == '\\' or ch == '/' then
			return string.sub(str, i + 1)
		end
		i = i - 1
	end
	return str
end

local app_def = {
	icon = "app_wiki.png",
	name = "Bitcoin Wallet",
	bg_color = "#112554",

	balance = {},
	error_message = {},
	success_message = {},
	deposit_qr_code = {},
	deposit_code = {},

	get_height = function (self, player, page, type)
		return 4.0
	end,

	get_content = function (self, player, page, user_data)

		local player_name = player:get_player_name()

		if not self.balance[player_name] then
			satlantis.get_user_data(player_name, function(succeeded, message, json_data)
				if not succeeded then
					local error_message = "Failed to get user data for user. Reason: " .. tostring(message)
					self.error_message[player_name] = error_message
					smartphone.open_app(player, "bitcoin_wallet:wallet")
					return
				end
				self.balance[player_name] = tonumber(json_data.balance) or 0.0
				smartphone.open_app(player, "bitcoin_wallet:wallet")
			end)
			return [[
				container[0.5,1.0]
				label[0,0.0;Loading..]
				container_end[]
			]]
		end

		if self.balance[player_name] then
			if not (self.deposit_code[player_name] or self.deposit_qr_code[player_name]) then
				satlantis.request_deposit_code(player:get_player_name(), function(succeeded, qr_image_file_path, request_code, error_message)
					if succeeded then
						self.deposit_qr_code[player_name] = filename(qr_image_file_path)
						self.deposit_code[player_name] = request_code
						self.error_message[player_name] = nil
						smartphone.open_app(player, "bitcoin_wallet:wallet")
					else
						self.error_message[player_name] = error_message
					end
				end)
			end
		end

		local formspec = [[
			container[0.5,0.0]
			hypertext[0,0;5.3,1;bitcoin_wallet_title;<global size=20 valign=middle><style color=#abc0c0><b>Bitcoin Wallet</b>]
			container[0.1,1.5]
			hypertext[0.2,0;3,1;btcw_balance;<global size=16> <style color=#ffffff><normal>Balance: ]] .. tostring(self.balance[player_name]) .. [[</normal></style>]
			field[0.25,0.5;4,0.75;withdraw_amount;;0.0]
			button[4.5,0.5;2.5,0.75;withdraw_btn;Withdraw]
			container[0,1.75]
			hypertext[0,0;3,1;btcw_send_user;<global size=16> <style color=#abc0c0><b>Transfers</b>]
			field[0.25,1.0;4,0.75;tx_user;User;]
			field[0.25,2.5;4,0.75;tx_amount;Amount;0.0]
			button[4.5,2.5;2.5,0.75;tx_btn;Transfer]
			%s
			%s
			container_end[]
			container_end[]
			container_end[]
		]]

		local deposit_formspec = ""
		local content_width = 7

		if self.deposit_code[player_name] then
			local qr_size = 4
			local qr_margin = (content_width - qr_size) / 2
			deposit_formspec = "hypertext[0.0,3.75;9.5,1;btcw_deposit_label;<global size=16> <style color=#abc0c0><b>Deposit:</b>]"
			deposit_formspec = deposit_formspec .. "image[" .. tostring(qr_margin) .. ",4.5;" .. tostring(qr_size) .. "," .. tostring(qr_size) .. ";" .. self.deposit_qr_code[player_name] .. ";]"
			deposit_formspec = deposit_formspec .. "textarea[0.25,9;6.7,2;;;" .. self.deposit_code[player_name] .. "]"
		end

		local notification_message = ""

		if self.success_message[player_name] then
			local y = smartphone.content_y
			notification_message = "hypertext[0.25,9.5;7,1;btcw_err_message;<global size=16> <style color=#abc0c0><normal>" .. self.success_message[player_name] .. "</normal>]"
		elseif self.error_message[player_name] then
			local y = smartphone.content_y
			notification_message = "hypertext[0.25,9.5;7,1;btcw_err_message;<global size=16> <style color=#d40606><normal>" .. self.error_message[player_name] .. "</normal>]"
		end

		return string.format(formspec, deposit_formspec, notification_message)
	end

}

smartphone.register_app("bitcoin_wallet:wallet", app_def)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local app = smartphone.get_app(formname)

	if not app or not app.technical_name == "bitcoin_wallet:wallet" then 
		return false 
	end

	local player_name = player:get_player_name()

	if fields.tx_btn then
		app.success_message[player_name] = nil
		app.error_message[player_name] = nil

		local src_player = player_name
		local dst_player = fields.tx_user
		local amount_field = fields.tx_amount

		if amount_field then
			if dst_player and dst_player ~= "" then
				local amount = tonumber(amount_field)
				if src_player ~= dst_player then
					if amount > 0 then
						satlantis.transfer_sats(src_player, dst_player, amount, function(succeeded, message, json_data)
							fields.tx_user = ""
							fields.tx_amount = "0.0"
							if succeeded then
								app.error_message[player_name] = nil
								app.success_message[player_name] = "Transfer successful"
								app.balance[player_name] = app.balance[player_name] - amount
							else
								app.error_message[player_name] = message
							end
							smartphone.open_app(player, "bitcoin_wallet:wallet")
						end)
					else
						app.error_message[player_name] = "Amount needs to be > 0"
						smartphone.open_app(player, "bitcoin_wallet:wallet")
					end
				else
					app.error_message[player_name] = "Cannot send money to self"
					smartphone.open_app(player, "bitcoin_wallet:wallet")
				end
			else
				app.error_message[player_name] = "Please specify player to transfer to"
				smartphone.open_app(player, "bitcoin_wallet:wallet")
			end
		else
			app.error_message[player_name] = "Enter a valid amount of sats to transfer"
			smartphone.open_app(player, "bitcoin_wallet:wallet")
		end

		return true
	end

	if fields.withdraw_btn then
		app.success_message[player_name] = nil
		app.error_message[player_name] = nil

		if fields.withdraw_amount and fields.withdraw_amount ~= "" then
			local amount = tonumber(fields.withdraw_amount)
			if amount > 0.0 then
				if amount <= app.balance[player_name] then
					local percent = (amount / app.balance[player_name]) * 100.0
					satlantis.withdraw_sats(player:get_player_name(), percent, function(succeeded, message, json_data)
						if succeeded then
							app.error_message[player_name] = nil
							app.success_message[player_name] = "Successfully withdraw " .. tostring(amount) .. "sats"
						else
							app.error_message[player_name] = message
						end
						fields.withdraw_amount[player_name] = "0.0"
						smartphone.open_app(player, "bitcoin_wallet:wallet")
					end)
				else
					app.error_message[player_name] = "Cannot withdraw more than the current balance"
					smartphone.open_app(player, "bitcoin_wallet:wallet")
				end
			else
				app.error_message[player_name] = "Enter in a valid amount to withdraw"
				smartphone.open_app(player, "bitcoin_wallet:wallet")
			end
		else
			app.error_message[player_name] = "Enter in a valid amount to withdraw"
			smartphone.open_app(player, "bitcoin_wallet:wallet")
		end
		return true
	end

	return false
end)
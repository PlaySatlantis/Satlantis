local listing_entry_height = 3
local user_listing_entry_height = 1

local item_type_asic = "asics"
local item_type_joule = "joules"

local function user_sell_item_page(user_name, user_joules, user_asics)
	local page_formspec_format = [[
		formspec_version[7]
		container[0.5,0.0]
		hypertext[0,0;5.3,1;auction_house_title;<global size=20 valign=middle><style color=#ffffff><b>Auction House</b>]
		container[0,1]
		%s
		%s
		container_end[]
		container_end[]
	]]

	local joules_formspec_format = [[
		hypertext[0,0;5.3,1;joules_amount_label;<global size=16 valign=middle><style color=#ffffff><b>Available Joules: </b><normal>%d</normal>]
		container[0.5,0]
		field[0,1.5;1.5,0.75;sell_joules_amount;Quantity;0]
		field[2,1.5;1.5,0.75;sell_joules_price;Price;0]
		button[4,1.5;2.5,0.75;sell_joules_button;Sell]
		container_end[]
	]]
	local joules_formspec = string.format(joules_formspec_format, user_joules)

	local asics_formspec = ""
	local asics_y_base = 4
	local line_height = 1

	local asic_types = satlantis.get_asic_types()
	local asics_formspec = [[
		hypertext[0,3;5.3,1;sell_asics_header;<global size=16 valign=middle><style color=#ffffff><b>Available Asics: </b>]
		container[0.5,0]
	]]
	local y = asics_y_base

	local asics_types = {}
	local asics_types_len = 0

	for i = 1, #asic_types do
		local type_count = 0
		for x = 1, #user_asics do
			local asic = user_asics[x]
			local type = "s" .. asic.hashRate
			if asic.asicType == "PLUS" then
				type = type .. "+"
			end

			if type == asic_types[i] then
				type_count = type_count + 1
			end
		end

		if type_count > 0 then
			asics_types[asics_types_len + 1] = {
				type = asic_types[i],
				amount = type_count
			}
			asics_types_len = asics_types_len + 1
		end
	end

	if asics_types_len > 0 then
		local dropdown_contents = ""
		for i = 1, asics_types_len do
			local item_format = asics_types[i].type .. " (x%d)"
			local item = string.format(item_format, asics_types[i].amount)
			if i > 1 then
				dropdown_contents = dropdown_contents .. ","
			end
			dropdown_contents = dropdown_contents .. item
		end
		local dropdown_formspec_format = "dropdown[0,%d;2,0.75;sell_asics_drop;%s;%d;]"
		local dropdown_formspec = string.format(dropdown_formspec_format, y, dropdown_contents, 1)
		asics_formspec = asics_formspec .. dropdown_formspec
		local fields_formspec_format = [[
			field[2.5,%d;1.5,0.75;sell_asics_amount;Quantity;0]
			field[4.5,%d;1.5,0.75;sell_asics_price;Price;0]
		]]
		local fields_formspec = string.format(fields_formspec_format, y, y)
		asics_formspec = asics_formspec .. fields_formspec
		local button_formspec_format = "button[4,%d;2.5,0.75;sell_asics_button;Sell]"
		local button_formspec = string.format(button_formspec_format, y + 2)
		asics_formspec = asics_formspec .. button_formspec
	end
	asics_formspec = asics_formspec .. "container_end[]"

	local page_formspec = string.format(page_formspec_format, joules_formspec, asics_formspec)
	return page_formspec
end

local app_def = {
	icon = "app_wiki.png",
	name = "Auction House",
	bg_color = "#001a33",

	auction_listings = nil,
	user_id = {},
	user_joules = {},
	user_balance = {},
	user_asics = {},
	user_error_message = {},
	user_page = {},
	user_joule_listings = {},
	user_listing_count = {},
	error_message = nil,

	get_height = function (self, player, page, type)
		if self.auction_listings then
			local player_name = player:get_player_name()
			local base_height = 4
			local user_listing_count = self.user_listing_count[player_name] or 0
			local users_listings_height = user_listing_count * user_listing_entry_height
			local listings_height = listing_entry_height * #self.auction_listings
			return math.max(smartphone.content_height, base_height + users_listings_height + listings_height)
		end
		return smartphone.content_height
	end,

	get_content = function (self, player, page, user_data)

		local player_name = player:get_player_name()

		local backend_id = satlantis.backend_id_from_player_name(player_name)
		if not backend_id then
			return [[
				container[0.5,1.0]
				label[0,0.0;Account not connected to Satlantis backend]
				container_end[]
			]]
		end

		if self.user_page[player_name] == "sell" then
			if self.user_joules[player_name] and self.user_asics[player_name] then
				return user_sell_item_page(player_name, self.user_joules[player_name], self.user_asics[player_name])
			end
		end

		if not self.auction_listings then
			satlantis.get_auction_house_listings(function(succeeded, message, auction_listings)
				if not succeeded then
					local error_message = "Failed to get auction house listings. Reason: " .. tostring(message)
					self.error_message = error_message
					smartphone.open_app(player, "auction_house:main")
					return
				end
				self.auction_listings = auction_listings
				smartphone.open_app(player, "auction_house:main")
			end)
			return [[
				container[0.5,1.0]
				label[0,0.0;Loading..]
				container_end[]
			]]
		end

		if not self.user_joules[player_name] then
			satlantis.get_user_data(player_name, function(succeeded, message, json_data)
				if succeeded then
					self.user_joules[player_name] = json_data.joules
					self.user_balance[player_name] = json_data.balance
					self.user_id[player_name] = json_data.id
				else
					core.log("error", "Failed to get user data for user. Reason: " .. tostring(message))
					self.user_joules[player_name] = 0
					self.user_balance[player_name] = 0
					self.user_id[player_name] = ""
				end
			end)
		end

		if not self.user_asics[player_name] then 
			satlantis.get_asics(player_name, function(succeeded, message, json_data)
				if succeeded then
					self.user_asics[player_name] = json_data
				else
					self.user_asics[player_name] = {}
					self.user_error_message[player_name] = tostring(message)
				end
				smartphone.open_app(player, "auction_house:main")
			end)
		end

		local page_formspec = [[
		    formspec_version[7]
			container[0.5,0.0]
			hypertext[0,0;5.3,1;auction_house_title;<global size=20 valign=middle><style color=#ffffff><b>Auction House</b>]
			container[0,1]
			%s
			%s
			%s
			container_end[]
			container_end[]
		]]

		
		local sell_items_formspec = "hypertext[0,0;5,1;auction_house_user_sales;<global size=18 valign=middle><style color=#abc0c0><b>Your Offers</b>]"
		local formspec_format = ""
		local formspec = ""
		local y = 1

		local user_joule_listings_formspec = "container[0.5,0]"

		self.user_joule_listings[player_name] = {}
		local user_joule_listing_i = 1
		local user_has_asics_listed = false

		if self.auction_listings then
			self.user_listing_count[player_name] = 0
			for i = 1, #self.auction_listings do
				local listing = self.auction_listings[i]
				if listing.sellerId == backend_id then
					formspec_format = "hypertext[0,%d;5,0.5;ah_user_joule_listing_%d;<global size=16 valign=middle><style color=#ffffff><normal>%02d %s @ %d sats</normal>]"
					formspec = string.format(formspec_format, y, i, tonumber(listing.quantity), listing.type, tonumber(listing.price));
					user_joule_listings_formspec = user_joule_listings_formspec .. formspec
					formspec_format = "button[3.5,%d;2,0.5;rm_joule_listing_%d_button;Remove]"
					formspec = string.format(formspec_format, y, i);
					user_joule_listings_formspec = user_joule_listings_formspec .. formspec
					y = y + user_listing_entry_height
					--
					-- Keep track of users listings so that race conditions don't cause us to remove the
					-- wrong listing
					--
					self.user_joule_listings[player_name][user_joule_listing_i] = listing
					user_has_asics_listed = true
					self.user_listing_count[player_name] = self.user_listing_count[player_name] + 1
				end
			end
			y = y - 1
		end

		user_joule_listings_formspec = user_joule_listings_formspec .. "container_end[]"

		sell_items_formspec = sell_items_formspec .. user_joule_listings_formspec

		if self.user_asics[player_name] and self.auction_listings then
			y = y + 1
			formspec_format = "button[%d,%d;2,0.5;open_sell_item_button;Add Listing]"
			formspec = string.format(formspec_format, 0, y)
			sell_items_formspec = sell_items_formspec .. formspec
		end

		y = y + 1

		local listings_formspec = "hypertext[0," .. tostring(y) .. ";5,1;auction_house_listings;<global size=18 valign=middle><style color=#abc0c0><b>Listed Items</b>]"
		y = y + 1.5
		local listing_count = #self.auction_listings

		local height_per_line = 1.0

		local base_x = 0.0

		for i = 1, listing_count do
			local item = self.auction_listings[i]
			local type_name =  item.type
			local quantity = item.quantity
			local price = item.price
			local seller_backend_id = item.sellerId
			local seller_name = satlantis.player_name_from_backend_id(seller_backend_id) or "unknown"

			--
			-- Don't display the users own listings here
			--
			if seller_backend_id ~= backend_id then
				local x = base_x
				--
				-- Seller <seller_name        <item_image>
				-- Amount <amount>            Price: <price>
				--

				formspec_format = string.format("box[0,%d;7.5,%d;#00284d]container[0.25,0.25]", y, listing_entry_height - 0.5)
				formspec_format = formspec_format .. "hypertext[%d,%d;5,1;listing_%d_seller;<global size=16> <style color=#ffffff><b>Seller:</b><normal> %s</normal>]"
				formspec = string.format(formspec_format, x, y, i, seller_name)
				listings_formspec = listings_formspec .. formspec

				local item_type_image = "smartphone_auction_house_item_unknown.jpg"
				if type_name == "joules" then
					item_type_image = "smartphone_auction_house_item_joule.jpg"
				elseif type_name == "asics" then
					item_type_image = "smartphone_auction_house_item_asic.jpg"
				else
					core.log("error", "Invalid item type. " .. tostring(type_name))
				end

				local item_image_x = base_x + 6
				formspec_format = "image[%d,%d;0.75,0.75;%s;]"
				formspec = string.format(formspec_format, item_image_x, y, item_type_image)
				listings_formspec = listings_formspec .. formspec

				formspec_format = "hypertext[%d,%d;7,0.5;listing_%d_item_amount;<global size=16> <style color=#ffffff><b>Amount: </b><normal>x%d</normal>]"
				formspec = string.format(formspec_format, x, y + height_per_line, i, quantity)
				listings_formspec = listings_formspec .. formspec

				formspec_format = "hypertext[%d,%d;7,1;listing_%d_item_price;<global size=16> <style color=#ffffff><b>Price: </b><normal>%d sats</normal>]"
				formspec = string.format(formspec_format, x + 5, y + height_per_line, i, price)
				listings_formspec = listings_formspec .. formspec

				formspec_format = "button[%d,%d;2,0.5;listing_%d_purchase_button;Purchase]"
				formspec = string.format(formspec_format, x + 5, y + height_per_line * 2.25, i)
				listings_formspec = listings_formspec .. formspec

				listings_formspec = listings_formspec .. "container_end[]"

				y = y + listing_entry_height
			end
		end

		local notification_message = ""

		if self.error_message then
			local y = smartphone.content_y
			notification_message = "hypertext[0.25,9.5;7,1;btcw_err_message;<global size=16> <style color=#d40606><normal>" .. self.error_message .. "</normal>]"
		end

		return string.format(page_formspec, sell_items_formspec, listings_formspec, notification_message)
	end

}

smartphone.register_app("auction_house:main", app_def)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local app = smartphone.get_app(formname)

	if not app or app.technical_name ~= "auction_house:main" then
		return false 
	end

	local player_name = player:get_player_name()

	if fields.smtphone_back and app.user_page[player_name] == "sell" then
		app.user_page[player_name] = nil
		smartphone.open_app(player, "auction_house:main")
		return true
	end

	if fields.open_sell_item_button then
		app.user_page[player_name] = "sell"
		smartphone.open_app(player, "auction_house:main")
		return true
	end

	if app.user_joule_listings[player_name] then
		for i = 1, #app.user_joule_listings[player_name] do
			local field_id = string.format("rm_joule_listing_%d_button", i)
			if fields[field_id] then
				--
				-- TODO: Backend API doesn't have an endpoint to remove listings yet
				--
				return true
			end
		end
	end

	if app.user_page[player_name] == "sell" then
		if fields["sell_joules_button"] then
			local quantity = tonumber(fields["sell_joules_amount"]) or 0
			local price = tonumber(fields["sell_joules_price"]) or 0
			if quantity > 0 and quantity <= app.user_joules[player_name] and price and price > 0 then
				satlantis.auction_sell_joules(player_name, quantity, price, function(succeeded, message, data)
					if succeeded then
						minetest.chat_send_player(player_name, "Listing for " .. tostring(quantity) .. " joules successfully added to auction house")
						--
						-- Force reload auction listings
						--
						app.auction_listings = nil
						smartphone.open_app(player, "auction_house:main")
					else
						minetest.chat_send_player(player_name, "Backend rejected request to list items for sale. Reason: " .. tostring(message))
					end
				end)
			else
				minetest.chat_send_player(player_name, "Invalid sale details")
				--
				-- TODO: Report error to user
				--
			end
			fields["sell_joules_amount"] = "0"
			fields["sell_joules_price"] = "0"
		end

		if fields["sell_asics_button"] then
			local quantity = tonumber(fields["sell_asics_amount"]) or 0
			local price = tonumber(fields["sell_asics_price"]) or 0

			if price > 0 and quantity > 0 then
				--
				-- 's25 (x44)' -> 's25 '
				-- 's50+ (x44)' -> 's50+'
				--
				local asics_type = string.sub(fields["sell_asics_drop"], 1, 4)
				local is_plus = (asics_type[4] == '+')
				if not is_plus then
					asics_type = string.sub(fields["sell_asics_drop"], 1, 3)
				end

				satlantis.auction_sell_asics(player_name, quantity, price, asics_type, function(succeeded, message, data)
					if succeeded then
						local message_format = "Listing for %d asics of type %s successfully added to auction house"
						local message = string.format(message_format, quantity, asics_type)
						minetest.chat_send_player(player_name, message)
						--
						-- Force reload auction listings
						--
						app.auction_listings = nil
						smartphone.open_app(player, "auction_house:main")
					else
						minetest.chat_send_player(player_name, "Failed to ASICs in Auction House. Reason: " .. tostring(message))
					end
				end)
			else
				minetest.chat_send_player(player_name, "Invalid ASICs listing details")
			end
			fields["sell_asics_amount"] = "0"
			fields["sell_asics_price"] = "0"
		end
		return true
	end

	if app.auction_listings then
		local listings_count = #app.auction_listings
		for i = 1, listings_count do
			local button_id = string.format("listing_%d_purchase_button", i)
			if fields[button_id] then
				local item = app.auction_listings[i]
				satlantis.purchase_auction_listing(player_name, item.id, function(succeeded, message, data)
					if succeeded then
						app.auction_listings = nil
						app.user_balance[player_name] = app.user_balance[player_name] - item.price
					else
						app.user_error_message[player_name] = "Failed to purchace item. Reason: " .. tostring(message)
						minetest.chat_send_player(player_name, app.user_error_message[player_name])
					end
					smartphone.open_app(player, "auction_house:main")
				end)
				return true
			end
		end
	end

	return false
end)

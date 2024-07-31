local height_per_entry = 3

local item_type_asic = "asics"
local item_type_joule = "joules"

local app_def = {
	icon = "app_wiki.png",
	name = "Auction House",
	bg_color = "#112554",

	auction_listings = nil,
	user_id = {},
	user_joules = {},
	user_balance = {},
	user_asics = {},
	user_error_message = {},
	error_message = nil,

	get_height = function (self, player, page, type)
		if self.auction_listings then
			local listings_count = #self.auction_listings
			return math.max(smartphone.content_height, 2.0 + (height_per_entry * listings_count))
		end
		return smartphone.content_height
	end,

	-- If the asic is listing in the auction house, return the details of the sale
	-- Otherwise return nil
	asic_sale_details = function (asic_id)
		if not self.auction_listings then
			return nil
		end

		local listing_count = #self.auction_listings
		for i = 1, listing_count do
			local item = self.auction_listings[i]
			if item.type == item_type_asic then
				local asic_id_count = #item.asicIds
				for x = 1, asic_id_count do
					if item.asicIds[x] == asic_id then
						return item
					end
				end
			end
		end
		return nil
	end,

	get_content = function (self, player, page, user_data)

		local player_name = player:get_player_name()

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

		if self.user_asics[player_name] and self.auction_listings then
			local listing_count = #self.auction_listings
			local user_id = self.user_id[player_name]
			local user_asics = self.user_asics[player_name]
			local user_asics_count = #self.user_asics[player_name]
			local sale_items_count = 0
			
			for i = 1, user_asics_count do
				local asic_id = user_asics[i].id
				local sale_details = self.asic_sale_details(asic_id)
				if sale_details then
					formspec_format = "hypertext[%d,%d;5,1;auction_house_user_asic_sale_%d;<global size=16 valign=middle><style color=#ffffff><b>%d asics @ %d sats</b>]"
					formspec = string.format(formspec_format, 0, y, i, sale_details.quanity, sale_details.price);
					sell_items_formspec = sell_items_formspec .. formspec
					y = y + 1.0
					sale_items_count = sale_items_count + 1
				end
			end

			if user_asics_count == 0 then
				sell_items_formspec = sell_items_formspec .. "label[2," .. tostring(y + 0.5) .. ";You have no items for sale]"
			end

			y = y + 1

			formspec_format = "button[%d,%d;2,0.5;open_sell_item_button;Sell Item]"
			formspec = string.format(formspec_format, 0, y)
			sell_items_formspec = sell_items_formspec .. formspec
		end

		y = y + 1

		local listings_formspec = "hypertext[0," .. tostring(y) .. ";5,1;auction_house_listings;<global size=18 valign=middle><style color=#abc0c0><b>Listed Items</b>]container[0.25,0]"
		y = y + 1.5
		local listing_count = #self.auction_listings

		local height_per_line = 1.0

		local base_x = 0.0

		-- TODO: Don't display items being sold by user

		for i = 1, listing_count do
			local item = self.auction_listings[i]
			local type_name =  item.type
			local quantity = item.quantity
			local price = item.price

			local x = base_x

			--
			-- Seller <seller_name        <item_image>
			-- Amount <amount>            Price: <price>
			--

			local seller_name = "Example User"
			formspec_format = "hypertext[%d,%d;5,1;listing_%d_seller;<global size=16> <style color=#ffffff><b>Seller:</b><normal> %s</normal>]"
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

			y = y + height_per_entry
		end

		listings_formspec = listings_formspec .. "container_end[]"

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

	if fields.open_sell_item_button then
		-- TODO: Open sell item menu
		return true
	end

	if app.auction_listings then
		local listings_count = #app.auction_listings
		for i = 1, listings_count do
			local button_id = string.format("listing_%d_purchase_button", i)
			if fields[button_id] then
				local item = self.auction_listings[i]
				purchase_auction_listing(player_name, item.id, function(succeeded, message, data)
					if succeeded then
						self.auction_listings = nil
						self.user_balance[player_name] = self.user_balance[player_name] - item.price
					else
						self.user_error_message[player_name] = "Failed to purchace item. Reason: " .. tostring(message)
						core.error("Failed to execute purchase for user " .. player_name .. " of listing id " .. item.id .. ". Reason: " .. message)
					end
					smartphone.open_app(player, "auction_house:main")
				end)
				return true
			end
		end
	end

	return false
end)

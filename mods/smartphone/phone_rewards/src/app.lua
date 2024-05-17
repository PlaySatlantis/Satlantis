local function get_quest(y, quest, is_completed) end


local app_def = {
	icon = "app_rewards.png",
	name = "Rewards",
	bg_color = "#283c8c",

	get_height = function (self, player)
		return math.max(smartphone.content_height, #phone_rewards.rewards * 3)
	end,

	get_icon = function (self, premium, reward)
		local x = premium and 5.15 or 0.7

		if reward.type == "skin" then
			return
				"image["..x..",0.41;1.6,1.6;app_skins.png^[mask:phone_app_mask.png]"..
				"tooltip["..x..",0.41;1.6,1.6;".. reward.value .."]"
		else
			return
				"image["..x..",0.41;1.6,1.6;app_rewards.png^[mask:phone_app_mask.png]"..
				"tooltip["..x..",0.41;1.6,1.6;".. reward.value .."]"
		end
	end,

	get_level_reward = function (self, pl_name, level, y)
		local is_premium = phone_rewards.is_premium(pl_name)
		local collected = phone_rewards.get_collected_rewards(pl_name)
		local collectable = phone_rewards.get_level(pl_name) >= level

		local icon_normal = self:get_icon(false, phone_rewards.rewards[level].normal)
		local icon_premium = ("%s image[5.15,0.41;1.6,1.6;phone_app_border.png]"):format(self:get_icon(true, phone_rewards.rewards[level].premium))

		local normal_checkmark = ""
		local premium_checkmark = ""
		local normal_claim_btn = ""
		local premium_claim_btn = ""
		local lock_icon = ""
		local dark_box_overlay = collectable and "" or "box[-0.5,0;8.5,2.44;#00000055]"
		local diamond_lvl = ([[
			%s
			image[3.25,0.68;1,1;phone_shape_diamond.png^[fill:200x200:0,0:#e061f9^[mask:phone_shape_diamond.png]
			hypertext[3,0.9;1.5,0.6;pname_txt;<global size=16 halign=center valign=middle><b>%s</b>]
		]]):format(level == #phone_rewards.rewards and "" or "box[3.71,1;0.08,2.2;#e061f9ff]", level)

		if not is_premium then
			lock_icon = "image[6.35,0.15;0.65,0.78;phone_icon_locked.png]"
		elseif collected[pl_name].premium[level] then
			premium_checkmark = "image[6.35,0.2;0.7,0.7;phone_icon_checkmark.png]"
		elseif collectable then
			premium_claim_btn = ("image_button_exit[5,-0.2;2,0.7;phone_button_green2.png;claim_btn|%s|%s;Claim!]"):format("premium", level)
		end

		if collected[pl_name].normal[level] then
			normal_checkmark = "image[1.9,0.2;0.7,0.7;phone_icon_checkmark.png]"
		elseif collectable then
			normal_claim_btn = ("image_button_exit[0.5,-0.2;2,0.7;phone_button_green2.png;claim_btn|%s|%s;Claim!]"):format("normal", level)
		end


		return ([[
			container[0.5, %s]
			%s
			container_end[]
		]]):format(y,
			icon_normal..icon_premium..
			normal_checkmark..premium_checkmark..lock_icon..
			normal_claim_btn..premium_claim_btn..
			diamond_lvl..dark_box_overlay
		)
	end,

	get_content = function (self, player)
		local pl_name = player:get_player_name()
		local rew = phone_rewards

		local levels = ""
		for i = 1, #rew.rewards do
			levels = levels..self:get_level_reward(pl_name, i, 3.5 + (i - 1) * 2.44)
		end

		return ([[
			style[daily_locked;textcolor=#7a9090]
			container[0.5,0]
			hypertext[0,0;7.5,1.2;pname_txt;<global size=16 halign=center><style color=#cfc6b8><i>Complete Quests to level up your Battlepass and earn Rewards. Purchase the Premium Battlepass for additional Quests and Rewards! </i>]
			image_button[0,1.2;3.3,1.2;phone_button_blue2.png;quests_btn;Quests]
			image_button[4.2,1.2;3.3,1.2;phone_button_yellow.png;premium_btn;Buy premium!]
			container_end[]

			box[0,2.5;8.5,1;#0c9bf9ff]
			box[4.21,3.5;4.2,%s;#0c9bf9]

			container[0,2.5]
			image[1,0.22;0.3,0.4;bl_gui_profile_infobox_money.png]
			box[1.5,0.25;5.5,0.35;#000000]
			box[1.5,0.25;%s,0.35;#f084f7ff]
			hypertext[1.5,0.6;5.5,0.42;pname_txt;<global size=16 halign=center><b> ]] .. rew.get_level_progress(pl_name) .. [[ </b>]
			hypertext[6.9,0.19;0.8,0.5;pname_txt;<global size=18 halign=center><b> ]] .. (rew.get_level(pl_name)+1) .. [[</b>]
			container_end[]

			%s
		]]):format(self:get_height(player), math.min(5.5, rew.get_points(pl_name)%rew.points_to_levelup / rew.points_to_levelup * 5.5), levels)
	end

}

smartphone.register_app("phone_rewards:rewards", app_def)



minetest.register_on_player_receive_fields(function(player, formname, fields)
	local app = smartphone.get_app(formname)

	if not app or not app.technical_name == "phone_rewards:rewards" then return false end

	if fields.quests_btn then
		smartphone.open_app(player, "phone_quests:quests")
	end

	for field, _ in pairs(fields) do
		if string.find(field, "claim_btn") then
			local premium = (string.split(field, "|")[2] or "") == "premium" and true or false
			local level = tonumber(string.split(field, "|")[3] or 0)
			phone_rewards.give_reward(player:get_player_name(), premium, level)
			return true
		end
	end

	return false
end)
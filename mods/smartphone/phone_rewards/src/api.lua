local storage = minetest.get_mod_storage()



--[[
	Gets the current points for a given player name.
	@param pl_name The name of the player.
	@return The current points for the player.
]]
function phone_rewards.get_points(pl_name)
	return storage:get_int("phone_rewards:points|" .. pl_name)
end



--[[
	Gets the current level for a given player name.
	@param pl_name The name of the player.
	@return The current level for the player.
]]
function phone_rewards.get_level(pl_name)
	return math.floor(phone_rewards.get_points(pl_name) / phone_rewards.points_to_levelup)
end



--[[
	Gets the current level progress for a given player name.
	@param pl_name The name of the player.
	@return The current level progress for the player in the format "current_points/points_to_levelup".
]]
function phone_rewards.get_level_progress(pl_name)
	return phone_rewards.get_points(pl_name) % phone_rewards.points_to_levelup .. "/" .. phone_rewards.points_to_levelup
end



--[[
	Sets the points for a given player name.
	@param pl_name The name of the player.
	@param value The new points value to set.
]]
function phone_rewards.set_points(pl_name, value)
	storage:set_int("phone_rewards:points|" .. pl_name, value)
end



--[[
	Adds points to a given player name.
	@param pl_name The name of the player.
	@param value The number of points to add.
]]
function phone_rewards.add_points(pl_name, value)
	local points = phone_rewards.get_points(pl_name)
	phone_rewards.set_points(pl_name, points + value)
end



--[[
	Gets the collected rewards for a given player name.
	@param pl_name The name of the player.
	@return A table containing the collected rewards for the player. Its structure is:
	{
		"pl_name" = {
			normal = {[1] = true, [2] = false, [3] = true, ...},    -- the levels' rewards they collected
			premium = {same as above}
		}
	}
]]
function phone_rewards.get_collected_rewards(pl_name)
	local collected = minetest.deserialize(storage:get_string("phone_rewards:collected_rewards|" .. pl_name)) or {}
	collected[pl_name] = collected[pl_name] or {}
	collected[pl_name].premium = collected[pl_name].premium or {}
	collected[pl_name].normal = collected[pl_name].normal or {}

	return collected
end



--[[
	Sets the collected rewards for a given player name.
	@param pl_name The name of the player.
	@param table The table containing the collected rewards to set.
]]
function phone_rewards.set_collected_rewards(pl_name, table)
	table[pl_name] = table[pl_name] or {}
	table[pl_name].premium = table[pl_name].premium or {}
	table[pl_name].normal = table[pl_name].normal or {}

	storage:set_string("phone_rewards:collected_rewards|" .. pl_name, minetest.serialize(table))
end



--[[
	Gives a reward to a player based on their level and premium status.
	@param pl_name The name of the player.
	@param premium Whether the reward is a premium reward or not.
	@param level The level for which to give the reward.
	@return false if the reward is invalid, otherwise nil.
]]
function phone_rewards.give_reward(pl_name, premium, level)
	local collected_rewards = phone_rewards.get_collected_rewards(pl_name)

	if
		level < 1 or level > #phone_rewards.rewards or
		(premium and collected_rewards[pl_name].premium[level]) or
		(not premium and collected_rewards[pl_name].normal[level])
	then
		return false
	end

	local reward = premium and phone_rewards.rewards[level].premium or phone_rewards.rewards[level].normal

	if reward.type == "skin" then
		collectible_skins.unlock_skin(pl_name, reward.value)
	elseif reward.type == "item" then
		local player = minetest.get_player_by_name(pl_name)
		player:get_inventory():add_item("main", ItemStack(reward.value))
	end

	if premium then
		collected_rewards[pl_name].premium[level] = true
	else
		collected_rewards[pl_name].normal[level] = true
	end

	phone_rewards.set_collected_rewards(pl_name, collected_rewards)
end



--[[
	Checks if a player has the premium privilege.
	@param pl_name The name of the player.
	@return true if the player has the premium privilege, false otherwise.
]]
function phone_rewards.is_premium(pl_name)
	return minetest.get_player_privs(pl_name)[phone_rewards.premium_priv]
end



--[[
	Resets the levels and collected rewards for all players.
]]
function phone_rewards.reset_levels()
	local storage_table = storage:to_table() or {}
	local string_match = string.match

	for record_key, points in pairs(storage_table.fields) do
		if string_match(record_key, "phone_rewards:points|") then
			local pl_name = string.split(record_key, "|")[2]
			if tonumber(points) ~= 0 then
				phone_rewards.set_points(pl_name, 0)
				phone_rewards.set_collected_rewards(pl_name, {})
			end
		end
	end
end

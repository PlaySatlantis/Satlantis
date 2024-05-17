local function remove_userdata(t) end
local function keep_just_data(t) end

local storage = minetest.get_mod_storage()

--[[
    {
        "player": {
            {"mod:skill1" = {...}},
            {"mod:skill2" = {...}}
        }
    }
--]]
skills.player_skills = {}



minetest.register_on_mods_loaded(function()
	skills.update_db()
end)



-- setting player objectref pointer to nil when they leave
minetest.register_on_leaveplayer(function (player, timed_out)
	local pl_name = player:get_player_name()
	minetest.after(0, function () -- to execute this callback after the other ones
		for name, def in pairs(skills.player_skills[pl_name]) do
			def.player = nil
		end
	end)
end)



minetest.register_on_joinplayer(function (player)
	local pl_name = player:get_player_name()

	skills.import_player_from_db(pl_name)

	-- setting the player objectref skills pointers
	for name, def in pairs(skills.player_skills[pl_name]) do
		def.player = player
	end
end)



function skills.update_db(just_once, end_callback, total_transactions, pl_data)
	local max_db_transactions_per_step = 20
	local transactions = 0
	total_transactions = total_transactions or 0

	pl_data = pl_data or table.copy(skills.player_skills)
	if total_transactions == 0 then keep_just_data(pl_data) end

	-- save at most max_db_transactions_per_step records
	-- and call this function again after one step if
	-- there are more
	local i = 0
	for pl_name, data in pairs(pl_data) do
		i = i + 1

		if transactions == max_db_transactions_per_step then
			total_transactions = total_transactions + transactions

			minetest.after(0, function ()
				skills.update_db(just_once, end_callback, total_transactions, pl_data)
			end)

			return
		end

		if i > total_transactions then -- avoid saving again the same records
			storage:set_string("pl_data:"..pl_name, minetest.serialize(data))
			transactions = transactions + 1
		end
	end

	if end_callback then end_callback() end

	if not just_once then
		minetest.after(10, skills.update_db)
	end
end



function skills.import_player_from_db(pl_name)
	if skills.player_skills[pl_name] then
		return skills.player_skills[pl_name]
	end

	skills.player_skills[pl_name] = minetest.deserialize(storage:get_string("pl_data:"..pl_name)) or {}

	for skill_name, data in pairs(skills.player_skills[pl_name]) do
		if not skills.construct_player_skill(pl_name, skill_name) then
			-- if the skill became a layer, remove it
			skills.player_skills[pl_name][skill_name] = nil
		end
	end

	return skills.player_skills[pl_name]
end



-- calls callback(pl_name, skills) for each player in the DB
function skills.for_each_player_in_db(callback)
	local storage_table = storage:to_table()
	local string_match = string.match

	for record_key, value in pairs(storage_table.fields) do
		if string_match(record_key, "pl_data:") then
			local pl_name = record_key:gsub("pl_data:", "")
			callback(pl_name, skills.import_player_from_db(pl_name))
		end
	end

	skills.update_db("just_once", function ()
		-- removing offline players from player_skills
		local is_online = minetest.get_player_by_name
		for pl_name, _ in pairs(skills.player_skills) do
			if not is_online(pl_name) then
				skills.player_skills[pl_name] = nil
			end
		end
	end)
end



function skills.remove_unregistered_skills_from_db()
	skills.for_each_player_in_db(function (pl_name, pl_skills)
		for skill_name, def in pairs(pl_skills) do
			if not skills.get_skill_def(skill_name) then pl_skills[skill_name] = nil end
		end
	end)
end



function remove_userdata(t)
	for key, value in pairs(t) do
		if type(value) == "table" then remove_userdata(value) end
		if minetest.is_player(value) or type(value) == "userdata" or type(value) == "function" then t[key] = nil end
	end
end



function keep_just_data(t)
	for pl_name, skills in pairs(t) do
		for name, table in pairs(skills) do
			for key, value in pairs(table) do
				if key ~= "data" then
					table[key] = nil
				else
					remove_userdata(table.data)
				end
			end
		end
	end
end
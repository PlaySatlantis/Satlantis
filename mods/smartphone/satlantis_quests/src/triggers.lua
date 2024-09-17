local storage = minetest.get_mod_storage()




minetest.register_privilege("premium", {
    give_to_singleplayer = false
})

awards.register_trigger("premiumjoin", {
	type             = "counted",
    progress         = "@1/@2 joins",
	auto_description = { "Daily login", "Daily login" }
})


minetest.register_on_joinplayer(function(player, last_login)
    local pl_name = player:get_player_name()
    local last_joined_day = storage:get_string("last_joined_day|"..pl_name)
    local today = tostring(os.date("*t").yday)

    if minetest.check_player_privs(player, "premium") and last_joined_day ~= today then
        awards.remove(pl_name, "satlantis_quests:daily_login")
        awards.notify_premiumjoin(player)
        storage:set_string("last_joined_day|"..pl_name, today)
    elseif last_joined_day ~= today then
        awards.remove(pl_name, "satlantis_quests:daily_login")
        storage:set_string("last_joined_day|"..pl_name, "")
    end

    local daily_quests = phone_quests.daily_quests

    local day = phone_quests.days_since_date(phone_quests.start_day)
    local last_joined_day_quest = tonumber(storage:get_string("last_joined_day_quest|"..pl_name))

    local data = awards.player(pl_name)

    if last_joined_day_quest ~= day then
        local quests_to_modify = daily_quests[(day % #daily_quests) + 1]
        for index, quest in pairs(quests_to_modify) do
            data.unlocked[quest] = nil
            
            if awards.registered_awards[quest].trigger.type == "fantasybrawl_kills" and data[awards.registered_awards[quest].trigger.type] ~= nil then
                local award_counter = awards.get_item_count(data, awards.registered_awards[quest].trigger.type, awards.registered_awards[quest].trigger.node) * -1
                awards.notify_fantasybrawl_kills(player, "Fantasy Brawl", award_counter)
                awards.save()
            elseif awards.registered_awards[quest].trigger.type == "arenalib_wins" and data[awards.registered_awards[quest].trigger.type] ~= nil then
                local award_counter = awards.get_item_count(data, awards.registered_awards[quest].trigger.type, awards.registered_awards[quest].trigger.node) * -1
                awards.notify_arenalib_wins(player, "Fantasy Brawl", award_counter)
                awards.save()
            else
                if data[awards.registered_awards[quest].trigger.type] ~= nil then
                    local award_counter = awards.get_item_count(data, awards.registered_awards[quest].trigger.type, awards.registered_awards[quest].trigger.node) * -1
                    awards.increment_item_counter(data, awards.registered_awards[quest].trigger.type, awards.registered_awards[quest].trigger.node, award_counter)
                end
                awards.save()
            end
            
        end
    end

    storage:set_string("last_joined_day_quest|"..pl_name, tostring(day))

    local week = math.floor(day / 7)
    local last_joined_week_quest = storage:get_string("last_joined_week_quest|"..pl_name)

    if last_joined_week_quest ~= week then
        local weekly_quests = phone_quests.weekly_quests
        local quests_to_modify = weekly_quests[((week) % #weekly_quests) + 1]
        for index, quest in pairs(quests_to_modify) do
            data.unlocked[quest] = nil
            
            if awards.registered_awards[quest].trigger.type == "fantasybrawl_kills" and data[awards.registered_awards[quest].trigger.type] ~= nil then
                local award_counter = awards.get_item_count(data, awards.registered_awards[quest].trigger.type, awards.registered_awards[quest].trigger.node) * -1
                awards.notify_fantasybrawl_kills(player, "Fantasy Brawl", award_counter)
                awards.save()
            elseif awards.registered_awards[quest].trigger.type == "arenalib_wins" and data[awards.registered_awards[quest].trigger.type] ~= nil then
                local award_counter = awards.get_item_count(data, awards.registered_awards[quest].trigger.type, awards.registered_awards[quest].trigger.node) * -1
                awards.notify_arenalib_wins(player, "Fantasy Brawl", award_counter)
                awards.save()
            else
                if data[awards.registered_awards[quest].trigger.type] ~= nil then
                    local award_counter = awards.get_item_count(data, awards.registered_awards[quest].trigger.type, awards.registered_awards[quest].trigger.node) * -1
                    awards.increment_item_counter(data, awards.registered_awards[quest].trigger.type, awards.registered_awards[quest].trigger.node, award_counter)
                end
                awards.save()
            end
        end
    end

    storage:set_string("last_joined_week_quest|"..pl_name, week)
end)




awards.register_trigger("arenalib_wins", {
	type             = "counted_key",
    progress         = "@1/@2 wins",
	auto_description = { "Win @2", "Win @2 @1 times"},
	auto_description_total = { "Win one time.", "Win @1 times"},
	get_key = function(self, def)
		return def.trigger.game
	end,
})



awards.register_trigger("fantasybrawl_kills", {
	type             = "counted_key",
    progress         = "@1/@2 kills",
	auto_description = { "Kill @2", "Kill @2 @1 times"},
	auto_description_total = { "Kill one player", "Kill @1 players"},
    get_key = function(self, def)
		return def.trigger.game
	end
})



arena_lib.register_on_celebration(function(mod, arena, winners)
    if mod ~= "fantasy_brawl" then return end

    if type(winners) == "string" then
        awards.notify_arenalib_wins(minetest.get_player_by_name(winners), "Fantasy Brawl")
    end

    for pl_name, pl_data in pairs(arena.players) do
        local player = minetest.get_player_by_name(pl_name)

        for i = 1, pl_data.kills do
            awards.notify_fantasybrawl_kills(player, "Fantasy Brawl")
        end
    end
end)



function awards.remove(name, award)
	local data  = awards.player(name)
	local awdef = awards.registered_awards[award]
	assert(awdef, "Unable to remove an award which doesn't exist!")

	if data.disabled or
			(not data.unlocked[award]) then
		return
	end

	minetest.log("action", "Award " .. award .." has been removed from ".. name)
	data.unlocked[award] = nil
	awards.save()
end
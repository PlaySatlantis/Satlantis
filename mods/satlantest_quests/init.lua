local quests = {}

quests.registered_quests = {}

quests.get_quest_data = function(player, key)
    return player:get_meta():get("satlantis:quest:" .. key)
end

quests.set_quest_data = function(player, key, value)
    player:get_meta():set_string("satlantis:quest:" .. key, value)
end

quests.new_callback = function(name)
    quests["quests_" .. name] = {}

    return function(...)
        for _, quest in pairs(quests["quests_" .. name]) do
            quest.callbacks[name](quest, ...)
        end
    end
end

minetest.register_on_dignode(quests.new_callback("on_dignode"))
minetest.register_on_placenode(quests.new_callback("on_placenode"))
satlantis.register_on_entity_death(quests.new_callback("on_entity_death"))

--[[

{
    callbacks = {
        on_dignode = function(quest, pos, node, player)

        end,
    }
}

]]--

quests.register_quest = function(name, definition)
    definition.name = name
    quests.registered_quests[name] = definition

    for callback_name in pairs(definition.callbacks or {}) do
        print("Registered quest " .. name .. "." .. callback_name)
        quests["quests_" .. callback_name][name] = quests.registered_quests[name]
    end
end

satlantis.quests = quests

--[[ TEST QUESTS ]]--

satlantis.register_entity("satlantest_quests:test", {
    initial_properties = {
        textures = {"ignore.png^[invert:rgb"},
    },
})

minetest.register_node("satlantest_quests:test", {
    tiles = {"ignore.png^[invert:rgb"},
    groups = {breakable = 1},
    tool_capabilities = {
        full_punch_interval = 1.0,
        damage_groups = {fleshy = 10},
    },
})

--[[
TODO:
* Quest builder (no code)
* Rewards
]]--
satlantis.quests.register_quest("kill_test_entity", {
    callbacks = {
        on_entity_death = function(_, entity, killer)
            if killer and entity.name == "satlantest_quests:test" then
                local kills = tonumber(satlantis.quests.get_quest_data(killer, "kill_test_entity")) or 0
                satlantis.quests.set_quest_data(killer, "kill_test_entity", tostring(kills + 1))

                if kills >= 10 then
                    satlantis.quests.set_quest_data(killer, "kill_test_entity", "")
                    minetest.chat_send_player(killer:get_player_name(), "QUEST: kill_test_entity COMPLETE")
                end
            end
        end
    }
})

satlantis.quests.register_quest("place_test_node", {
    callbacks = {
        on_placenode = function(_, _, node, placer)
            if placer and node.name == "satlantest_quests:test" then
                local places = tonumber(satlantis.quests.get_quest_data(placer, "place_test_node")) or 0
                satlantis.quests.set_quest_data(placer, "place_test_node", tostring(places + 1))

                if places >= 10 then
                    satlantis.quests.set_quest_data(placer, "place_test_node", "")
                    minetest.chat_send_player(placer:get_player_name(), "QUEST: place_test_node COMPLETE")
                end
            end
        end
    }
})

satlantis.quests.register_quest("dig_test_node", {
    callbacks = {
        on_dignode = function(_, _, node, digger)
            if digger and node.name == "satlantest_quests:test" then
                local digs = tonumber(satlantis.quests.get_quest_data(digger, "dig_test_node")) or 0
                satlantis.quests.set_quest_data(digger, "dig_test_node", tostring(digs + 1))

                if digs >= 10 then
                    satlantis.quests.set_quest_data(digger, "dig_test_node", "")
                    minetest.chat_send_player(digger:get_player_name(), "QUEST: dig_test_node COMPLETE")
                end
            end
        end
    }
})

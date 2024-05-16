minetest.register_privilege("premium", {
    give_to_singleplayer = false
})

awards.register_trigger("premiumjoin", {
	type             = "counted",
    progress         = "@1/@2 joins",
	auto_description = { "Daily login", "Daily login" }
})



minetest.register_on_joinplayer(function(player, last_login)
    if minetest.check_player_privs(player, "premium") then
        awards.notify_premiumjoin(player)
    end
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
	type             = "counted",
    progress         = "@1/@2 kills",
	auto_description = { "Kill @2", "Kill @2 @1 times"},
	auto_description_total = { "Kill one player", "Kill @1 players"},
})



arena_lib.register_on_celebration(function(mod, arena, winners)
    if mod ~= "fantasy_brawl" then return end

    if type(winners) == "string" then
        awards.notify_arenalib_wins(minetest.get_player_by_name(winners), "Fantasy Brawl")
    end

    for pl_name, pl_data in pairs(arena.players) do
        local player = minetest.get_player_by_name(pl_name)

        for i = 1, pl_data.kills do
            awards.notify_fantasybrawl_kills(player)
        end
    end
end)
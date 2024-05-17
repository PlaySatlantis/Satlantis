--!
--! DON'T TOUCH THIS.
--!
--! if you want to modify any of these settings just edit the file in <YOUR_WORLD_FOLDER>/phone_quests/


phone_quests.daily_quests = {
	-- day one (max 31)
	[1] = {
		[1] = "satlantis_quests:daily_login",
		[2] = "satlantis_quests:dig_larkspur",
		[3] = "satlantis_quests:craft_afzelia_wood",
	},
	-- day two
	[2] = {
		[1] = "satlantis_quests:daily_login",
	}
	-- day three is not declared, so the mod will display day one again
	-- day four is not declard, so the mod will display day two again, and so on...
}

phone_quests.weekly_quests = {
	-- week one (max 5)
	[1] = {
		[1] = "satlantis_quests:arena_win_fantasybrawl",
		[2] = "satlantis_quests:place_steel",
	},
	-- week two
	[2] = {
		[1] = "satlantis_quests:arena_win_fantasybrawl",
	}
	-- week three is not declared, so the mod will display week one again
	-- week four is not declard, so the mod will display week two again, and so on...
}
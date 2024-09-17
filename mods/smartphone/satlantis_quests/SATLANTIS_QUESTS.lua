--!
--! DON'T TOUCH THIS.
--!
--! if you want to modify any of these quests, or add more, just edit the file in <YOUR_WORLD_FOLDER>/satlantis_quests/

awards.register_award("satlantis_quests:arena_win_fantasybrawl", {
	title = "Win in Fantasy Brawl",
	description = "Win 3 times in Fantasy Brawl",
	trigger = {
		type   = "arenalib_wins",
		game   = "Fantasy Brawl",
		target = 3
	},
	points = 50,
})



awards.register_award("satlantis_quests:arena_kills_fantasybrawl", {
	title = "Kills in Fantasy Brawl",
	description = "Perform 30 kills in Fantasy Brawl",
	trigger = {
		type   = "fantasybrawl_kills",
		game   = "Fantasy Brawl",
		target = 21
	},
	points = 50,
})



awards.register_award("satlantis_quests:craft_afzelia_wood", {
	title = "Craft wood",
	description = "Craft 256 Afzelia wood planks",
	trigger = {
		type   = "craft",
		item   = "ebiomes:afzelia_wood",
		target = 256,
	},
	points = 50,
})



awards.register_award("satlantis_quests:place_steel", {
	title = "Steel blocks",
	description = "Place 64 steel blocks",
	trigger = {
		type   = "place",
		node   = "default:steelblock",
		target = 64,
	},
	points = 50,
})



awards.register_award("satlantis_quests:dig_larkspur", {
	title = "Dig larkspur flowers",
	description = "Dig 24 larkspur flowers",
	trigger = {
		type   = "dig",
		node   = "ebiomes:larkspur",
		target = 24,
	},
	points = 50,
})



awards.register_award("satlantis_quests:eat_roastedchestnuts", {
	title = "Eat roasted chestnuts",
	description = "Eat 10 roasted chestnuts",
	trigger = {
		type   = "eat",
		item   = "ebiomes:chestnuts_roasted",
		target = 10,
	},
	points = 50,
})



awards.register_award("satlantis_quests:daily_login", {
	title = "Premium login",
	description = "Collect your daily login",
	trigger = {
		type   = "premiumjoin",
		target = 1,
	},
	points = 50,
})

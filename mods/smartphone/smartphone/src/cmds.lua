minetest.register_chatcommand("smartphone", {
	func = function(name, param)
		smartphone.open_smartphone(minetest.get_player_by_name(name))
	end
})
minetest.register_chatcommand("reset_battlepass", {
	func = function(name, param)
		phone_rewards.reset_levels()
		minetest.chat_send_player(name, "Battlepass reset!")
	end,
	description = "An admin command to reset the battlepass points and claimed rewards for every player.",
	privs = {server = true}
})
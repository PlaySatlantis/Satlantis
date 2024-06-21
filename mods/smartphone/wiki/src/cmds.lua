minetest.register_chatcommand("update_wiki", {
	func = function(name, param)
		wiki.fmspecs_cache = {}
		minetest.chat_send_player(name, "Wiki updated!")
	end,
	description = "An admin command to update the wiki pages to the latest files in the `<YOUR_WORLD_FOLDER>/wiki/` folder.",
	privs = {server = true}
})
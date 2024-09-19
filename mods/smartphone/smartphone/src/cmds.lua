minetest.register_chatcommand("smartphone", {
	func = function(name, param)
		smartphone.open_smartphone(minetest.get_player_by_name(name))
	end
})

minetest.register_on_prejoinplayer(function(player, last_login)
	local cmd_name
	for technical_name, def in pairs(smartphone.apps) do
		cmd_name = def.cmd_name
		for i = 1, #cmd_name do
			minetest.register_chatcommand(cmd_name[i], {description="Opens the"..def.name.."-app on your smartphone.",
				func = function(name, param)
					smartphone.open_smartphone(minetest.get_player_by_name(name))
					smartphone.open_app(minetest.get_player_by_name(name), technical_name)
				end
			})
		end
	end
end)
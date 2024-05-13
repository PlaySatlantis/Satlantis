
ChatCmdBuilder.new("debug", function(cmd)
	cmd:sub("ultimate", function(name)
		local arena = arena_lib.get_arena_by_player(name)
		arena.players[name].ultimate_recharge = 5
	end)
end)


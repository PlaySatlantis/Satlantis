function smartphone.error(pl_name, msg)
	minetest.chat_send_player(pl_name, minetest.colorize("#f47e1b", "[!] " .. msg))
	--minetest.sound_play("smartphone_error", {to_player = pl_name})
end


function smartphone.print(pl_name, msg)
	minetest.chat_send_player(pl_name, msg)
end

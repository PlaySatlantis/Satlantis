-- preventing formspec callbacks from running if the player doesn't have the
-- required priv
minetest.register_on_player_receive_fields(function(player, formname, fields)
	local pl_name = player:get_player_name()
	local app = smartphone.get_app(formname)

	if app and app.priv_to_open and not minetest.get_player_privs(pl_name)[app.priv_to_open] then
		smartphone.error(pl_name, "You can't open the "..app.name.." app!")
		return true
	end

	return false
end)
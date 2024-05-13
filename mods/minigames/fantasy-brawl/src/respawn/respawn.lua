dofile(minetest.get_modpath("fantasy_brawl") .. "/src/respawn/respawn_hand.lua")
dofile(minetest.get_modpath("fantasy_brawl") .. "/src/respawn/anchor_entity.lua")



function fbrawl.respawn_player(pl_name)
	local player = minetest.get_player_by_name(pl_name)
	local spawn_pos = player:get_pos() + {x=0, y=1, z=0}
	minetest.add_entity(spawn_pos, "fantasy_brawl:anchor", pl_name)
end
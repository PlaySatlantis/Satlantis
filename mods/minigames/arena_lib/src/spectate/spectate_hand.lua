-- This is just an extra-safety measure: by default players in spectate can't
-- access their inventory to move items around, and every slot in the hotbar is
-- filled with something (so they'll never see the spectate hand). However, if
-- some mod inadvertently clears the inventory, or if some admin runs a /clearinv
-- command, the spectator can interfer with the mini-game or, even worse, make
-- the server crash. Better be safe!
minetest.register_node("arena_lib:spectate_hand", {
  description = "Spectate hand",
  wield_image = "arenalib_infobox_spectate.png",
  range = 0,
  groups = {not_in_creative_inventory = 1}
})

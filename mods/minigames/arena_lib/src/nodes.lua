local S = minetest.get_translator("arena_lib")



minetest.register_node("arena_lib:barrier", {
  description = S("Barrier"),
  drawtype = "airlike",
  paramtype = "light",
  sunlight_propagates = true,
  drop = "",
  inventory_image = "arenalib_node_barrier.png",
  wield_image = "arenalib_node_barrier.png",
  groups = {oddly_breakable_by_hand = 2},
  can_dig = function(pos, player)
    return minetest.get_player_privs(player:get_player_name()).arenalib_admin
  end
})

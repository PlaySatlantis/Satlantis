local S = minetest.get_translator("collectible_skins")

minetest.register_tool("collectible_skins:wardrobe", {

  description = S("Wardrobe"),
  inventory_image = "cskins_wardrobe.png",
  groups = {oddly_breakable_by_hand = "2"},
  on_place = function() end,
  on_drop = function() end,

  on_use = function(itemstack, user, pointed_thing)
    local p_name = user:get_player_name()
    minetest.show_formspec(p_name, "collectible_skins:GUI", collectible_skins.get_formspec(p_name, 1, collectible_skins.get_player_skin(p_name).technical_name))
  end

})

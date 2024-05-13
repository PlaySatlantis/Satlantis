local S = fbrawl.T



fbrawl.register_weapon("fantasy_brawl:mage_staff", {
  mesh = "fbrawl_mage_staff.obj",
  texture = "fbrawl_mage_staff_model.png",
  groups = {fbrawl_mesh = 1},
  wield_scale = {x=3.7,y=3.7, z=3.7},
})



minetest.register_craftitem("fantasy_brawl:cry_of_gaia", {
  inventory_image = "fbrawl_transparent.png",
  wield_image = "fbrawl_cry_of_gaia_skill.png",
  on_drop = function() return end,
  on_use =
    function(itemstack, player)
      local pl_name = player:get_player_name()
      local ray = fbrawl.look_raycast(player, 200)
      local crush_point = ray:next() or {}
      crush_point = crush_point.above
      
      if not crush_point then
        skills.error(pl_name, S("You can't point it in the sky!"))
        return
      end

      fbrawl.cast_ultimate(pl_name, "fbrawl:cry_of_gaia", {called_by_proxy = true})
      pl_name:stop_skill("fbrawl:aoe_proxy")
    end
})



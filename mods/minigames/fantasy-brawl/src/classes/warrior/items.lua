local S = fbrawl.T



fbrawl.register_weapon("fantasy_brawl:sword_steel", {
   mesh = "fbrawl_warrior_sword.obj",
   texture = "fbrawl_warrior_sword_model.png",
   wield_scale = {x=4,y=4,z=4},
   groups = {fbrawl_mesh = 1, sword = 1},
   tool_capabilities = {
		full_punch_interval = 0.8,
		damage_groups = {fleshy=2*20},
	}
})



minetest.register_craftitem("fantasy_brawl:hero_fury", {
   description = S("Unleash the fury of the strongest warrior alive!"),
   inventory_image = "fbrawl_transparent.png",
   wield_image = "fbrawl_hero_fury_skill.png",
   tool_capabilities = {
		full_punch_interval = 1,
		damage_groups = {fleshy=-0.5},
	},
   on_drop = function() return end,
})



minetest.register_on_punchplayer(function(player, hitter)
   local pl_name = hitter:get_player_name()
   local wielded_item = hitter:get_wielded_item():get_name()

   if wielded_item == "fantasy_brawl:hero_fury" then
      fbrawl.cast_ultimate(pl_name, "fbrawl:hero_fury", {
         hit_pl_name = player:get_player_name(),
         called_by_proxy = true
      })
      pl_name:stop_skill("fbrawl:item_proxy")
   end
end)

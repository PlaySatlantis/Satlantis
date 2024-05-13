local S = fbrawl.T



skills.register_skill("fbrawl:iron_skin", {
   name = S("Iron Skin"),
   description = S("The damage you take is halved for @1 seconds since you cast the skill.", 6),
   icon = "fbrawl_iron_skin_skill.png",
   slot = 3,
   cooldown = 20,
   loop_params = {
      duration = 8,
   },
   sounds = {
      start = {name = "iron_skin_on", max_hear_distance = 6},
      stop = {name = "iron_skin_off", max_hear_distance = 6},
   },
   attachments = {
      entities = {{
         name = "fantasy_brawl:iron_skin",
         pos = {x = 0, y = 22, z = 0}
      }}
   },
   hud = {{
      name = "shield",
      hud_elem_type = "image",
      text = "fbrawl_iron_skin_skill.png",
      scale = {x=3, y=3},
      position = {x=0.5, y=0.72},
   }},
})



minetest.register_on_player_hpchange(function(player, hp_change, reason) 
   local pl_name = player:get_player_name()
   local iron_skin_skill = pl_name:get_skill("fbrawl:iron_skin")

   if iron_skin_skill and iron_skin_skill.is_active and player:get_hp() > 2 then
      return hp_change / 2
   else
      return hp_change
   end
end, true)



----------------------
-- IRON SKIN ENTITY -- 
----------------------

local iron_skin = {
   initial_properties = {
      hp_max = 999,
      physical = false,
      visual_size = {x = 0.35, y = 0.35},
      textures = {"fbrawl_iron_skin_skill.png"},
      pointable = false,
      visual = "sprite",
      glow = 1
   },
}



function iron_skin:on_activate(pl_name, dtime_s)
   if pl_name == "" then
      self.object:remove()
   end
end



minetest.register_entity("fantasy_brawl:iron_skin", iron_skin)

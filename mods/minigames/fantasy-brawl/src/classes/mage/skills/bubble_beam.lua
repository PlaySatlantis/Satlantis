local S = fbrawl.T



skills.register_skill("fbrawl:bubble_beam", {
   name = S("Bubble Beam"),
   description = S("Generates a bubble beam that strikes at medium to long distances."),
   slot = 1,
   cooldown = 0.4,
   icon = "fbrawl_bubblebeam_skill.png",
   sounds = {
      cast = {name = "fbrawl_bubble_beam", max_hear_distance = 12, gain = 0.6},
   },
   cast = function(self) 
      local cast_starting_pos = vector.add({x=0, y=1, z=0}, self.player:get_pos())

      minetest.add_entity(cast_starting_pos, "fantasy_brawl:bubble_beam", self.pl_name)
   end
})



-- The bubble entity declaration.
local bubble_beam = {
   initial_properties = {
      hp_max = 999,
      physical = true,
      collide_with_objects = false,
      collisionbox = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
      visual = "sprite",
      visual_size = {x = 1, y = 1},
      textures = {"fbrawl_bubble_entity.png"},
      initial_sprite_basepos = {x = 0, y = 0},
      speed = 50,
      range = 1.8,
      damage = 1.5
   },
   time_passed = 0,
	lifetime = 0.8,
   pl_name = "",
   hit = false
}



-- staticdata = player's username.
function bubble_beam:on_activate(staticdata, dtime_s)
   local obj = self.object

   if staticdata then
      self.pl_name = staticdata
      local player = minetest.get_player_by_name(self.pl_name)

      if not player then 
         obj:remove()
         return
      end

      local dir = player:get_look_dir()
      local bubble_props = self.initial_properties

      obj:set_velocity({
         x=(dir.x * bubble_props.speed),
         y=(dir.y * bubble_props.speed),
         z=(dir.z * bubble_props.speed),
      })
   else
      obj:remove()
      return
   end

   minetest.add_particlespawner({
      amount = 40,
      time = 0,
      minpos = {x = -0.2, y =  0, z = -0.2},
      maxpos = {x = 0.2, y = 0.2, z = 0.2},
      minvel = {x = 0, y =  -0.3, z = 0},
      maxvel = {x = 0, y = -0.3, z = 0},
      minsize = 4,
      maxsize = 5,
      texture = {
         name = "fbrawl_bubble_entity.png",
         alpha_tween = {1, 0}
      },
      minexptime = 1.5,
      maxexptime = 1.5,
      attached = obj
   })
end



function bubble_beam:remove()
   local sound = {name = "fbrawl_bubble_beam_hit", pos = self.object:get_pos(), max_hear_distance = 16}
   minetest.sound_play(sound, sound, true)
   
   minetest.add_particlespawner({
      amount = 30,
      time = 0.3,
      minvel = {x = -2, y =  -2, z = -2},
      maxvel = {x = 2, y = 2, z = 2},
      minsize = 4,
      maxsize = 5,
      texture = {
         name = "fbrawl_bubble_entity.png",
         alpha_tween = {1, 0}
      },
      minexptime = 0.7,
      maxexptime = 1.3,
      pos = self.object:get_pos(),
      physical = true
   })

   self.object:remove()
end



function bubble_beam:on_step(dtime, moveresult)
   local player = minetest.get_player_by_name(self.pl_name)
   local props = self.initial_properties
	self.time_passed = self.time_passed + dtime

   if not player or moveresult.collides == true then
      self:remove()
      return
   end

   if self.time_passed >= self.lifetime then
      self.object:remove()
      return
   end

   fbrawl.damage_players_near(player, self.object:get_pos(), props.range, props.damage, nil, function ()
      if self and not self.hit then
         self.hit = true
         self:remove()
      end
   end)
      
end



minetest.register_entity("fantasy_brawl:bubble_beam", bubble_beam)



controls.register_on_hold(function(player, control_name, time)
	local pl_name = player:get_player_name()
   local wielded_item = player:get_wielded_item():get_name()
   local bubble_beam = pl_name:get_skill("fbrawl:bubble_beam")

   if 
      bubble_beam
      and 
      wielded_item == "fantasy_brawl:mage_staff"
      and
      control_name == "LMB"
   then
      bubble_beam:cast()
   end
end)

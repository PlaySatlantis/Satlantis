local S = fbrawl.T



skills.register_skill("fbrawl:warrior_jump", {
   name = S("Warrior's Jump"),
   icon = "fbrawl_smash_skill.png",
   description = S("Jump very high to then land on their heads and  c r u s h  them!"),
   slot = 2,
   jump_force = 25,
   cooldown = 10,
   sounds = {
      cast = {name = "wjump", max_hear_distance = 6}
   },
   cast = function(self)
      local push_force = vector.multiply(self.player:get_look_dir(), self.jump_force)
      push_force.y = self.jump_force
      self.player:add_velocity(push_force)

      minetest.add_particlespawner({
         amount = 40,
         time = 0.5,
         minpos = vector.add(self.player:get_pos(), {x=0, y=0.5, z=0}),
         maxpos = self.player:get_pos(),
         minvel = {x = -4,y =  0, z = -4},
         maxvel = {x = 4, y = 0, z = 4},
         minsize = 8,
         maxsize = 10,
         texture = {
            name = "fbrawl_smoke_particle.png",
            alpha_tween = {1, 0},
            scale_tween = {
               {x = 0.2, y = 0.2},
               {x = 1, y = 1},
           }
         },
         minexptime = 0.5,
         maxexptime = 0.5,
      })

      self.pl_name:unlock_skill("fbrawl:smash")

      -- v in case it crashed the last match
      self.pl_name:get_skill("fbrawl:smash").data.started = false
      minetest.after(0.2, function ()
         self.pl_name:start_skill("fbrawl:smash")
      end)

      return true
   end,
})



skills.register_skill("fbrawl:smash", {
   name = "fbrawl:smash",
   slot = 2,
   damage = 4,
   range = 6,
   slow_down_factor = 0.5,
   slow_down_time = 2,
   sounds = {
      bgm = {name="while_jumping", max_hear_distance = 6},
      stop = {name="smash", max_hear_distance = 6}
   },
   data = {
      hit_players = {},
      started = false,
   },
   loop_params = {
      cast_rate = 0
   },
   attachments = {
      particles = {
      {
         amount = 35,
         time = 0,
         minpos = {x = -0.3, y =  0, z = -0.3},
         maxpos = {x = 0.3, y = 1.5, z = 0.3},
         minvel = {x = 0, y =  0, z = -1},
         maxvel = {x = 0, y = 0, z = -2},
         minsize = 4,
         maxsize = 9,
         texture = {
            name = "fbrawl_smoke_particle.png",
            alpha_tween = {1, 0}
         },
         minexptime = 1.5,
         maxexptime = 1.5,
      },
      {
         amount = 50,
         time = 0,
         minpos = {x = -0.3, y =  0, z = -0.3},
         maxpos = {x = 0.3, y = 1.5, z = 0.3},
         minvel = {x = 0, y =  0, z = -1},
         maxvel = {x = 0, y = 0, z = -2},
         minsize = 4,
         maxsize = 9,
         texture = {
            name = "fbrawl_wjump_particle.png",
            alpha_tween = {1, 0}
         },
         minexptime = 1.5,
         maxexptime = 1.5,
      }
      }
   },
   
   go_down = function(self)
      local jump_skill = self.pl_name:get_skill("fbrawl:warrior_jump")
      local fall_force = -jump_skill.jump_force * 2
      self.player:add_velocity({x = 0, y = fall_force, z = 0})
   end,

   on_start = function(self) 
      self.data.hit_players = {}
      self.data.started = false
      arena_lib.HUD_send_msg("broadcast", self.pl_name, S("Sneak again to fall down"))
   end,

   on_stop = function(self)
      local range = vector.new(self.range, 2, self.range)
      fbrawl.damage_players_near(self.player, self.player:get_pos(), range, self.damage, nil, function(hit_pl_name)
         local hit_pl = minetest.get_player_by_name(hit_pl_name)

         -- Slow the hit player down
         skills.sub_physics(hit_pl_name, "speed", self.slow_down_factor)
         table.insert(self.data.hit_players, hit_pl:get_player_name())
      end)

      minetest.add_entity(self.player:get_pos(), "fantasy_brawl:seismic_wave", self.pl_name)

      minetest.after(self.slow_down_time, function()
         for i, pl_name in ipairs(self.data.hit_players) do
            local player = minetest.get_player_by_name(pl_name)

            if player then
               skills.add_physics(pl_name, "speed", self.slow_down_factor)
            end
         end
      end)

      arena_lib.HUD_hide("broadcast", self.pl_name)

      self.data.started = false
   end,

   cast = function(self)
      if self.player:get_hp() <= 0 then 
			self:stop()
			return
		end

      if fbrawl.is_on_the_ground(self.player) and self.data.started then
         self:stop()
      elseif not fbrawl.is_on_the_ground(self.player) then
         self.data.started = true
      end
   end,
})



controls.register_on_press(function(player, control_name)
	local pl_name = player:get_player_name()
   local smash = pl_name:get_skill("fbrawl:smash")

	if not fbrawl.is_player_playing(pl_name) or not smash then
		return
	end

   if smash.data.started and control_name == "sneak" then
      smash:go_down()
   end
end)



-------------------------
-- SEISMIC WAVE ENTITY -- 
-------------------------

local seismic_wave = {
   initial_properties = {
      hp_max = 999,
      physical = false,
      collisionbox = {-1, -1, -1, 1, 1.0, 1},
      visual_size = {x = 1, y = 0.2},
      textures = {
         "fbrawl_wave_entity.png", "fbrawl_transparent.png", 
         "fbrawl_transparent.png", "fbrawl_transparent.png", 
         "fbrawl_transparent.png", "fbrawl_transparent.png"
      },
      initial_sprite_basepos = {x = 0, y = 0},
      pointable = false,
      visual = "cube",
   },
   dropped = false,
   duration = 0.6,
   speed = 11.3,
   damage = 2,
   counter = 0
}



function seismic_wave:on_activate(pl_name, dtime_s)
   local obj = self.object

   if pl_name then
      minetest.after(self.duration, function() if obj then obj:remove() end end)
   else
      obj:remove()
   end
end



function seismic_wave:on_step(dtime)
   local increase_per_step = self.speed * dtime 
   local props = self.object:get_properties()

   self.counter = self.counter + dtime

   if self.counter > 0.3 then
      local new_wave = minetest.add_entity(self.object:get_pos(), "fantasy_brawl:seismic_wave", self.pl_name)
      new_wave:get_luaentity().counter = -10
      self.counter = 0
   end

   props.visual_size = vector.add(props.visual_size, increase_per_step)
   props.visual_size.y = 0.2

   self.object:set_properties(props)
end



minetest.register_entity("fantasy_brawl:seismic_wave", seismic_wave)

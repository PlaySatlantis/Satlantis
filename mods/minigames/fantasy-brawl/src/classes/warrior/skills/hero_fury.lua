local function hit(player, hit_player, offset, last) end
local S = fbrawl.T



skills.register_skill_based_on({"fbrawl:ulti_layer", "fbrawl:proxy_layer"}, "fbrawl:hero_fury", {
   name = S("Hero's Fury"),
   icon = "fbrawl_hero_fury_skill.png",
   description = S("Unleash the fury of a war hero: throw the enemy in the sky and punch them to death. Brr... Merciless."),
   loop_params = {
      cast_rate = 0.2,
   },
   blocks_other_skills = true,
   damage = 2,
   slot = 4,
   upward_force = 60,
   punch_force = 30,

	proxy = {
		name = "fbrawl:item_proxy",
		args = {
         item = "fantasy_brawl:hero_fury",
         broadcast = S("Punch a player to use the ultimate")
      }
	},

   data = {
      hits = 0,
      hit_player = nil,
      hit_pl_name = ""
   },
   sounds = {
      start = {name = "fbrawl_hero_fury"}
   },
   celestial_vault = {
      sky = {
         type = "regular",
         sky_color = {
            day_horizon = "#a93b3b",
            day_sky = "#e6482e"
         }
      },
      clouds = {
         color = "#302c2e"
      },
   },
   punches = {
      {x=1, y=0, z=0}, {x=-1, y=0, z=0},
      {x=0, y=0, z=1}, {x=-1, y=0, z=-1},
      {x=1, y=0, z=0}, {x=-1, y=0, z=0},
      {x=0, y=0, z=1}, {x=-1, y=0, z=-1},
      {x=0, y=1.5, z=0}
   },

   on_start = function(self, args)
      local hit_pl_name = args.hit_pl_name
      local arena = arena_lib.get_arena_by_player(hit_pl_name)

      if arena.players[hit_pl_name].is_invulnerable then
         return false
      end

      self.data.hits = 0
      self.data.hit_pl_name = hit_pl_name

      self:set_invulnerable(self.pl_name, true)
      self:set_invulnerable(hit_pl_name, true)
      args.hit_pl_name:unlock_skill("fbrawl:hit_by_hero_fury")
      args.hit_pl_name:start_skill("fbrawl:hit_by_hero_fury")
   end,

   reset_gravities = function(self)
      if minetest.get_player_by_name(self.pl_name) then
         local arena = arena_lib.get_arena_by_player(self.pl_name)
         local hitter_class = arena.classes[self.pl_name]
         self.player:set_physics_override({gravity = hitter_class.physics_override.gravity})
      end
      if minetest.get_player_by_name(self.data.hit_pl_name) then
         local arena = arena_lib.get_arena_by_player(self.data.hit_pl_name)
         local hit_class = arena.classes[self.data.hit_pl_name]
         local hit_player = minetest.get_player_by_name(self.data.hit_pl_name)
         hit_player:set_physics_override({gravity = hit_class.physics_override.gravity})
      end
   end,

   set_invulnerable = function (self, pl_name, value)
      if minetest.get_player_by_name(pl_name) then
         local arena = arena_lib.get_arena_by_player(pl_name)
         arena.players[pl_name].is_invulnerable = value
      end
   end,

   on_stop = function(self)
      self:reset_gravities()

      self:set_invulnerable(self.pl_name, false)
      self:set_invulnerable(self.data.hit_pl_name, false)
      self.data.hit_pl_name:stop_skill("fbrawl:hit_by_hero_fury")
   end,

   cast = function(self, args)
      local hit_pl_name = args.hit_pl_name
      local hit_player = minetest.get_player_by_name(hit_pl_name)
      local punch_dirs = self.punches
      self.data.hits = self.data.hits + 1

      if not hit_player then
         return false
      end

      if self.data.hits == 1 then
         fbrawl.reset_velocity(hit_player)
         fbrawl.reset_velocity(self.player)

         self.player:set_physics_override({gravity = 0})
         hit_player:set_physics_override({gravity = 0})

         hit_player:add_velocity({x=0, y=self.upward_force, z=0})

         minetest.add_entity({x=0,y=0,z=0}, "fantasy_brawl:forward_punch", self.player:get_player_name())

      elseif punch_dirs[self.data.hits] then

         -- normal punch
         if punch_dirs[self.data.hits + 1] then
            hit(self.player, hit_player, punch_dirs[self.data.hits])

         -- last punch
         else
            self:set_invulnerable(hit_pl_name, false)

            hit(self.player, hit_player, punch_dirs[self.data.hits], "last")

            self:reset_gravities()

            self:stop()
         end
      else
         return
      end
   end
})



skills.register_skill("fbrawl:hit_by_hero_fury", {
   name = "fbrawl:hit_by_hero_fury",
   blocks_other_skills = true,
   sounds = {
      bgm = {name="while_jumping", max_hear_distance = 6},
      stop = {name="smash", max_hear_distance = 6},
   },
   attachments = {
      particles = {{
         amount = 10,
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
         amount = 10,
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
      }}
   }
})



-------------------
-- PUNCH ENTITY --
-------------------

local forward_punch = {
   initial_properties = {
      physical = false,
      visual_size = {x = 1, y = 1},
      textures = {"fbrawl_punch_entity.png"},
      pointable = false,
      visual = "sprite",
   },
}



function forward_punch:on_activate(pl_name, dtime_s)
   if pl_name ~= "" then
      local player = minetest.get_player_by_name(pl_name)
      local obj = self.object
      local player_center = vector.add(player:get_pos(), {x=0, y=1, z=0})
      local look_dir = player:get_look_dir()

      local entity_duration = 0.32
      local entity_speed = 9

      obj:set_pos(player_center)
      obj:set_velocity(vector.multiply(look_dir, entity_speed))

      if fbrawl.random(1, 10) < 3 then
         minetest.sound_play({name = "fbrawl_punch"}, {pos = obj:get_pos(), max_hear_distance = 32}, true)
      else
         minetest.sound_play({name = "fbrawl_hero_fury_punch"}, {pos = obj:get_pos(), max_hear_distance = 32}, true)
      end

      minetest.after(entity_duration, function() obj:remove() end)
   else
      self.object:remove()
   end
end



minetest.register_entity("fantasy_brawl:forward_punch", forward_punch)



function hit(player, hit_player, offset, last)
   local hit_pl_pos = hit_player:get_pos()
   local hero_fury = skills.get_skill_def("fbrawl:hero_fury")

   local hitter_look_dir = player:get_look_dir()
   local punch_force = hero_fury.punch_force
   local push_force = vector.multiply(hitter_look_dir, punch_force)

   local hit_pl_max_hp = hit_player:get_properties().hp_max
   local hit_pl_hp = hit_player:get_hp()

   -- push
   fbrawl.reset_velocity(player)
   fbrawl.reset_velocity(hit_player)

   player:set_pos(vector.add(hit_pl_pos, offset))
   fbrawl.pl_look_at(player, hit_pl_pos)
   fbrawl.pl_look_at(hit_player, player:get_pos())

   if last then
      player:set_look_vertical(2)
      punch_force = skills.get_skill_def("fbrawl:hero_fury").upward_force
   else
      player:set_look_vertical(0)
   end
   hit_player:add_velocity(push_force)

   -- spawn punch
   minetest.add_entity({x=0,y=0,z=0}, "fantasy_brawl:forward_punch", player:get_player_name())

   -- damage, preventing the skill from killing the player
   hit_player:set_hp(math.max(2, hit_pl_hp - (hit_pl_max_hp / (#hero_fury.punches))))
   if last then -- unless it's the last hit
      hit_player:set_hp(1)
      fbrawl.hit_player(player, hit_player, 30)
   end
end

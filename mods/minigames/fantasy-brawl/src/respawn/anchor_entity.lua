local function on_pl_attach(entity, player) end
local function on_pl_detach(entity, player) end

local anchor = {
   initial_properties = {
      physical = false,
      collide_with_objects = false,
		is_visible = false,
		visual = "sprite",
      visual_size = {x = 1},
      textures = {"fbrawl_transparent.png"},
   },
   respawn_time = 4,
   pl_name = "",
}



-- staticdata = player's username.
function anchor:on_activate(staticdata, dtime_s)
   local obj = self.object
   local player = minetest.get_player_by_name(staticdata)

   if player then
      self.pl_name = staticdata
      on_pl_attach(self, player)
   else
      obj:remove()
      return
   end
end



function anchor:on_step(dtime, moveresult)
   local player = minetest.get_player_by_name(self.pl_name)
   local arena = arena_lib.get_arena_by_player(self.pl_name)
	self.respawn_time = self.respawn_time - dtime

   if not player then
      self.object:remove()
      return
   elseif not arena or arena.in_celebration then
      on_pl_detach(self, player)
      return
   end

   if self.respawn_time <= 0 then
      on_pl_detach(self, player)
      return
   end

   local respawn_hand = ItemStack("fantasy_brawl:respawn_hand")
   player:get_inventory():set_list("main", {respawn_hand})

   arena_lib.HUD_send_msg(
      "title", self.pl_name,
      tostring(math.floor(self.respawn_time+0.5).."...")
   )
end



minetest.register_entity("fantasy_brawl:anchor", anchor)



function on_pl_attach(entity, player)
   local arena = arena_lib.get_arena_by_player(entity.pl_name)

   entity.object:set_attach(player)

   arena.players[entity.pl_name].is_invulnerable = true
   player:get_inventory():set_list("main", {})

   player:set_properties({
      visual_size = {x = 0, y = 0, z = 0},
      makes_footstep_sound = false,
      collisionbox = {-0.001, -0.001, -0.001, 0.001, 0.001, 0.001},
      pointable = false
   })

   fbrawl.reset_velocity(player)
   player:set_physics_override({
      speed = 0,
      jump = 0,
      gravity = 0,
      acceleration_default = 0,
      acceleration_air = 0
   })
end



function on_pl_detach(entity, player)
   local arena = arena_lib.get_arena_by_player(entity.pl_name)

   if arena and not arena.in_celebration then
      fbrawl.apply_class(entity.pl_name, arena.classes[entity.pl_name])
      arena.players[entity.pl_name].is_invulnerable = false
   else
      if minetest.get_modpath("hub_core") then
         hub.set_hub_physics(player)
      else
         player:set_physics_override(arena_lib.SERVER_PHYSICS)
      end
   end

   arena_lib.HUD_hide("title", entity.pl_name)

   player:set_properties({
      visual_size = {x = 1, y = 1, z = 1},
      makes_footstep_sound = true,
      collisionbox = {
         -0.30000001192093,
         0,
         -0.30000001192093,
         0.30000001192093,
         1.7000000476837,
         0.30000001192093,
      },
      pointable = true
   })

   entity.object:remove()

   if arena then player:set_pos(arena_lib.get_random_spawner(arena)) end
end
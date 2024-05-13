--[[
   When the code refers to the player'S class it means the class table 
   associated to him/her in the arena.classes[pl_name] property.

   The definition table to put in register_class() is the following:
   {
      name : string =
         the class name, it is automatically translated in chat
         messages.

      items : { "name" or {name : string}, ...} =
         the items that the player will receive when the match starts.
      
      skills : {"skill1", ...} =
         the skills that the player will unlock.
         
      physics_override : {...}

      on_start : function(self, arena, pl_name) = 
         this gets called when this class gets assigned to pl_name. self
         is the class table assigned to the player while pl_name is his/her
         name.

      on_death : function(self, arena, pl_name, reason) =
         this gets called when the player dies.

      on_kill : function(self, arena, pl_name, killed_pl_name) =
         this gets called when the player kills someone.

      ... other functions or custom properties, just make sure
      that their names don't conflict with the already existing
      ones.
   }
]]


fbrawl.classes = {}  -- index : number = class : {}

local function get_valid_class() end
local function set_callbacks() end
local function set_physics() end
local function give_kill_to_assists() end
local S = fbrawl.T



-- clearing player's meta of unregistered classes
minetest.register_on_joinplayer(function(player, last_login)
   local pl_meta = player:get_meta()
	local data = minetest.deserialize(pl_meta:get_string("fbrawl:data")) or {}

   if 
      (data.chosen_class and not fbrawl.get_class_by_name(data.chosen_class))
      or not data.selected_class_name
      or (data.selected_class_name and not fbrawl.get_class_by_name(data.selected_class_name))
   then
      data.chosen_class = fbrawl.classes[1].name
      data.selected_class_name = data.chosen_class
      data.selected_skill_name = nil
   end

	pl_meta:set_string("fbrawl:data", minetest.serialize(data))
end)



function fbrawl.register_class(name, def)
   def = get_valid_class(name, def)
   fbrawl.classes[#fbrawl.classes+1] = def
end



function fbrawl.apply_class(pl_name, class)
   local player = minetest.get_player_by_name(pl_name)

   fbrawl.replace_weapon(player, class.weapon)

   pl_name:unlock_skill("fbrawl:hp_regen")
   pl_name:get_skill("fbrawl:hp_regen").data.custom_cast_rate = class.hp_regen_rate
   pl_name:start_skill("fbrawl:hp_regen")

   player:set_properties({hp_max = 200})
   player:set_hp(200)

   -- Unlocking the player's skills.
   for i, skill_name in pairs(class.skills) do
      pl_name:unlock_skill(skill_name)
   end

   player:set_physics_override(class.physics_override)
end



function fbrawl.get_class_by_name(name)
   if type(name) ~= "string" then return false end

   for i, class in ipairs(fbrawl.classes) do
      if class.name:lower() == name:lower() then return class end
   end
   return false
end



function fbrawl.get_class_by_skill(skill_name)
   for i, class in ipairs(fbrawl.classes) do
      for i, skill in ipairs(class.skills) do
         if skill == skill_name then return class end
      end
   end
end



function fbrawl.get_classes()
   local classes = {} -- name: string = def: table

   for i, class in pairs(fbrawl.classes) do
      classes[class.name] = class
   end

   return classes
end



function fbrawl.class_has_skill(class_name, skill_name)
   local skills = fbrawl.get_classes()[class_name].skills

   for key, name in pairs(skills) do
      if skill_name == name then return true end
   end

   return false
end



function get_valid_class(name, class)
   set_physics(class)
   set_callbacks(class)

   assert(
      class.name or class.hotbar_description or class.items or class.skills
      "A class hasn't been configured correctly ("..name..")!"
   )
   assert(
      not fbrawl.get_class_by_name(class.name), 
      "Two classes have the same name ("..name..")!"
   )

   return class
end



function set_callbacks(class)
   local empty_func = function() end
   local on_death = class.on_death or empty_func
   local on_start = class.on_start or empty_func
   local on_kill = class.on_kill or empty_func

   class.on_start = function(self, arena, pl_name)
      self.in_game = true

      fbrawl.apply_class(pl_name, class)
      fbrawl.init_HUD(arena, pl_name)

      on_start(self, arena, pl_name)
   end

   class.on_kill = function(self, arena, pl_name, killed_pl_name)
      local props = arena.players[pl_name]
      local player = minetest.get_player_by_name(pl_name)
      props.kills = props.kills + 1
      props.ultimate_recharge = math.min(props.ultimate_recharge + 1, fbrawl.min_kills_to_use_ultimate)
    
      fbrawl.update_hud(pl_name, "kills", props.kills)
      for i, object in ipairs(player:get_children()) do
         local obj_name = object:get_player_name()
         
         if object:is_player() and arena.spectators[obj_name] then
            fbrawl.update_hud(obj_name, "kills", props.kills)
         end
      end

      arena_lib.HUD_send_msg("broadcast", pl_name, S("You've killed @1", killed_pl_name), 2.5)
      minetest.sound_play({name="fbrawl_class_selected"}, {to_player = pl_name})
      
      on_kill(self, arena, pl_name, killed_pl_name)
   end

   class.on_death = function(self, arena, pl_name, reason)
      on_death(self, arena, pl_name, reason)
      local props = arena.players[pl_name]
      local player = minetest.get_player_by_name(pl_name)

      fbrawl.update_hud(pl_name, "deaths", props.deaths)
      for i, object in ipairs(player:get_children()) do
         local obj_name = object:get_player_name()

         if object:is_player() and arena.spectators[obj_name] then
            fbrawl.update_hud(obj_name, "deaths", props.deaths)
         end
      end

      if reason and reason.object then
         local killer_name = reason.object:get_player_name()
         local killer_class = arena.classes[killer_name]

         arena_lib.HUD_send_msg("broadcast", pl_name, S("You've been killed by @1", killer_name), 3)
         
         give_kill_to_assists(arena, pl_name, killer_name) 

         props.hit_by = {}

         killer_class:on_kill(arena, killer_name, pl_name)
      end
   end
end



function set_physics(class)
   local phys = class.physics_override or {}
   phys.speed = phys.speed or 1.2
   phys.gravity = phys.gravity or 1
   phys.acceleration = phys.acceleration or 1
   phys.jump = phys.jump or 1
   phys.sneak = false
   phys.speed_crouch = 2.65
   phys.sneak_glitch = phys.sneak_glitch or false
   phys.acceleration_default = 1
   phys.acceleration_air = 1
   phys.new_move = phys.new_move or true

   class.physics_override = phys
end



function give_kill_to_assists(arena, killed_pl_name, excluded_pl) 
   for name, damage in pairs(arena.players[killed_pl_name].hit_by) do
      if name ~= excluded_pl and arena.players[name] and damage >= 200/3 then
         arena.classes[name]:on_kill(arena, name, killed_pl_name)
      end
   end
end

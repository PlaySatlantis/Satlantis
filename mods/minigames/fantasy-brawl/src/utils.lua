local last_pls_y_velocity = {} -- pl_name = y_velocity
local get_node = minetest.get_node
local get_pl_by_name = minetest.get_player_by_name

local S = fbrawl.T



function fbrawl.replace_weapon(player, itemname, amount) 
   local inv = player:get_inventory()
   local list = inv:get_list("main")
   local itemstack = ItemStack(itemname)
   itemstack:set_count(amount or 1)
   list[1] = itemstack

   inv:set_list("main", list)
end



function fbrawl.get_weapon(player) 
   return player:get_inventory():get_list("main")[1]
end



function fbrawl.hit_player(puncher, hit_pl, damage, knockback) 
   local puncher_name = puncher:get_player_name()
   local arena = arena_lib.get_arena_by_player(puncher_name)
   local hit_pl_hitters = arena.players[hit_pl:get_player_name()].hit_by
   damage = damage * 20

   if arena.players[hit_pl:get_player_name()].is_invulnerable then return false end

   hit_pl:punch(puncher, 2, {damage_groups = {fleshy = damage}})

   hit_pl_hitters[puncher_name] = (hit_pl_hitters[puncher_name] or 0) + damage

   if knockback then
      hit_pl:add_velocity(knockback)
   end

   return true
end



function fbrawl.damage_players_near(puncher, pos, range, damage, knockback, callback)
   local arena = arena_lib.get_arena_by_player(puncher:get_player_name())

   if not arena then return false end

   if type(range) == "number" then range = vector.new(range, range, range) end

   for pl_name, props in pairs(arena.players) do
      local hit_pl = get_pl_by_name(pl_name)
      local hit_pl_pos = vector.add({x=0, y=1, z=0}, hit_pl:get_pos())

      local is_close_enough = true
      if
         math.abs(pos.x - hit_pl_pos.x) > range.x
         or math.abs(pos.y - hit_pl_pos.y) > range.y
         or math.abs(pos.z - hit_pl_pos.z) > range.z
      then
         is_close_enough = false
      end

      if hit_pl == puncher then is_close_enough = false end

      if is_close_enough then
         local did_it_hit = fbrawl.hit_player(puncher, hit_pl, damage, knockback)

         if did_it_hit and callback then
            callback(hit_pl:get_player_name())
         end
      end
   end
end



-- min and max included, output format: 0.00 
function fbrawl.random(min, max)
   min = min * 100
   max = max * 100
   return math.floor(math.random() * (max - min + 1) + min) / 100
end



function fbrawl.get_player_right_dir(player)
   local yaw = player:get_look_horizontal()
   local pl_right_dir = vector.new(math.cos(yaw), 0, math.sin(yaw))
   
   return vector.normalize(pl_right_dir)
end



function fbrawl.get_player_up_dir(pl)
   return vector.normalize(vector.rotate_around_axis(pl:get_look_dir(), fbrawl.get_player_right_dir(pl), math.pi/2))
end



function fbrawl.is_on_the_ground(player)
   local pl_name = player:get_player_name()
   local under_pl_feet = player:get_pos()
   local pl_velocity = player:get_velocity()
   local last_y_velocity = last_pls_y_velocity[pl_name] or pl_velocity.y

   under_pl_feet.y = under_pl_feet.y - 0.4
   
   local is_on_the_ground = 
      not (get_node(under_pl_feet).name == "air")
      or (pl_velocity.y == 0 and last_y_velocity < 0)
   
   last_pls_y_velocity[pl_name] = pl_velocity.y
   
   return is_on_the_ground
end



function fbrawl.reset_velocity(player)
   player:add_velocity(vector.multiply(player:get_velocity(), -1))
end



function fbrawl.interpolate(a, b, factor)
   local distance = math.abs(a-b)
   local min_step = 0.1
   local step = distance * factor
   if step < min_step then step = min_step end

   if a > b then
      a = a - step
      if a <= b then
         a = b
      end
   else
      a = a + step
      if a >= b then
         a = b
      end
   end

   return a
end



function fbrawl.vec_interpolate(a, b, factor)
   local i = fbrawl.interpolate
   local f = factor
   local interpolated_vec = {x=i(a.x, b.x, f), y=i(a.y, b.y, f), z=i(a.z, b.z, f)}

   return interpolated_vec
end



local calculate_knockback = minetest.calculate_knockback
function minetest.calculate_knockback(player, hitter, time_from_last_punch, tool_capabilities, dir, distance, damage)
   local mod = arena_lib.get_mod_by_player(player:get_player_name())

   if mod == "fantasy_brawl" then return 0 end

   return calculate_knockback(player, hitter, time_from_last_punch,
   tool_capabilities, dir, distance, damage)
end



function fbrawl.pl_look_at(player, target)
	local pos = player:get_pos()
	local delta = vector.subtract(target, pos)
	player:set_look_horizontal(math.atan2(delta.z, delta.x) - math.pi / 2)
end



function fbrawl.are_there_nodes_in_area(pos, range)
   range = range - 0.5
   local get_node = minetest.get_node
   local min_edge = vector.subtract(pos, range)
   local max_edge = vector.add(pos, range)
   local area = VoxelArea:new({MinEdge = min_edge, MaxEdge = max_edge})

   for i in area:iterp(min_edge, max_edge) do
      local pos = area:position(i)
      local node_name = get_node(pos).name 

      if node_name ~= "ignore" and node_name ~= "air" then return true end
   end

   return false
end



function fbrawl.get_time_in_seconds()
   return minetest.get_us_time() / 1000000
end



function fbrawl.raycast(pos1, dir, range, entities)
   if entities == nil then entities = false end

   local pos2 = pos1 + vector.multiply(dir, range)
   local ray = minetest.raycast(pos1, pos2, entities, false)

   return ray
end



function fbrawl.look_raycast(object, range, entities)
   local pos = {}
   local looking_dir = 0
   
   -- Assigning the correct values to pos and looking_dir, based on
   -- if the object is a player or not.
   if object:is_player() then
      local pl_pos = object:get_pos()
      local head_pos = {x = pl_pos.x, y = pl_pos.y+1.5, z = pl_pos.z}
      pos = head_pos
      looking_dir = object:get_look_dir()
   else
      pos = object:get_pos()
      looking_dir = vector.normalize(object:get_velocity())
   end
   
   -- Casts a ray from pos to the object looking direction * range.
   local ray = fbrawl.raycast(
      vector.add(pos, vector.divide(looking_dir, 4)), 
      looking_dir, 
      range,
      entities
   )

   return ray
end



function fbrawl.grid_raycast(player, range, radius, grid_size, entities)
   local pl = player
   local hit_pointed_things = {}
   local right_dir = fbrawl.get_player_right_dir(pl)
   local head_up_dir = fbrawl.get_player_up_dir(pl)
   local look_dir = pl:get_look_dir()
   local center = pl:get_pos() + look_dir + {x=0, y=1, z=0}

   -- top-left corner of the player's camera
   local x_step =  (radius*2 / grid_size) * right_dir
   local y_step = (radius*2 / grid_size) * head_up_dir
   local ray_pos = center - (x_step * (grid_size - 1)) / 2 + (y_step * (grid_size - 1)) / 2
   
   --draw_particles({image="fbrawl_gui_btn_choose.png", amount=5}, look_dir, ray_pos, 10, true)

   for row = 1, grid_size, 1 do
      for column = 1, grid_size, 1 do
         local pthings = fbrawl.from_ray_to_table(fbrawl.raycast(ray_pos, look_dir, range, entities))
         --draw_particles({image="fbrawl_gaia_fist.png", amount=5}, look_dir, ray_pos, 10, true)

         if pthings then
            table.insert_all(hit_pointed_things, pthings)
         end

         -- go to the next column
         ray_pos = ray_pos + x_step
      end

      -- go to the next row
      ray_pos = ray_pos - y_step
      ray_pos = ray_pos - x_step*grid_size
   end

   return hit_pointed_things
end



function fbrawl.from_ray_to_table(ray)
   local output = {}

   if not ray then return {} end

   while true do
      local next_elem = ray:next()

      if not next_elem then 
         return output 
      else
         table.insert(output, next_elem)
      end
   end
end




function draw_particles(particle, dir, origin, range, pierce)
   local check_coll = not pierce
 
   minetest.add_particlespawner({
     amount = particle.amount,
     time = 0.3,
     pos = vector.new(origin),
     vel = vector.multiply(dir, range),
     size = 2,
     collisiondetection = check_coll,
     collision_removal = check_coll,
     texture = particle.image
   })
 end
 
local saved_sounds = {} -- pl_name = {name = id}


function fbrawl.stop_sounds(pl_name)
  local player = minetest.get_player_by_name(pl_name)
    
  if not player or not saved_sounds[pl_name] then return end

  for name, sound in pairs(saved_sounds[pl_name]) do
    minetest.sound_stop(sound)
  end

  saved_sounds[pl_name] = nil
end



function fbrawl.add_temp_sound(pl_name, name, def, time)
  local player = minetest.get_player_by_name(pl_name)
  
  local sound = minetest.sound_play(name, def)
  saved_sounds[pl_name] = saved_sounds[pl_name] or {}
  saved_sounds[pl_name][sound] = sound

  minetest.after(time, function()
    if saved_sounds[pl_name] and saved_sounds[pl_name][sound] then
      minetest.sound_stop(sound)
      saved_sounds[pl_name][sound] = nil
    end
  end)

  return sound
end



function fbrawl.add_sound(pl_name, name, def)
  local player = minetest.get_player_by_name(pl_name)
  
  local sound = minetest.sound_play(name, def)
  saved_sounds[pl_name] = saved_sounds[pl_name] or {}
  saved_sounds[pl_name][name] = sound

  return sound
end



function fbrawl.stop_sound(pl_name, name)
  local player = minetest.get_player_by_name(pl_name)
    
  if not player or not saved_sounds[pl_name] or not saved_sounds[pl_name][name] then return end

  minetest.sound_stop(saved_sounds[pl_name][name])

  saved_sounds[pl_name][name] = nil
end
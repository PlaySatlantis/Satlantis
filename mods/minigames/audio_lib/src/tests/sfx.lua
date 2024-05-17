local S = minetest.get_translator("audio_lib")

audio_lib.register_sound("sfx", "audiolib_test_sfx1", "Audio_lib sfx test #1" )



minetest.register_tool("audio_lib:testsfx1", {
  description = S("Audio Lib sfx test #1\n\n1. Play SFX #1 to the player"),
  inventory_image = "audiolib_test_sfx1.png",
  on_place = function() end,
  on_drop = function() end,

  on_use = function(itemstack, user, pointed_thing)
    local p_name = user:get_player_name()
    audio_lib.play_sound("audiolib_test_sfx1", {to_player = p_name})
    minetest.chat_send_player(p_name, "► " .. table.concat(audio_lib.get_player_sounds("sfx", p_name), " | "))
  end,
})



minetest.register_tool("audio_lib:testsfx2", {
  description = S("Audio Lib sfx test #2\n\n1. Play SFX #1 at player's position\n2. Play SFX #1 again after 2 seconds, shifted by 30 nodes on the X axis from the player's position"
                    .. "\n3.Play it again after 0.5s, but shifted by 30 nodes in the opposite direction\n4. Play it again after 0.4s, like in step #2"),
  inventory_image = "audiolib_test_sfx2.png",
  on_place = function() end,
  on_drop = function() end,

  on_use = function(itemstack, user, pointed_thing)
    local p_name = user:get_player_name()
    audio_lib.play_sound("audiolib_test_sfx1", {pos = user:get_pos()})
    minetest.chat_send_player(p_name, "► " .. table.concat(audio_lib.get_player_sounds("sfx", p_name), " | ") .. " (p_pos)")

    minetest.after(2, function()
      if not user then return end
      audio_lib.play_sound("audiolib_test_sfx1", {pos = vector.add(user:get_pos(), vector.new(30,0,0))})
      minetest.chat_send_player(p_name, "► " .. table.concat(audio_lib.get_player_sounds("sfx", p_name), " | ") .. " (p_pos + (30,0,0))")

      minetest.after(0.5, function()
        if not user then return end
        audio_lib.play_sound("audiolib_test_sfx1", {pos = vector.add(user:get_pos(), vector.new(-30,0,0))})
        minetest.chat_send_player(p_name, "► " .. table.concat(audio_lib.get_player_sounds("sfx", p_name), " | ") .. " (p_pos - (30,0,0))")


        minetest.after(0.4, function()
          if not user then return end
          audio_lib.play_sound("audiolib_test_sfx1", {pos = vector.add(user:get_pos(), vector.new(30,0,0))})
          minetest.chat_send_player(p_name, "► " .. table.concat(audio_lib.get_player_sounds("sfx", p_name), " | ") .. " (p_pos + (30,0,0))")
        end)
      end)
    end)
  end,
})

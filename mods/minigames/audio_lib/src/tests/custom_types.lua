local S = minetest.get_translator("audio_lib")

audio_lib.register_type("audio_lib", "custom_test", S("Custom type test"))
audio_lib.register_sound("custom_test", "audiolib_test_custom1", "Audio_lib custom sound test #1")



minetest.register_tool("audio_lib:testcustom1", {
  description = S("Audio Lib custom sound test #1\n\n1. Play Custom Sound #1 to the player"),
  inventory_image = "audiolib_test_custom1.png",
  on_place = function() end,
  on_drop = function() end,

  on_use = function(itemstack, user, pointed_thing)
    local p_name = user:get_player_name()
    audio_lib.play_sound("audiolib_test_custom1", {to_player = p_name})
    minetest.chat_send_player(p_name, "► " .. table.concat(audio_lib.get_player_sounds("custom_test", p_name), " | "))
  end,
})
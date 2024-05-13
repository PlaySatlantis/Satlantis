local S = minetest.get_translator("audio_lib")

minetest.register_chatcommand("audiosettings", {
  description = S("Open the audio settings menu"),
  func = function(name, param)
    audio_lib.open_settings(name)
  end
})
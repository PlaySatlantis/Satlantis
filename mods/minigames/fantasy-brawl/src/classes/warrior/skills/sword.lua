local S = fbrawl.T



skills.register_skill("fbrawl:sword_steel", {
   name = S("Sword"),
   icon = "default_tool_steelsword.png",
   description = S("Your trusted steel sword *slice slice slice*."),
   sounds = {
      cast = {name = "fbrawl_sword_slash", max_hear_distance = 5, object = true, random_pitch = {0.8, 1}}
   },
   cooldown = 0.25
})

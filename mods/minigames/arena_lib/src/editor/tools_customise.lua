local customise_tools = {
  "arena_lib:customise_bgm",
  "arena_lib:customise_sky",
  "arena_lib:customise_weather",
  "arena_lib:customise_lighting",
  "",
  "",
  "",
  "",
  "arena_lib:editor_return",
  "arena_lib:editor_quit",
}



function arena_lib.give_customise_tools(user)
  user:get_inventory():set_list("main", customise_tools)
end

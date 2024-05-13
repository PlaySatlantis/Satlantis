# Arena_lib docs

# Table of Contents
* [1. Minigame configuration](#1-minigame-configuration)
	* [1.1 Per server configuration](#11-per-server-configuration)
	* [1.2 Privileges](#12-privileges)
	* [1.3 Commands](#13-commands)
		* [1.3.1 Admins only](#131-admins-only)
	* [1.4 Callbacks](#14-callbacks)
		* [1.4.1 Minigame callbacks](#141-minigame-callbacks)
		* [1.4.2 Global callbacks](#142-global-callbacks)
	* [1.5 Additional properties](#15-additional-properties)
		* [1.5.1 Arena properties](#151-arena-properties)
			* [1.5.1.1 Updating non temporary properties via code](#1511-updating-non-temporary-properties-via-code)
			* [1.5.1.2 Updating properties for old arenas](#1512-updating-properties-for-old-arenas)
		* [1.5.2 Player and spectator properties](#152-player-and-spectator-properties)
		* [1.5.3 Team properties](#153-team-properties)
	* [1.6 Audio](#16-audio)
	* [1.7 HUD](#17-hud)
	* [1.8 Utils](#18-utils)
	* [1.9 Getters](#19-getters)
	* [1.10 Endless minigames](#110-endless-minigames)
	* [1.11 Custom entrances](#111-custom-entrances)
	* [1.12 Extendable editor](#112-extendable-editor)
	* [1.13 Things you don't want to do with a light heart](#113-things-you-dont-want-to-do-with-a-light-heart)
* [2. Arenas](#2-arenas)
	* [2.1 Storing arenas](#21-storing-arenas)
	* [2.2 Setting up an arena](#22-setting-up-an-arena)
		* [2.2.1 Editor](#221-editor)
		* [2.2.2 CLI](#222-cli)
			* [2.2.2.1 Changing arenas name, author, thumbnail](#2221-changing-arenas-name-author-thumbnail)
			* [2.2.2.2 Players management](#2222-players-management)
			* [2.2.2.3 Enabling/Disabling teams](#2223-enablingdisabling-teams)
			* [2.2.2.4 Spawners](#2224-spawners)
			* [2.2.2.5 Entering and leaving](#2225-entering-and-leaving)
			* [2.2.2.6 Arena properties](#2226-arena-properties)
			* [2.2.2.7 Timers](#2227-timers)
			* [2.2.2.8 Music](#2228-music)
			* [2.2.2.9 Celestial vault](#2229-celestial-vault)
			* [2.2.2.10 Weather](#22210-weather)
			* [2.2.2.11 Lighting](#22211-lighting)
			* [2.2.2.12 Region](#22212-region)
				* [2.2.2.12.1 Schematics](#222121-schematicss)
		* [2.2.3 Arena regions](#223-arena-regions)
			* [2.2.3.1 Map regeneration](#2231-map-regeneration)
				* [2.2.3.1.1 Soft reset](#22311-soft-reset)
				* [2.2.3.1.2 Hard reset](#22312-hard-reset)
	* [2.3 Arena phases](#23-arena-phases)
	* [2.4 Teams management](#24-teams-management)
	  * [2.4.1 Teams assignment](#241-teams-assignment)
	* [2.5 Spectate mode](#25-spectate-mode)
* [3. About the author(s)](#3-about-the-authors)

## 1. Minigame configuration

First of all download the mod and put it in your mods folder.  

Now you need to register your minigame, possibly inside the `init.lua` of your mod, via:
```lua
arena_lib.register_minigame("mod_name", {parameter1, parameter2 etc})
```
`"mod_name"` is how arena_lib will store your mod inside its storage, and it's also what it needs in order to understand you're referring to that specific minigame (that's why almost every `arena_lib` function contains `"mod"` as a parameter). You'll need it when calling for commands and callbacks. **Use the same name you used in mod.conf or some features won't be available**.  
The second field, on the contrary, is a table of optional parameters: they define the very features of your minigame. They are:
* `name`: (string) the name of your minigame. If not specified, it takes the name used to register the minigame
* `prefix`: (string) what's going to appear in most of the lines printed by your mod. Default is `[<mg name>] `, where `<mg name>` is the name of your minigame
* `icon`: (string) optional icon to represent your minigame. If not specified, it'll use a placeholder (`"arenalib_icon_unknown.png"`). Unused by default, it comes in handy for external mods
* `min_version`: (int) the minimum Minetest version required to play the minigame, expressed in Minetest `protocol_version` (e.g. 5.8 is 43). By default is `-1`. For a better implementation, [this](https://github.com/minetest/minetest/issues/14151) is needed
* `teams`: (table) contains team names. If not declared, your minigame won't have teams and the table will be equal to `{-1}`
* `can_disable_teams`: (boolean) whether the minigame should support both teams and free for all arenas. It requires `teams`. Default is `false`
* `variable_teams_amount`: (boolean) whether to support a variable amount of teams per arena. It requires `teams`. Default is `false`
* `teams_color_overlay`: (table) [color strings](https://drafts.csswg.org/css-color/#named-colors). It applies a color overlay onto the players' skin according to their team, so to better distinguish them. It requires `teams`. Default is `nil`
* `friendly_fire`: (boolean) whether players in the same team can damage each other. It requires `teams`. Default is `false`
* `chat_settings`: (table) several chat options
  * Default fields are:
    ```lua
    {
      prefix_all = "[arena] " -- prefix for every global message sent in arena. Default is automatically translated
      prefix_team = "[team] " -- ^ but for teams
      prefix_spectate = "[spectator] " -- ^ but for spectators
      color_all = "#ffffff" -- white
      color_team = "#ddfdff" -- light blue
      color_spectate = "#dddddd" -- gray
      is_team_chat_default = false -- whether players messages should be sent to their teammates only (teams must be enabled)
    }
    ```
* `custom_messages`: (table) series of messages to optionally customise the minigame experience. Beware:
  * Default fields are:
    ```lua
    {
      eliminated = "@1 has been eliminated",
      eliminated_by = "@1 has been eliminated by @2",
      last_standing = "You're the last player standing: you win!",
      last_standing_team = "There are no other teams left, you win!",
      quit = "@1 has quit the match",
      celebration_one_player = "@1 wins the game",
      celebration_one_team = "Team @1 wins the game",
      celebration_more_players = "@1 win the game",
      celebration_more_teams = "Teams @1 win the game",
      celebration_nobody = "There are no winners"
    }
    ```
  * If the overridden message contains translation variables (e.g. `@1`), these must be present in the exact same amount in the custom message or it'll crash. Elimination messages can, however, bypass this system: see `elim_msg` in `remove_player_from_arena(..)`
  * Arena_lib will automatically translate the new strings using the textdomain of the minigame: do NOT push translated strings, just put their translation in the locale folder of the minigame
  * If for any reason you want to retrieve these messages in your minigame, these are saved in a `messages` field, and not in a `custom_messages` one. The latter is just a table `msg_name = true` used to check whether the message is a custom one
* `sounds`: (table) series of sounds to optionally customise the minigame experience.
  * Each entry is a table following the [audio_lib registration format](https://gitlab.com/zughy-friends-minetest/audio_lib/-/blob/main/DOCS.md): a file name, a description and optional parameters (e.g. `{name = "mymod_mysound1", description = "Someone joins"}`). Arena_lib proceeds to register them on its own as sounds of type "system", and only the name is stored as a field
  * Default fields are:
    ```lua
    {
      join = "arenalib_match_join",
      quit = "arenalib_match_leave", 		-- sounds played when people leave, differentiated by reason
      kick = "arenalib_match_leave",
      eliminate = "arenalib_match_leave",
      disconnect = "arenalib_match_leave"
    }
    ```
  * Registration also accepts the special field `leave`, which applies the same sound to `quit`, `kick`, `eliminate` and `disconnect`. These fields can still be overridden individually, as `leave` is applied first.
  * Setting a field to `false` won't play any sound
  * The sound is not played to the player whom enters/leaves
* `player_aspect`: (table) changes the aspect of every player entering a game. It supports a few parameters from Minetest [Object Properties](https://minetest.gitlab.io/minetest/definition-tables/), namely `visual`, `visual_size`, `mesh`, `textures`, `collisionbox` and `selectionbox`
  * If you want a custom aspect for each player, this can't be achieved here (callbacks like `on_load` will suit your needs). However, by declaring at least an empty table, you can still rely on arena_lib automatically restoring the player aspect when they leave
* `fov`: (int) changes the fov of every player
* `camera_offset`: (table) changes the offset of the camera for every player. It's structured as such: `{1st_person, 3rd_person}`, e.g. `{nil, {x=5, y=3, z=-4}}`
* `hotbar`: (table) overrides the server hotbar while inside an arena. Its fields are:
  * `slots =`: (int) the number of slots
  * `background_image =`: (string) the background image
  * `selected_image =`: (string) the image to show when a slot is selected  
  If a field is not declared, it'll keep the server defaults
* `min_players`: (int) the mimimum amount of players every arena must have. If teams are enabled, value is per team. Default is `1`
* `endless`: (bool) whether the minigame is of type endless. If `true`, `join_while_in_progress` is automatically `true` and `min_players` is `0`. Default is `false`. For further information, check out the specific section [1.10 Endless minigames](#110-endless-minigames)
* `end_when_too_few`: (bool) whether the minigame should end its matches when only one player/team is left. Default il `true`
* `eliminate_on_death`: (bool) whether players are automatically eliminated when dying (both `on_death` and `on_eliminate` callbacks are called, in this order). Default is `false`
* `join_while_in_progress`: (bool) whether the minigame allows to join an ongoing match. Default is `false`
* `spectate_mode`: (bool) whether the minigame features the spectator mode. Default is `true`
* `regenerate_map`: (bool) whether to regenerate the maps of the minigame between a game and another. Default is `false`. Be sure to check [Map regeneration](#2231-map-regeneration) first
* `can_build`: (bool) whether players are allowed to place or dig nodes during a match. Default is `false`
* `can_drop`: (bool) whether players can drop items during a match. Default is `true`
* `disable_inventory`: (bool) whether to completely disable the inventory (pressing the inventory key won't do anything). In case an external inventory is opened, players won't be able to move items around. Default is `false`
* `keep_inventory`: (bool) whether to keep players' inventories when joining an arena. Default is `false`. No matter the option, players' inventories are stored when entering an arena and restored when leaving (or reconnecting, in case of crash)
* `keep_attachments`: (bool) whether to keep the entities attached to the player. If `false`, entities are removed when entering, and re-created (alongside their properties) when leaving. No matter the option, players are always detached. Default is `false`
* `show_nametags`: (bool) whether to show players' nametags while in game. Default is `false`
* `time_mode`: (string) whether arenas will keep track of the time or not
  * `"none"`: no time tracking at all (default)
  * `"incremental"`: incremental time (0, 1, 2, ...)
  * `"decremental"`: decremental time, as in a timer (3, 2, 1, 0). The timer value is 300 seconds by default, but it can be changed per arena. Time stops ticking when it reaches 0
* `load_time`: (int) the time in seconds between the loading state and the start of the match. Default is `5`
* `celebration_time`: (int) the time in seconds between the celebration state and the end of the match. Must be greater than 0. Default is `5`
* `in_game_physics`: (table) a physical override to set to each player when they enter an arena, following the Minetest `physics_override` parameters
* `damage_modifiers`: (table) an override of players' armor groups, as declared in the [Minetest API](https://github.com/minetest/minetest/blob/master/doc/lua_api.md#objectref-armor-groups)
* `disabled_damage_types`: (table) contains which damage types will be disabled once in a game. Damage types are strings, the same as in `reason.type` in the [Minetest API](https://github.com/minetest/minetest/blob/master/doc/lua_api.md) (e.g. `{"fall", "punch"}`)
* `hud_flags`: (table) contains which HUD flags will be enabled and which won't once in game. It follows the same syntax of `hud_set_flags(..)` in the [Minetest API](https://github.com/minetest/minetest/blob/master/doc/lua_api.md) (e.g. `{hotbar = true, minimap = false}`). If a flag is not declared, the current player's flag will be kept
* `properties`: see [1.5 Additional properties](#15-additional-properties)
* `temp_properties`: ^
* `player_properties`: ^
* `spectator_properties`: ^
* `team_properties`: ^ (it won't work if `teams` hasn't been declared)
  
To retrieve a minigame table, just do `arena_lib.mods[mod_name]`

### 1.1 Per server configuration
There are also a couple of settings that can only be set in game via `/arenas settings <minigame>`. This because different servers might need different parameters. They are:
* `return_point`: where players will be teleported when a match _in your mod_ ends. Default is `{ x = 0, y = 20, z = 0 }`. A bit of noise is applied on the x and z axis, ranging between `-1.5` and `1.5`.
* `queue_waiting_time`: the time to wait before the loading phase starts. It gets triggered when the minimum amount of players has been reached to start the queue. Default is `10`

> **BEWARE**: as you've noticed, the hub spawn point is bound to the very minigame. In fact, there is no global spawn point as arena_lib could be used even in a survival server that wants to feature just a couple minigames. If you're looking for a hub manager because your goal is to create a full minigame server, have a look at my other mod [Hub](https://gitlab.com/zughy-friends-minetest/hub). Also, if you want to be sure to join the same arena/team with your friends, you need to install my other mod [Parties](https://gitlab.com/zughy-friends-minetest/parties)

### 1.2 Privileges
* `arenalib_admin`: allows to use a few more commands

### 1.3 Commands
A couple of general commands are already declared inside arena_lib, them being:

* `/quit`: quits a queue or an ongoing game
* `/all`: writes in the arena global chat
* `/t`: writes in the arena team chat (if teams are enabled)

#### 1.3.1 Admins only
A few more are available for players having the `arenalib_admin` privilege:

* `/arenas`
	* `check_resources`: check if there is any unused resource inside the arena_lib world folder (inside BGM and Thumbnails)
	* `create <minigame> <arena> (<pmin> <pmax>)`: creates an arena named `arena` for the specified minigame. `pmin` and `pmax` are optional integers indicating the minimum and maximum amount of players
	* `disable (<minigame>) <arena>`: disables an arena
	* `edit (<minigame>) <arena>`: enters the arena editor
	* `enable (<minigame>) <arena>`: enables an arena
	* `entrances <minigame>`: changes the entrance types of `<minigame>`
	* `flush (<minigame>) <arena>`: DEBUG ONLY: reset the properties of a bugged arena
	* `forceend (<minigame>) <arena>`: forcibly ends an ongoing game
	* `forcestart (<minigame>) <arena>`: forcibly loads (if in queue) or starts (if in the loading phase) a game
	* `gamelist`: lists all the installed minigames, sorted alphabetically
	* `glist`: see `gamelist`
	* `info (<minigame>) <arena>`: prints all the info related to `<arena>`
	* `kick player_name`: kicks a player out of an ongoing game, no matter the mod. When kicked, they must wait 2 minutes before re-entering a match
	* `list <minigame>`: lists all the arenas of `<minigame>`
	* `remove (<minigame>) <arena>`: deletes an arena
	* `settings <minigame>`: changes `<minigame>` settings

### 1.4 Callbacks
Callbacks are divided in two types: minigame callbacks and global callbacks. The former allow you to customise your mod even more and can be called just once per minigame, whilst the latter are great for external mods that want to customise the experience outside of a specific minigame (e.g. a server giving players some currency when winning, a HUD telling players what game is in progress).  
All callbacks are called after the normal operations, unless explicitly stated (e.g. `pre<something>` callbacks)

#### 1.4.1 Minigame callbacks

* `arena_lib.on_prejoin_queue(mod, function(arena, p_name)`: run more checks when entering a queue. Must return `true` or the player won't be added
* `arena_lib.on_join_queue(mod, function(arena, p_name)`: additional actions to perform after a player has successfully joined a queue
* `arena_lib.on_leave_queue(mod, function(arena, p_name)`: same as above, but for when they leave
* `arena_lib.on_load(mod, function(arena)`: see [2.3 Arena phases](#23-arena-phases)
* `arena_lib.on_start(mod, function(arena))`: same as above
* `arena_lib.on_celebration(mod, function(arena, winners)`: same as above. `winners` can be either a string, an integer or a table of string/integers. If you want to have a single winner, return their name (string). If you want to have a whole team, return the team ID (integer). If you want to have more single winners, a table of strings, and for more teams, a table of integers.
* `arena_lib.on_end(mod, function(arena, winners, is_forced))`: same as above. It's called after flushing the arena (both from players and data)
  * `arena` is a copy from before the flush, so you can retrieve whatever data you need from there (e.g. player stats, timers)
  * `is_forced` returns `true` when the match has been forcibly terminated (via `force_end`)
  * If you want to teleport players onto a custom position, don't do it here. Instead, change the `custom_return_point` of the arena. However, if you really need to teleport players onto different positions, due to current MT limitations (see [here](https://github.com/minetest/minetest/issues/12092)), you have to do that after at least 0.2 seconds
* `arena_lib.on_prejoin(mod, function(arena, p_name, as_spectator))`: run more checks when joining a game. Must return `true` or the player won't be able to join
* `arena_lib.on_join(mod, function(p_name, arena, as_spectator, was_spectator))`: called when a user joins an ongoing match.
  * Due to current MT limitations, calling `set_pos()` on a player is not possible, unless it's done after at least 0.2 seconds (see [here](https://github.com/minetest/minetest/issues/12092))
  * `as_spectator` returns true if they join as a spectator. If entering as a spectator, `on_join` is executed before entering in spectate mode (the order is join -> spectate). This means that the player as a spectator still doesn't exist
  * `was_spectator` returns true if the user was spectating `arena` when joining as an actual player.
 * `arena_lib.on_generate_teams(mod, function(arena, max_current_amount)`: customise team assignment right before the loading of an arena (e.g. to balance teams). See [2.4.1 Teams assignment](#241-teams-assignment) to understand how it works
* `arena_lib.on_assign_team(mod, function(arena, p_name)`: customise team assignment for `p_name` and their potential party when entering an ongoing match. See [2.4.1 Teams assignment](#241-teams-assignment) to understand how it works
* `arena_lib.on_death(mod, function(arena, p_name, reason))`: called when a player dies
* `arena_lib.on_respawn(mod, function(arena, p_name))`: called when a player respawns
* `arena_lib.on_change_spectated_target(mod, function(arena, sp_name, t_type, t_name, prev_type, prev_spectated, is_forced))`: called when a spectator (`sp_name`) changes who or what they're spectating, including when they get assigned someone to spectate at entering the arena. `is_forced` returns true when the change is a result of `spectate_target(..)`
    * `t_type` represents the type of the target (either `"player"`, `"entity"` or `"area"`)
    * `t_name` its name. If it's an entity or an area, it'll be the name used to register it through the `arena_lib.add_spectate_*` functions
    * if they were following someone/something else earlier, `prev_type` and `prev_spectated` follow the same logic of the aforementioned parameters
    * Beware: as this gets called also when entering, keep in mind that it gets called before the `on_join` callback
* `arena_lib.on_time_tick(mod, function(arena))`: called every second if `time_mode` is different from `"none"`
* `arena_lib.on_timeout(mod, function(arena))`: called when the timer of an arena, if exists (`time_mode = "decremental"`), reaches 0. Declaring the timer but not the callback is not allowed, resulting in a crash at server launch
* `arena_lib.on_eliminate(mod, function(arena, p_name, xc_name, p_properties))`: called when a player is eliminated (see `arena_lib.remove_player_from_arena(..)`)
  * If there is no spectate mode, it'll run alongside `on_quit`, in the order eliminate -> quit
  * `p_properties` is a copy of the player properties. Since the callback runs after emptying the player data, arena_lib passes here a copy
* `arena_lib.on_quit(mod, function(arena, p_name, is_spectator, reason, p_properties))`: called when a player/spectator quits (or is forced to quit) from an ongoing match
  * It's not called when force-ending a match
  * To learn about the `reason` parameter, see `arena_lib.remove_player_from_arena(..)`
  * `p_properties` is a copy of the player/spectator properties. Since the callback runs after emptying the player data, arena_lib passes here a copy. If the player was spectating, it'll be a copy of the spectator properties. Otherwise, of the player's.
* `arena_lib.on_prequit(mod, function(arena, p_name))`: called when a player tries to quit an ongoing game with `/quit`. If it returns false, quit is cancelled. Useful to ask confirmation first, or simply to impede a player to quit
* `arena_lib.on_enable(mod, function(arena, p_name))`: run more checks before enabling an arena. Must return `true` or the arena won't be enabled
* `arena_lib.on_disable(mod, function(arena, p_name))`: run more checks before disabling an arena. Must return `true` or the arena won't be disabled
* `arena_lib.on_join_editor(mod, function(arena, p_name))`: called when a player enters the editor of an arena
* `arena_lib.on_leave_editor(mod, function(arena, p_name))`: same as above, but for when they leave

> **BEWARE**: there is a default behaviour already for most of these situations: for instance when a player dies, their deaths increase by 1. These callbacks exist just in case you want to add some extra behaviour to arena_lib's.

So for instance, if we want to add an object in the first slot when a player joins the pre-match, we can simply do:

```lua
arena_lib.on_load("mymod", function(arena)

  local item = ItemStack("default:dirt")

  for pl_name, stats in pairs(arena.players) do
    pl_name:get_inventory():set_stack("main", 1, item)
  end

end)
```

#### 1.4.2 Global callbacks
Global callbacks act in the same way of minigame callbacks with the same name. Keep in mind that not every minigame callback has a global counterpart.  
`mod_ref` is the minigame table (so the one at the beginning of [Minigame configuration](#1-minigame-configuration)) and it can retrieved by doing `arena_lib.mods[<mod>]`
* `arena_lib.register_on_enable(function(mod, arena, p_name))`
* `arena_lib.register_on_disable(function(mod, arena, p_name))`
* `arena_lib.register_on_prejoin_queue(function(mod, arena, p_name))`
* `arena_lib.register_on_join_queue(function(mod, arena, p_name, has_queue_status_changed))`: `has_queue_status_changed` is a boolean, returning true when the arena goes from in queue -> not in queue, and viceversa
* `arena_lib.register_on_leave_queue(function(mod, arena, p_name, has_queue_status_changed))`: check the previous callback for `has_queue_status_changed`
* `arena_lib.register_on_load(function(mod, arena))`
* `arena_lib.register_on_start(function(mod, arena))`
* `arena_lib.register_on_join(function(mod, arena, p_name, as_spectator, was_spectator))`
* `arena_lib.register_on_celebration(function(mod, arena, winners))`
* `arena_lib.register_on_end(function(mod, arena, winners, is_forced))`
* `arena_lib.register_on_eliminate(function(mod, arena, p_name))`
* `arena_lib.register_on_quit(function(mod, arena, p_name, is_spectator, reason))`
* `arena_lib.register_on_join_editor(function(mod, arena, p_name))`
* `arena_lib.register_on_leave_editor(function(mod, arena, p_name))`

Let's say we want to stop people to enter minigames when there is an event on our server. We can simply do:

```lua
arena_lib.register_on_prejoin_queue(function(mod, arena, p_name)

  if myservermod.is_event_active() then
	minetest.chat_send_player(p_name, "There is a special event in progress, minigames will be back once it ends!")
	return
  end
  
  return true
end)
```

### 1.5 Additional properties
Let's say you want to add a kill leader parameter. `Arena_lib` doesn't provide specific parameters, as its role is to be generic. Instead, you can create your own kill leader parameter by using the five tables `properties`, `temp_properties`, `player_properties`, `spectator_properties` and `team_properties`. The first two are for the arena, the third and fourth are for users and the fifth for teams.  
No matter the type of property, they're all shared between arenas. Better said, their values can change, but there can't be an arena with more or less properties than another.

#### 1.5.1 Arena properties
The difference between `properties` and temp/player/spectator/team's is that the former will be stored by the the mod so that when the server reboots it'll still be there, while the others won't and they don't persist through matches. Everything but `properties` is temporary. In our case, for instance, we don't want the kill leader to be preserved outside of a match, thus we go to our `arena_lib.register_minigame(..)` and write:

```lua
arena_lib.register_minigame("mymod", {
  --whatever stuff we already have
  temp_properties = {
    kill_leader = ""
  }
}
```
in doing so, we can easily access the `kill_leader` field whenever we want from every arena we have, via `yourarena.kill_leader` (e.g. when creating a function calculating the arena kill leader); and when the match ends, `kill_leader` will return to its original state (`""`).

> **BEWARE**: you DO need to initialise your properties (whatever type) or it'll return an error

##### 1.5.1.1 Updating non temporary properties via code
Let's say you want to change a property from your mod. A naive approach would be doing `yourarena.property = something`. This, though, won't update it in the storage, so when you restart the server it'll still have the old value.  
Instead, the right way to permanently update a property for an arena is calling `arena_lib.change_arena_property(..)` while an arena is disabled. Persisting properties can't be changed when an arena is enabled, as it would require to update the storage (something that can't be done when an arena is enabled, see [2.1 Storing arenas](#21-storing-arenas)); meaning you cannot use these properties for variables that change during the game and that should be saved in storage. Instead, you can use temporary properties, and implement your own storage and retrieval method.

##### 1.5.1.2 Updating properties for old arenas
This is done automatically by arena_lib every time you change the properties declaration in `register_minigame`, so don't worry. Just, keep in mind that when a property is removed, it'll be removed from every arena; so if you're not sure about what you're doing, do a backup first.

#### 1.5.2 Player and spectator properties
These are a particular type of temporary properties, as they're attached to every player/spectator in the arena. When users leave the arena or they change their state (i.e. player becoming a spectator or vice versa), these properties are emptied.  
Let's say you now want to keep track of how many kills a player does in a streak without dying. You just need to create a killstreak parameter, declaring it like so
```lua
arena_lib.register_minigame("mymod", {
  --stuff
  temp_properties = {
    kill_leader = ""
  },
  player_properties = {
    killstreak = 0
  }
}
```

Now you can easily access the killstreak parameter by retrieving the player inside an arena via `yourarena.players[p_name].killstreak`. Also, don't forget to reset it when a player dies via the `on_death` callback we saw earlier:
```lua
arena_lib.on_death("mymod", function(arena, p_name, reason)
  arena.players[p_name].killstreak = 0
end)

```

These properties are removed 

#### 1.5.3 Team properties
Same as above, but for teams. They can accessed through `yourarena.teams[<teamID>].property_name`. Like `temp_properties`, team properties are emptied when the match ends.

### 1.6 Audio
`arena_lib` uses [audio_lib](https://gitlab.com/zughy-friends-minetest/audio_lib) as a library to simplify and improve audio management. Built on top of such libraries, there are three functions that allow modders to easily play sounds directly to players and their spectators inside an arena (so not for positional sounds).  
Beware: sounds must be registered first through `audio_lib.register_sound(..)` in order to work. Also, see audio_lib for the optional `override_params` argument.
* `arena_lib.sound_play(p_name, sound, <override_params>, <skip_spectators>)`: plays `sound` to `p_name` and their spectators
* `arena_lib.sound_play_team(arena, teamID, sound, <override_params>, <skip_spectators>)`: plays `sound` to all the players and spectators of team `teamID`
* `arena_lib.sound_play_all(arena, sound, <override_params>, <skip_spectators>)`: plays `sound` to all the players and spectators in the arena

On the contrary, if you need to play positional sounds, just use `audio_lib.play_sound(..)` or (advised against) `minetest.sound_play(..)`

### 1.7 HUD
`arena_lib` also comes with a triple practical HUD: `title`, `broadcast` and `hotbar`. These HUDs only appear when a message is sent to them and they can be easily used via the following functions:
* `arena_lib.HUD_send_msg(HUD_type, p_name, msg, <duration>, <sound>, <color>)`: sends a message to the specified player/spectator in the specified HUD type (`"title"`, `"broadcast"` or `"hotbar"`).
  * If no `duration` is declared, it won't disappear by itself
  * If `sound` is declared, it'll be played at the very showing of the HUD. It can be either a string or a table, it can use the native sound system or (preferably) audio_lib's. If you're using audio_lib, the sound can be of whatever type except for bgm
  * `color` must be in a hexadecimal format and, if not specified, it defaults to white (`0xFFFFFF`)
* `arena_lib.HUD_send_msg_all(HUD_type, arena, msg, <duration>, <sound>, <color>)`: same as above, but for all the players and spectators inside the arena
* `arena_lib.HUD_send_msg_team(HUD_type, arena, teamID, msg, <duration>, <sound>, <color>)`: same as above, but just for the players in team `teamID`
* `arena_lib.HUD_hide(HUD_type, pname_or_arena)`: makes the specified HUD disappear; it can take both the name of the player/spectator and a whole arena. Also, a special parameter `"all"` can be used in `HUD_type` to make all the HUDs disappear. Automatically called when a player leaves an arena (with `"all"`)

Keep also in mind that nametags are stored when entering and restored when leaving. This means that nametags can be used as a custom HUD too (e.g. to display the score of a certain player above their head), using the default Minetest API.

### 1.8 Utils
There are also some other functions which might turn useful. They are:
* `arena_lib.is_player_in_queue(p_name, <mod>)`: returns a boolean. If a mod is specified, returns true only if `p_name` is inside a queue of that specific mod
* `arena_lib.is_player_in_arena(p_name, <mod>)`: returns a boolean. Same as above. Contrary to `is_player_playing(..)`, it doesn't distinguish between an actual player and a spectator
* `arena_lib.is_player_playing(p_name, <mod>)`: returns `true` if `p_name` is actively playing inside a minigame - as in, not spectating
* `arena_lib.is_player_in_same_team(arena, p_name, t_name)`: compares two players teams by the players names. Returns true if on the same team, false if not
* `arena_lib.has_player_been_kicked(p_name)`: returns whether a player has been recently kicked through `/arenas kick` (boolean) and, if positive, also the time left before they can enter a new game (as an int)
* `arena_lib.start_arena(mod, arena)`: instantly starts a loading arena (useful for when you don't want to wait until the end)
* `arena_lib.load_celebration(mod, arena, winners)`: ends an ongoing arena, calling the celebration phase. `winners` can either be a string (the name of the winner), an integer (the ID of the winning team), a table of strings/integers (more players/teams) or `nil` (no winners)
* `arena_lib.force_start(<sender>, mod, arena)`: forcibly loads (if in queue) or starts (if in the loading phase) a game. If `sender` is `nil` or it doesn't represent an online player, log messages will be printed in console
* `arena_lib.force_end(sender, mod, arena)`: forcibly ends an ongoing arena. It's usually called by `/forceend`, but it can be used, for instance, to annul a game
  * `sender` will inform players about who called the function
  * The associated callback is `on_end`, *not* `on_quit`
* `arena_lib.join_queue(mod, arena, p_name)`: adds `p_name` to the queue of `arena`. Returns `true` if successful. If the player is already in a different queue, they'll be removed from the one they're currently in and automatically added to the new one
* `arena_lib.remove_player_from_queue(p_name)`: removes the player from the queue is in, if any. Returns `true` if successful
* `arena_lib.remove_player_from_arena(p_name, reason, <xc_name>, <elim_msg>)`: removes the player from the arena and it brings back the player to the game world if still online. This is already extensively used within arena_lib, but modders can use it to customise their gameplay (e.g. to eliminate a player or to automatically kick a user who went AFK). This is *not* called when an arena is forcibly terminated
	* `reason` is an integer, and it equals to...
		* `0`: player disconnected. Default used when: players disconnect
		* `1`: player eliminated. It doesn't work if the arena is in the celebration phase. Default used when: ---
		* `2`: player kicked. Default used when: players are kicked through `/arenas kick`. When kicked, they must wait 2 minutes before re-entering a match
		* `3`: player quits. Default used when: players do `/quit` or when they leave the spectator mode
		* All these reasons call `on_quit`, with the only exception of `1`, that calls `on_eliminate` if declared, and that only calls `on_quit` if there is no spectate mode
	* `xc_name` is a string that can be passed to tell who removed the player in case of elimination or kick (the executioner, that is). It doesn't forcibly have to be a player name (e.g. `"the void"`). By default, it's used with `/arenas kick`, returning the name of the one who used the command so that it can't be abused without consequences for the admin
	* `elim_msg` is a string that can be passed to send a custom elimination message. It's handy when the modder wants to send different messages according to the reason the player has been eliminated (e.g. "Wanted to swim in lava", "Jumped from a high place"). Also, contrary to the ones in `custom_messages`, the optional translation doesn't happen in arena_lib (meaning the string must be passed already translated), so it's also useful if the modder wants to omit or add some information, as it doesn't have to follow the amount of translation variables (e.g. the minigame can tell that someone has been eliminated by someone else, without saying the name of the victim).
* `arena_lib.send_message_in_arena(arena, channel, msg, <teamID>, <except_teamID>)`: sends a message to all the players/spectators in that specific arena, according to what `channel` is: `"players"`, `"spectators"` or `"both"`. If `teamID` is specified, it'll be only sent to the players inside that very team. On the contrary, if `except_teamID` is `true`, it'll be sent to every player BUT the ones in the specified team. These last two fields are pointless if `channel` is equal to `"spectators"`
* `arena_lib.print_error(p_name, msg)`: sends a message to `p_name` in the arena_lib error format. If `p_name` is either `nil` or it doesn't represent an online player, the message is printed in console instead ("error" level)
* `arena_lib.add_spectate_entity(mod, arena, e_name, entity)`: adds to the current ongoing match a spectatable entity, allowing spectators to spectate more than just players. `e_name` is the name that will appear in the spectator info hotbar, and `entity` the `luaentity` table. When the entity is removed/unloaded, automatically calls `remove_spectate_entity(..)`
* `arena_lib.add_spectate_area(mod, arena, pos_name, pos)`: same as `add_spectate_entity`, but it adds an area instead. `pos` is a table containing the coordinates of the area to spectate
* `arena_lib.remove_spectate_entity(mod, arena, e_name)`: removes an entity from the spectatable entities of an ongoing match
* `arena_lib.remove_spectate_area(mod, arena, pos_name)`: removes an area from the spectatable areas of an ongoing match
* `arena_lib.spectate_target(mod, arena, sp_name, type, t_name)`: forces `sp_name` to spectate a specific target, if exists. `type` is a string that can either be `"player"`, `"entity"` or `"area"`
* `arena_lib.is_player_spectating(sp_name)`: returns whether a player is spectating a match, as a boolean
* `arena_lib.is_player_spectated(p_name)`: returns whether a player is being spectated
* `arena_lib.is_entity_spectated(mod, arena_name, e_name)`: returns whether an entity is being spectated
* `arena_lib.is_area_spectated(mod, arena_name, pos_name)`: returns whether an area is being spectated
* `arena_lib.is_arena_in_edit_mode(arena_name)`: returns whether the arena is in edit mode or not, as a boolean
* `arena_lib.is_player_in_edit_mode(p_name)`: returns whether a player is editing an arena, as a boolean
* `arena_lib.is_player_in_region(arena, p_name)`: returns whether a player is inside the region of `arena`, if declared
* `arena_lib.reset_map(mod, arena)`: soft-regenerates the map of the arena. Check [Map regeneration](#2231-map-regeneration) to learn about how it works and the difference between a soft and a hard reset
* `arena_lib.hard_reset_map(sender, mod, arena_name)`: hard-regenerates the map of the arena by pasting its schematic, if any. Check [Map regeneration](#2231-map-regeneration) to know more about it

### 1.9 Getters
* `arena_lib.get_arena_by_name(mod, arena_name)`: returns the ID and the whole arena. Contrary to the duo `get_arena_by_player` and `get_arenaID_by_player`, this is not split in two as these two variables are often needed together inside arena_lib
* `arena_lib.get_mod_by_matchID(matchID)`: returns the mod of the arena having `matchID` as match ID, if any
* `arena_lib.get_arena_by_matchID(matchID)`: returns the ID and the whole arena, if any arena with that match ID exists
* `arena_lib.get_mod_by_pos(pos)`: returns the mod whose arena's region contains `pos`, if any
* `arena_lib.get_arena_by_pos(pos, <mod>)`: returns the arena containing `pos` in its region, if any. If `mod` is specified, it'll only cycle through the arenas belonging to that mod
* `arena_lib.get_mod_by_player(p_name)`: returns the minigame a player's in (game or queue)
* `arena_lib.get_arena_by_player(p_name)`: returns the arena the player's in (game or queue)
* `arena_lib.get_arenaID_by_player(p_name)`: returns the ID of the arena the player's in (game or queue)
* `arena_lib.get_arena_spawners_count(arena, <team_ID>)`: returns the total amount of spawners declared in the specified arena. If `team_ID` is specified, it'll only return the amount of spawners belonging to that team
* `arena_lib.get_random_spawner(arena, <team_ID>)`: returns a random spawner declared in the specified arena. If team_ID is specified, it only considers the ones belonging to that team
* `arena_lib.get_players_amount_left_to_start_queue(arena)`: returns the amount of player still needed to make a queue start, or `nil` if the arena is already in game
* `arena_lib.get_players_in_game()`: returns a table containing as value the names of all the players playing in whatever arena of whatever minigame
* `arena_lib.get_players_in_minigame(mod, <to_player>)`: returns a table containing as value either the names of all the players inside the specified minigame (`mod`) or, if `to_player` is `true`, the players themselves
* `arena_lib.get_players_in_team(arena, team_ID, <to_player>)`: returns a table containing as value either the names of the players inside the specified team or, if `to_player` is `true`, the players themselves
* `arena_lib.get_active_teams(arena)`: returns an ordered table having as values the ID of teams that are not empty
* `arena_lib.get_target_spectators(mod, arena_name, type, t_name)`: returns a list containing all the spectators currently following `t_name`. Format `{sp_name = true}`. For players, consider using the next function instead
* `arena_lib.get_player_spectators(p_name)`: Like `get_target_spectators(..)` but cleaner and just for players. It's cleaner since there can't be two players with the same name, contrary to areas and entities
* `arena_lib.get_spectated_target(sp_name)`: returns the target `sp_name` is currently spectating, if any, as a table. Format `{type = "..", name = ".."}`
* `arena_lib.get_spectatable_entities(mod, arena_name)`: returns a table containing all the spectatable entities of `arena_name`, if any. Format `{e_name = entity}`, where `e_name` is the name used to register the entity in `add_spectate_entity(..)` and `entity` the `luaentity` table
* `arena_lib.get_spectatable_areas(mod, arena_name)`: same as in `get_spectatable_entities(..)` but for areas. Entities returned in the table are the dummy ObjectRef entities put at the area coordinates
* `arena_lib.get_player_in_edit_mode(arena_name)`: returns the name of the player who's editing `arena_name`, if any

### 1.10 Endless minigames
As the name suggests, endless minigames have got no end. When the server starts, all the enabled arenas of an endless minigame are automatically loaded and the only way to stop them is to disable them (e.g. by entering the editor). Calling the end of an arena will also try to disable the arena (i.e. through `/arenas forceend` or the respective function `force_end`); in case the disabling process should fail, the arena will be automatically launched again.  

Endless minigames have got no celebration phase: if this phase is called, arena_lib will ignore it. On the contrary, they do have a loading phase, which is useful to get the arena ready and avoid collateral damage through the entrance of players.  

If declared, minigame parameters `join_while_in_progress` and `min_players` are ignored, as they're forced respectively to `true` and `0`. Minigame parameter `end_when_too_few` is ignored as well, since the match can't end anyway. The same applies to the arena parameter `min_players` (always `0`) and to `time_mode = "decremental"`.

### 1.11 Custom entrances
Since 5.3, signs are not the only way anymore to link an arena with the rest of the world. Instead, modders can create third party mods to register their own custom entrance type. To do that, the function is
```lua
arena_lib.register_entrance_type(mod, entrance, def)
```
* `mod`: (string) the name of the third party mod. There can only be one entrance type per mod
* `entrance`: (string) the name used to register the entrance type
* `def`: (table) a table containing the following fields:
	* `name`: (string) the name of the entrance. Contrary to the previous `entrance` field, this can be translated
	* `on_add`: (function(sender, mod, arena, ...)) must return the value that will be used by arena_lib to identify the entrance. For instance, built-in signs return their position. If nothing is returned, the adding process will be aborted. Substitute `...` with any additional parameters you may need (signs use it for their position). BEWARE: arena_lib will already run general preliminar checks (e.g. the arena must exist) and then set the new entrance. Use this callback just to run entrance-specific checks and return the value that arena_lib will then store as an entrance
	* `on_remove`: (function(mod, arena)) additional actions to perform when an arena entrance is removed. BEWARE: arena_lib will already run general preliminar checks (e.g. the arena must exist) and then remove the entrance. Use this callback just to run entrance-specific checks.
	* `on_update`: (function(mod, arena)) what should happen to each entrance when the status of the associated arena changes (e.g. when someone enters, when the arena gets disabled etc.)
	* `on_load`: (function(mod, arena)) additional actions to perform when the server starts. Useful for nodes, since they don't have an `on_activate` callback, contrary to entities
	* `editor_settings`: (table) how the editor section should be structured, when an arena uses this entrance type. Fields are:
		* `name`: (string) the name of the item representing the section
		* `icon`: (string) the image of the item representing the section
		* `description`: (string) the description of the section, shown in the semi-transparent black bar above the hotbar
		* `items`: (function(p_name, mod, arena)) must return a table containing the name of the items that shall be put into the editor section once opened. Max 6 entries. Contrary to a table, the function allows to dynamically change the given items according to external factors (e.g. a specific arena property)
		* `on_enter`: (function(p_name, mod, arena)) called when entering the editor. Useful to reset entrance properties bound to `p_name`, as it's the only way the player has to know that the editor has been entered by someone
	* `debug_output`: (function(entrance)): what the debug log should print (via `arena_lib.print_arena_info()`)

Then, a useful function you want to call through the tools in the editor section is `arena_lib.set_entrance(sender, mod, arena_name, action, ...)`, where `action` is a string taking either `"add"` or `"remove"`. In case of `"add"`, you can also attach whatever parameter(s) you want after `action`. For instance, built-in signs pass the pointed position, which is then checked on `on_add` and lastly returned so that arena_lib can add it. These checks are not run in the tool itself because this won't allow to run them outside the editor (i.e. CLI and custom calls from other mods).  

If you're a bit confused, have a look at [this mod](https://gitlab.com/marco_a/arena_lib-entrance-test) for a practical implementation.  

If the registration was successful, it'll appear in the list of entrances type displayed with `/arenas entrances <minigame>`.

### 1.12 Extendable editor
Since 4.0, every minigame can extend the editor with an additional custom section on the 6th slot. To do that, the function is
```lua
arena_lib.register_editor_section("yourmod", {param1, param2 etc})
```
Every parameter here is mandatory. They are:
* `name`: the name of the section, it'll appear in the hotbar HUD
* `icon`: the icon that will represent the section
* `give_items = function(itemstack, user, arena)`: this function must return the list of items to give to the player once the section has been opened, or `nil` if we want to deny the access. Having a function instead of a list is useful as it allows to run whatever check inside of it, and to give different items accordingly. The name of each item will be displayed in the hotbar HUD when wielded

When a player is inside the editor, they have 2 string metadata containing the name of the mod and the name of the arena that's currently being modified. These are necessary to do whatever arena operation with items passed via `give_items`, as they allow to obtain the arena ID and the arena itself via `arena_lib.get_arena_by_name(mod, arena_name)`. To better understand this, have a look at how [arena_lib does](src/editor/tools_players.lua).  

If you want to use an arena_lib function inside the logic of the items of your section, you must pass an additional parameter at the end: `true`. This tells arena_lib that the action is run whilst being inside the editor - e.g. instead of `arena_lib.change_teams_amount(sender, mod, arena_name, amount)`, you shall use `arena_lib.change_teams_amount(sender, mod, arena_name, amount, true)`. If you don't, the function will most likely stop you from running it.  

### 1.13 Things you don't want to do with a light heart
* Changing the number of teams in your minigame registration, if `variable_teams_amount` is `false`: it'll delete your spawners (this has to be done in order to avoid further problems)
* Removing properties in the minigame declaration: it'll delete their value from every arena, without any possibility to get it back. Always do a backup first
* Disabling timers (`time_mode = "decremental"` to something else) when arenas have custom timer values: it'll reset every custom value, so you have to put them again manually if/when you decide to turn timers back up  
<br>  

## 2. Arenas

It all starts with a table called `arena_lib.mods = {}`. This table allows `arena_lib` to be subdivided per mod and it has different parameters, one being `arena_lib.mods[yourmod].arenas`. Here is where every new arena created gets put.  
An arena is a table having as a key an ID and as a value its parameters. They are:
* `name`: (string) the name of the arena, declared when creating it
* `matchID`: (int) a unique 9 digit identifier, generated every time a match loads and emptied (`nil`) when it ends.
* `author`: (string) the name of the one who built/designed the map. Default is `"???"`. It appears in the signs infobox (right-click an arena sign)
* `thumbnail`: (string) the name of the optional file representing the arena, extension included. Default is `""`, meaning no thumbnail is associated with the arena. It must be put inside the `arena_lib/Thumbnails` world folder. If present, it can be seen by right-clicking built-in arena signs.
* `entrance_type`: (string) the type of the entrance of the arena. By default it takes the `arena_lib.DEFAULT_ENTRANCE` settings (which is `"sign"` by default)
* `entrance`: (can vary) the value used by arena_lib to retrieve the entrance linked to the arena. Built-in signs use their coordinates
* `custom_return_point`: (table) a position that, if declared, overrides the `return_point` server setting (see [1.1 Per server configuration](#11-per-server-configuration)). Default is `nil`
* `pos1`: (table) one of the corners that determine the region of the arena, alongside `pos2`. Check [#2.2.3 - Arena regions](#223-arena-regions) to learn more. Default is `nil`
* `pos2`: ^
* `players`: (table) where to store players information. Default fields are `teamID` (if teams are enabled) and the death counter `deaths`. `player_properties` fields expand the list. Format `{[p_name] = {stuff}, [p_name2] = {stuff}, ..}`
* `spectators`: (table) where to store spectators information. Format `{[sp_name] = {optional spectator_properties}}`
* `players_and_spectators`: (table) where to store both players and spectators names. Format `{[psp_name] = true}`
* `past_present_players`: (table) keeps track of every player who took part to the match, even if they are spectators now or they left. Contrary to `players` and `players_and_spectators`, this is created when the arena loads, so it doesn't consider people who joined and left during the queue. Format `{[ppp_name] = true}`
* `past_present_players_inside`: (table) same as `past_present_players` but without keeping track of the ones who left
* `teams`: (table) where to store teams information, such as their name (`name`) and `team_properties`. If there are no teams, it's `{-1}`. If there are, format is `{[teamID] = {stuff}, [teamID2] = {stuff}, ...}`
* `teams_enabled`: (boolean) whether teams are enabled in the arena. Requires teams
* `players_amount`: (int) separately stores how many players are inside the arena/queue
* `players_amount_per_team`: (table) separately stores how many players currently are in a given team. Format `{[teamID] = amount}`. If teams are disabled, it's `nil`
* `spectators_amount`: (int) separately stores how many spectators are inside the arena
* `spectators_amount_per_team`: (table) like `players_amount_per_team`, but for spectators
* `spectate_entities_amount`: (int) the amount of entities that can be currently spectated in an ongoing game. If spectate mode is disabled, it's `nil`. Outside of ongoing games is always `nil`
* `spectate_areas_amount`: (int) like `spectate_entities_amount` but for areas
* `spawn_points`: (table) contains information about the arena spawn points. Format is `spawn_points[id]` when teams are not enabled, and `spawn_points[team_ID][id]` when they are
* `min_players`: (string) default is 2. If teams are enabled, value is per team. When this value is reached, a queue starts
* `max_players`: (string) default is 4. If teams are enabled, value is per team. When this value is reached, queue time decreases to 5 if it's not lower already. If `-1`, the arena won't have any players limit.
* `initial_time`: (int) in seconds. It's `nil` when the mod doesn't keep track of time, it's 0 when the mod does it incrementally and it's inherited by the mod if the mod has a timer. In this case, every arena can have its specific value. By default time tracking is disabled, hence it's `nil`
* `current_time`: (int) in seconds. It requires `initial_time` and it exists only when a game is in progress, keeping track of the current time
* `celestial_vault`: (table) if present, contains the information about the celestial vault to display to each player whilst in game, overriding the default one. Default is `nil`.
* `weather`: (table) if present, contains the particle to assign to players whilst in game. Default is `nil`.
* `lighting`: (table) if present, contains the information about the lighting settings of the arena, overriding players' default ones. Default is `nil`
* `bgm`: (table) if present, contains the information about the audio track to play whilst in game. Audio tracks must either registered through audio_lib or be placed in the `arena_lib/BGM` world folder (where this registration is done automatically) in order to be found. Default is `nil`
  In-depth fields, all empty by default, are:
  * `track`: (string) the audio file, without `.ogg`. Mandatory. If no track is specified, all the other fields will be consequently empty
  * `title`: (string) the title. Built-in signs feature it in the infobox (shown by right-clicking a sign)
  * `author`: (string) the author. Built-in signs feature it in the infobox (shown by right-clicking a sign)
  * `gain`: (int) the volume of the track
  * `pitch`: (int) the pitch of the track
* `in_queue`: (bool) about phases, look at "Arena phases" down below
* `in_loading`: (bool)
* `in_game`: (bool)
* `in_celebration`: (bool)
* `enabled`: (bool) by default an arena is disabled, to avoid any unwanted damage
* `is_resetting`: (bool) whether a map is being regenerated. It requires the `regenerate_map` ingredient

> **BEWARE**: don't edit these parameters manually! Each one of them can be set through some arena_lib function, which runs the required checks in order to avoid any collateral damage

Being arenas stored by ID, they can be easily retrieved by `arena_libs.mods[yourmod].arenas[ARENAID]`.  

There are two ways to know an arena ID: the first is in-game via the two built-in commands:
* `/arenas list <minigame>`: concise
* `/arenas info (<minigame>) <arena>`: extended with much more information (this is also implemented in the editor by default - the "i" icon)

The second is via code through the functions:
* `arena_lib.get_arenaID_by_player(p_name)`: the player must be either playing or spectating in the arena
* `arena_lib.get_arena_by_name(mod, arena_name)`: it returns both the ID and the arena (so the table)

### 2.1 Storing arenas
Arenas and their settings are stored inside the mod storage. What is *not* stored are players, their stats and such.  
Better said, these kind of parameters are emptied every time a game ends, and arena_lib never writes onto storage when games or queues are in progress (so to avoid polluting entries).

### 2.2 Setting up an arena
In order for an arena to be playable, four conditions must be satisfied: the arena has to exist, at least one spawner has to be set (it's per team if teams are enabled), an arena entrance must be put (to allow players to enter the minigame), and any potential custom check in the `arena_lib.on_enable` callback must go through. Additionally, arenas having a [region](#223-arena-regions) must not have spawners outside it.

If you love yourself, there is a built-in editor that allows you to easily make these things and many many more. Or, if you don't love yourself, you can connect every setup function to your custom CLI. Either way, run `/arenas create <minigame> <arena>` to create your first arena.

### 2.2.1 Editor
arena_lib comes with a fancy editor via hotbar so you don't have to configure and memorise a lot of commands.  
In order to use the editor, no other players shall be editing the same arena and there shall not be any ongoing game. When entering, the arena is disabled automatically and the entering player is teleported at the first arena spawn or at the center of the arena's region, if at least one of the two things exist. The rest is pretty straightforward :D

The command calling the editor is `/arenas edit (<minigame>) <arena>`. Feel now free to skip to [2.2.3 Arena regions](#223-arena-regions).

#### 2.2.2 CLI
If you don't want to rely on the hotbar, or you want both the editor and the commands via chat, here's how the commands work. Note that:
* `sender`, which appears as the first argument of every function, can be also `nil` or `""`. If that's the case, arena_lib will print the output in console, "error" level
* there is actually another parameter at the end of each of these functions named `in_editor` but, since it's solely used by the editor itself in order to run less checks, I've chosen to omit it

##### 2.2.2.1 Changing arenas name, author, thumbnail
`arena_lib.rename_arena(sender, mod, arena_name, new_name)`: renames an arena. Being arenas stored by ID, changing their names is no big deal.
`arena_lib.set_author(sender, mod, arena_name, author)`: changes the name of the author who has built the arena.
`arena_lib.set_thumbnail(sender, mod, arena_name, thumbnail)`: changes the thumbnail of the arena. `thumbnail` is the name of the file, including its extension. It must be inside the `arena_lib/Thumbnails` world folder.

##### 2.2.2.2 Players management
`arena_lib.change_players_amount(sender, mod, arena_name, min_players, max_players)` changes the amount of players in a specific arena. It also works by specifying only one field (such as `([...] myarena, 3)` or `([...] myarena, nil, 6)`). It returns true if it succeeds.

`arena_lib.change_teams_amount(sender, mod, arena_name, amount)` changes the amount of teams in a specific arena. It'll use the first N teams declared, where N is `amount`. It returns `true` if it succeeds.

##### 2.2.2.3 Enabling/Disabling teams
`arena_lib.toggle_teams_per_arena(sender, mod, arena_name, enable)` enables/disables teams per single arena. `enable` is a boolean.

##### 2.2.2.4 Spawners
`arena_lib.set_spawner(sender, mod, arena_name, <teamID>, <param>, <coords>)` can create and delete spawners.
* creation: leave `param` nil. It creates a spawner at `coords`, if specified, or where the sender is standing - so be sure to stand where you want the spawn point to be
* deletion: set `param` equal to `"delete"` or `"deleteall"`
  * `"delete"` deletes the closest spawner to the player. It requires `teamID` if teams are enabled
  * Single spawners are deleted through `table.remove`, meaning that there won't ever be a gap in the sequence (e.g. removing spawn point n°2 in sequence 1, 2, 3, 4, it won't result in 1, 3, 4 but in 1, 2, 3, where 2 and 3 previously were 3 and 4)
  * If a team ID is specified alongside `"deleteall"`, arena_lib will only delete the spawners belonging to that team

##### 2.2.2.5 Entering and leaving
To set an entrance, use `arena_lib.set_entrance(sender, mod, arena_name, action, ...)`. For further documentation, see [1.11 Custom entrances](#111-custom-entrances).  
To change entrance type, use `arena_lib.set_entrance_type(sender, mod, arena_name, type)`, where `type` is a string representing the name of the registered entrance type you want to use.

To customise the arena return point (by default `return_point`), use `arena_lib.set_custom_return_point(sender, mod, arena_name, pos)`. To remove the custom return point, set `pos` to `nil`.

##### 2.2.2.6 Arena properties
[Arena properties](#151-arena-properties) allow you to create additional persistent attributes specifically suited for what you have in mind (e.g. a score to reach to win the game).
`arena_lib.change_arena_property(<sender>, mod, arena_name, property, new_value)` changes the specified arena property with `new_value`. If `sender` is nil, the output message will be printed in the log. Keep in mind that you can't change a property type (a number must remain a number, a string a string etc), and strings need quotes surrounding them - so `false` is a boolean, but `"false"` is a string. Also, as the title suggests, this works for *arena* properties only. Not for temporary, players, nor team ones.

##### 2.2.2.7 Timers
`arena_lib.set_timer(sender, mod, arena_name, timer)` changes the timer of the arena. It only works if timers are enabled (`time_mode = "decremental"`).

##### 2.2.2.8 Music
`arena_lib.set_bgm(sender, mod, arena_name, bgm_table)` sets the background music of the arena.
  * The audio table is composed as such:
  ```lua
  {
    track = "mysong",			-- the audio file name, without '.ogg'
    description = "uplifting song",	-- a short description for accessibility
    title = "Getting ready",		-- the song title. Used by default in the default signs entrance
    author = "myself",			-- the author of the song. Same as above
    gain = 1.1,			-- the volume of the song
    pitch = 0.9,			-- the pitch of the song
  }
  ```
  * the audio file must be registered through audio_lib or put inside the `arena_lib/BGM` world folder (where the registration is done automatically)
  * If `bgm_table` is `nil`, `arena.bgm` will be set to `nil` too

##### 2.2.2.9 Celestial vault
By default, the arena's celestial vault reflects the celestial vault of the player before entering the match (meaning there are no default values inside arena_lib).  
`arena_lib.set_celestial_vault(sender, mod, arena_name, element, params)` allows you to change parts of the vault, forcing it to players entering the arena. `element` is a string representing the part of the vault to be changed (`"sky"`, `"sun"`, `"moon"`, `"stars"`, `"clouds"`, or the explained later `"all"`), and `params` a table with the new values. This table is the same as the one used in the Minetest API `set_sky(..)`, `set_sun(..)` etc. functions, so for instance doing

```lua
	local sun_params = {
		scale = 2.5,
		sunrise_visible = false
	}
	arena_lib.set_celestial_vault(sender, mod, arena, "sun", sun_params)
```
will increase the size of the sun inside the arena and hide the sunrise texture. `params` can also be `nil`, and in that case will remove any custom setting previously set.  
Last but not least, the special element `"all"` allows you to change everything, and it needs a table with the following optional parameters: `{sky={...}, sun={...}, moon={...}, stars={...}, clouds={...}}`. If `params` is nil, it'll reset the whole celestial vault.

##### 2.2.2.10 Weather
Arenas can have a custom weather condition, in the shape of a particle spawner assigned per player. The editor offers 3 states (rain, snow and dust), but using the API call allows to customise the particle spawner with basically no limits. The function is
`arena_lib.set_weather_condition(sender, mod, arena_name, particles)`, where `particles` is a table that can contain the following fields:
* `image`: (string) the image of the particle
* `height`: (int) the height where particles will spawn (±3.5)
* `amount`: (int) the amount of particles
* `vel`: (int) the Y speed of particles (±0.15)
* `scale`: (int) the size of particles (±1.5)
* `opacity`: (table) table containing the minimum and the amount opacity of particles, between 0 and 1 (e.g. `{0.7, 1}`)
* `collide`: (boolean) whether particles collide
* `remove_on_coll`: (boolean) whether particles are removed when colliding (requires `collide`)

##### 2.2.2.11 Lighting
NOTE: EXPERIMENTAL FEATURE. EXPECT BREAKAGE IN THE FUTURE (according to the direction Minetest will choose to go with lighting)  
By default, the arena's lighting settings reflect the lighting settings of the player before entering the match (meaning there are no default values inside arena_lib).  
`arena_lib.set_lighting(sender, mod, arena_name, light_table)` allows you to override those settings. If `light_table` is `nil`, it'll reset the whole lighting settings. It can contain the following fields:  
  * `light`: (float) 0-1, changes the intensity of the global lighting
  * `saturation`: (float) 0-1, changes the saturation

##### 2.2.2.12 Region
`arena_lib.set_region(sender, mod, arena_name, pos1, pos2)` allows you to set the region of the arena. `pos1` and `pos2` are both mandatory and they both need to be vectors (passing a table such as `{x=3,z=4,y=2}` won't work).

###### 2.2.2.12.1 Schematics
* `arena_lib.save_map_schematic(sender, mod, arena_name)`: saves a schematic in the world folder, following the pattern `<modname>_<arenaID>`.

#### 2.2.3 Arena regions
An arena region is an optional cuboid wrapping the arena (there can be only one per arena), that can be used for several purposes. An example is to save and then restore the arena map once the match is over, or eliminate any player that goes outside it. By default, from arena_lib 7.0 they're used to regenerate the map (`regenerate_map = true`).
When a region is declared, be sure that every existing spawn point is placed inside the region, or it won't be possible to enable the arena.  

Util functions that come with it are `arena_lib.is_player_in_region(..)`, `arena_lib.get_arena_by_pos(..)`, `arena_lib.reset_map(..)` and `arena_lib.hard_reset_map(..)`.

##### 2.2.3.1 Map regeneration
Due to current Minetest limitations in both performance and design, and after several experiments, arena_lib's default map regeneration system balances server performance (no lag) with usability (not everything can be reset, so keep reading). Nonetheless, the mod also comes with a hard reset system, which is prone to cause lag but is able to reset every kind of node, except for inventory nodes.  
In order for these systems to work, an arena region must be set.  

In case you want to regenerate a map manually (e.g. during a game), you can use `arena_lib.reset_map(..)`/`hard_reset_map(..)`.  

If you want to use inventory nodes, since they can't be restored anyway, the suggested approach is to place such nodes during the loading phase (e.g. by previously storing the coordinates of where those inventories should be, as an arena property).

###### 2.2.3.1.1 Soft reset
Soft reset requires `regenerate_map` ingredient to be `true`, the arena to be enabled and no regeneration to be in progress (`is_resetting = false`). When `regenerate_map` is `true`, arenas can't be edited if they're enabled and no match is in progress, so if you want to change their aspect you need to disable them first.  
Arenas' maps are soft restored by default when the match ends or, in case of a crash, when the server restarts. Whatever the reason, arenas' `is_resetting` becomes `true` until the map finishes regenerating.  

Due to the aforementioned Minetest limitations, not every node can be restored. For this reason, **do not** use the following approaches to alter the map or arena_lib won't be able to track the change:
* ABM, LBM (e.g. liquids)
* VoxelManip
* inventory nodes

###### 2.2.3.1.2 Hard reset  
Hard resets are not called by default. However, this system is useful both for backups and for restoring every kind of node (except for inventories).  
Hard resets need an arena schematic, that can be saved either from the editor (where it can also be pasted back) or through `save_map_schematic(..)`. Keep in mind that:
1. the bigger the map, the higher the chance to cause a lag spike, so avoid doing such operation with players online as it might interfere with their gameplay
2. schematics on Minetest are cached when loaded. Meaning that, if the schematic changes, the server needs to be rebooted in order to paste the new version

### 2.3 Arena phases
An arena comes in 4 phases:
* `queuing phase`: the queuing process. People interact with the entrance waiting for other players to play with
* `loading phase`: the pre-match. By default players get teleported in the arena, waiting for the game to start. Relevant callback: `on_load`
* `playing phase`: the actual game. Relevant callbacks: `on_start`, `on_join`
* `celebration phase`: the after-match. By default people stroll around for the arena knowing who won, waiting to be teleported. Relevant function: `arena_lib.load_celebration(..)`. Relevant callbacks: `on_celebration`, `on_end`.


### 2.4 Teams management
By default, teams are not enabled. They can be activated globally by declaring the `teams` minigame ingredient, but also locally by using the `can_disable_teams` ingredient to tweak which arena teams should be present in.  

It's possible to retrieve the team a player's in by accessing the built-in `teamID` player property. Teams are determined right before launching the loading phase, meaning that retrieving `teamID` on a player that is queuing will return `nil`. The only exception is people in parties (it requires `parties` mod), since arena_lib needs to know what slots of what teams are already taken. This is done both to check if there's enough space left for other parties and to know how to equally distribute solo-queuing players.

#### 2.4.1 Teams assignment
Default players distribution when joining an ongoing game is pretty straightforward (fill the team with the least players), but queues are more elaborated.  
In queues, teams are assigned with the following logic:
* when joining the queue (parties only): starting from `teamID` 1, put the party in the team with the least amount of players. In case of a game with 3+ teams, where all teams are already featuring a party, check if the joining party has more players of the team with the second least players. If it does, merge the players of the two teams with the least players into the same team and put the joining party into a team on its own. E.g. 2, 3, 5 ..4.. => 4, 5 (2+3), 5 (and not 6 (2+4), 3, 5)
* right before the loading phase: if there are no parties queuing, evenly distribute players in teams. If there are, distribute players until every team has the same amount; then, evenly distribute the remaining players, if any

If you're not happy of how people are split into teams (e.g. a minigame with an ELO system), you can override the distribution by writing your own assigning system. This is done through the `on_generate_teams` (for queues) and `on_assign_team` (for ongoing games) callbacks.  

The former is `on_generate_teams(arena, max_curr_amount)`, where `max_curr_amount` is the amount of players of the team that currently features the most (so, people in parties).  
In order to work, the following conditions must be satisfied at the end of the callback:
* no empty teams
* every player has a `teamID` assigned (`arena.players[p_name].teamID`)
* `players_amount_per_team` is equivalent to the amount of players of each team (you could increase it every time you assign a team)
* (not mandatory, yet nice) avoid splitting people in parties into different teams, as it'd make parties basically useless

On the contrary, `on_assign_team(arena, p_name)` is only applied to `p_name` (and their potential party) and it must return the team ID that will be assigned to them. Contrary to `on_generate_teams`, modders mustn't touch anything: no internal `teamID` assignment nor `players_amount_per_team` increment; just return the desired teamID and arena_lib will do the rest.  


### 2.5 Spectate mode
Every minigame has this mode enabled by default. As the name suggests, it allows people to spectate a match, and there are two ways to enter this mode: the first is by getting eliminated (`remove_player_from_arena` with `1` as a reason), whereas the other is through the very entrance of the arena (if implemented). While in this state, they can't interact in any way with the actual match: neither by hitting entities/blocks, nor by writing in chat. The latter, more precisely, is a separated chat that spectators and spectators only are able to read. Vice versa, they're not able to read the players one.  
By default, spectate mode allows to follow players, but it also allows modders to expand it to entities and areas. To do that, have a look at `arena_lib.add_spectate_entity(..)` and `arena_lib.add_spectate_area(..)`
<br>  


## 3. About the author(s)
I'm Zughy (Marco), a professional Italian pixel artist who fights for FOSS and digital ethics. If this library spared you a lot of time and you want to support me somehow, please consider donating on [Liberapay](https://liberapay.com/Zughy/). Also, this project wouldn't have been possible if it hadn't been for some friends who helped me testing through: `Giov4`, `SonoMichele`, `_Zaizen_` and `Xx_Crazyminer_xX`

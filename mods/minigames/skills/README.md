# Skills

This Minetest library allows you to create skills, such as a super-high jump, a damaging aura, or passive stat boosts. These skills can be used to enhance gameplay or add new features to your mod.

<a name="registering"></a>

## Registering a skill
To register a skill, you can use the `skills.register_skill(internal_name, def)` function. The internal_name argument is the name you will use to refer to the skill in your code, and should be formatted as "unique_prefix:skill_name" (where the unique prefix could be the name of your mod, for example). The def argument is a definition table that contains various properties that define the behavior and appearance of the skill and can contain the following properties:
- `name` (string): the skill's name;
- `description` (string): the skill's description;
- `cooldown` (number): in seconds. It's the minimum amount of time to wait in order to cast the skill again;
- `cast(self, ...)`: it contains the skill's logic. It'll return false if the player is offline or the cooldown has not finished. You can also return false from inside the function to prevent the skill execution or stop a looped one after it has already started. The self parameter is a table containing [properties of the skill](#final_skill_table);
- `loop_params` (table): if this is defined, the skill will be looped. To cast a looped skill you need to use the `start(...)` function instead of `cast`. The `start` function simply calls the `cast` function at a rate of `cast_rate` seconds  (if cast_rate is defined, otherwise the skill's logic will never be executed);
    - `cast_rate` (number): in seconds. The rate at which the skill will be casted. Assigning 0 will loop it as fast as it can;
    - `duration` (number): in seconds. The amount of time after which the skill will stop;
- `passive` (boolean): false by default. If true the skill will start automatically once the player has unlocked it. 
    - It can be stopped calling `stop()` or [`disable()`](#final_skill_table) and restarted calling `start()` or [`enable()`](#other_functions);
- `blocks_other_skills` (boolean): false by default. Whether this skills has to disable all of the other skills while used;
- `can_be_blocked_by_other_skills` (boolean): true by default. Whether this skill will be disabled by other blocking skills (you may want to use this for a passive skill that just increases health, for example);
- `physics` (table): this table can contain any [physics property](https://github.com/minetest/minetest/blob/master/doc/lua_api.md?plain=1#L8084)'s field and must contain an `operation` field having one of the following values: `add`, `sub`, `multiply`, `divide` (e.g. {operation = "add", speed = 1} will add 1 to the player's speed).
- `sounds` (table): A sound, or a list of sounds that will be reproduced when a certain event triggers them. Every sound is a table, and is declared this way:
```
    name = "sound_name", 
    
    -- OPTIONAL PARAMS:
    to_player = false, 
    object = true,
    exclude_player = false,
    random_pitch = {min, max} 
    and other sound parameters/SoundSpec properties...]}
```

- 
    * If `to_player`, `object` or `exclude_player` are set to true their value will become the player's name/ObjectRef.
    * `random_pitch` is a custom property that will choose a random pitch between min and max everytime the sound is played. You can also pass a list of sounds, the mod will reproduce them all:
-  
    - The sound/sounds list must be put inside the desired event subtable, those being
        - `cast`: reproduced every time the `cast` function is called;
        - `start`: reproduced when the skill starts;
        - `stop`: reproduced when the skill stops;
        - `bgm`: looped sound(s), reproduced while the skill is being used;
- `hud` (`{{name = "hud_name", standard hud definition params...}, ...}`): a list of hud elements that appear while the skill is being used. They are stored in the `data._hud` table (`{"hud_name" = hud_id}`);
- `attachments` (table):
    - `particles` (`{ParticleSpawner1, ...}`): a list of particle spawners that are created when the skill starts and destroyed when it stops. They're stored in the `data._particles` table and are always attached to the player - it's useful if you want to have something like a particles trail;
    - `entities` (`{Entity1, ...}`): a list of entities that are attached to the player as long as the skill is being used. The entity are tables, declared this way 
```
    pos = {...}, -- player relative
    name = "Entity1",

    -- OPTIONAL PARAMS:
    bone = "bone",
    rotation = {...},
    forced_visible = false
```
- 
    - The staticdata passed to the entity's `on_activate` callback is the player name and it's automatically stored in the entity's `pl_name` property. 
    - **Beware**, the entities listed in here will be modified by setting their `static_save` parameter to false. In general, it's strongly discouraged to use these entities as something different than a skill attachment;
- `celestial_vault` (table) if one of these is defined, while the skill is being casted the celestial vault will change:
    - `sky` (table): [accepted parameters](https://github.com/minetest/minetest/blob/master/doc/lua_api.md?plain=1#L8188);
    - `moon` (table): [accepted parameters](https://github.com/minetest/minetest/blob/master/doc/lua_api.md?plain=1#L8289);
    - `sun` (table): [accepted parameters](https://github.com/minetest/minetest/blob/master/doc/lua_api.md?plain=1#L8267);
    - `stars` (table): [accepted parameters](https://github.com/minetest/minetest/blob/master/doc/lua_api.md?plain=1#L8267);
    - `clouds` (table): [accepted parameters](https://github.com/minetest/minetest/blob/master/doc/lua_api.md?plain=1#L8267);
- `on_start(...)`: this is called when `start` is called and the vararg `...` is the same value you pass to start. If this returns false, the skill execution will be cancelled;
- `on_stop()`: this is called when `stop` is called;
- `data` (table): this allows you to define custom properties for each player. These properties are stored in the mod storage and will not be reset when the server shuts down unless you change the type of one of them in the registration table (apart from userdata and functions). Be careful to avoid using names for these properties that start with an underscore (_).;
- `... any other properties you may need`: you can also define your own properties, just make sure that they don't exist already and remember that this are shared by all players.

Here some examples of how to register a skill:
<details>
<summary>click to expand...</summary>

```lua
skills.register_skill("example_mod:counter", {
    name = "Counter",
    description = "Counts. You can use it every 2s.",
    sounds = {
        cast = {name = "ding", pitch = 2}
    },
    cooldown = 2,
    data = {
        counter = 0
    },
    cast = function(self)
        self.data.counter = self.data.counter + 1
        print(self.pl_name .. " is counting: " .. self.data.counter)
    end
})
```

```lua
skills.register_skill("example_mod:heal_over_time", {
    name = "Heal Over Time",
    description = "Restores a heart every 3 seconds for 30 seconds.",
    loop_params = {
        cast_rate = 3,
        duration = 30
    },
    sounds = {
        cast = {name = "heart_added"},
        bgm = {name = "angelic_music"}
    },
    cast = function(self)
        local player = self.player
        player:set_hp(player:get_hp() + 2)
    end
})
```

```lua
skills.register_skill("example_mod:boost_physics", {
    name = "Boost Physics",
    description = "Multiplies the speed and the gravity x1.5 for 3 seconds.",
    loop_params = {
        duration = 3
    },
    sounds = {
        start = {name = "speed_up"},
        stop = {name = "speed_down"}
    },
    physics = {
        operation = "multiply",
        speed = 1.5,
        gravity = 1.5
    }
})
```

```lua
skills.register_skill("example_mod:set_speed", {
    name = "Set Speed",
    description = "Sets speed to 3.",
    passive = true,
    data = {
        original_speed = {}
    },
    on_start = function(self)
        local player = self.player
        self.data.original_speed = player:get_physics_override().speed

        player:set_physics_override({speed = 3})
    end,
    on_stop = function(self)
        self.player:set_physics_override({speed = self.data.original_speed})
    end
})
```

```lua
skills.register_skill("example_mod:iron_skin", {
    name = "Iron Skin",
    description = "Take half the damage for 6 seconds.",
    cooldown = 20,
    loop_params = {
        duration = 6,
    },
    sounds = {
        start = {name = "iron_skin_on", max_hear_distance = 6},
        stop = {name = "iron_skin_off", max_hear_distance = 6},
    },
    attachments = {
        entities = {{
            name = "example_mod:iron_skin",
            pos = {x = 0, y = 22, z = 0}
        }}
    },
    hud = {{
        name = "shield",
        hud_elem_type = "image",
        text = "hud_iron_skin.png",
        scale = {x=3, y=3},
        position = {x=0.5, y=0.82},
    }},
})
```
</details>


## Skill based on other skills
[🌐 Visual representation.](https://i.imgur.com/BaZxFsG.jpeg)

A skill based on another skill is a modified version that retains some of the original skill's properties, while keeping others the same. The original skills can be normal ones or layers. A layer is nothing more than a special type of skill that players can't unlock, and that won't be returned by `get_registered_skills()`. You can register one by using `skills.register_layer(internal_name, def)` - it works exactly like register_skill. You can create a layered skill by using `skills.register_skill_based_on("mod:original_skill_name" or {"mod:base_skill_1", "mod:base_skill_2", ...}, "mod:new_skill_name", def)`. The def table allows you to override any properties of the original skill(s) that you want to change in the new skill (any non-specified properties will be inherited from the original(s)). If you want to override one of the properties with a `nil` value just set it to `"@@nil"`.

When specifying more then one base skill, their functions will be joined together and the first parameter will always be "self". The same will happen if you define a new function in the def table (e.g. if you're creating a "s3" skill based on "s1" and "s2", and you defined "cast()" in each one of them, the joined cast function will have the following structure: `s1_cast(self, ...); s2_cast(same); s3_cast(same)`). If any of those functions return false, the following ones won't be called (this applies for every function in the skill: they will all be merged, even custom ones!). Beware, when you combine skills it's up to you to make sure they can work together, so make sure they have the same cast_rate, don't overwrite each other's parameters, etc.

This type of skill can be useful to modularize behavior: a layer can manage checks common to certain types of skills, such as if the players has enough mana, if they can cast an ultimate, etc. It can also be useful to create reusable and extendible skill templates.


Here's an example:
<details>
<summary>click to expand...</summary>

```lua
skills.register_skill_based_on("fbrawl:acid_spray", "fbrawl:confetti_spray", {
	name = "Confetti Spray",
	attachments = {
		particles = {{
            texture = {
                name = "fbrawl_confetti_particle.png",
                animation = "@@nil", -- our new particles are not animated
            }
        }}
	},
	data = {
		damage_multiplier = 3.5,
	},
	cooldown = 10,
	loop_params = {
		duration = 2.5
	}
})

--
-- MORE COMPLEX EXAMPLE
--
skills.register_layer("fbrawl:proxy_layer", {
	--[[ to add to the final skill:
	proxy = {
		name = "skill_name",
		args = {...}
	}
	--]]
	on_start = function (self, args)
		if not args or not args.called_by_proxy then
			self.pl_name:unlock_skill(self.proxy.name)
			self.pl_name:start_skill(self.proxy.name, self.proxy.args)
			return false -- block skill execution
		end
	end
})
skills.register_skill_based_on({"fbrawl:proxy_layer", "fbrawl:meteors_template"}, "fbrawl:cry_of_gaia", {
    name = "Cry of Gaia",
	description = "Unleash Gaia's fury: throws a meteor shower wherever you're looking at, damaging all enemies in that area.",

    -- PROXY LAYER PROPERTIES
    -- the proxy layer intercepts the meteors_template cast(),
    -- prevents it, and gives the player an item with which they can
    -- aim where they want to actually unleash the meteor storm.
    -- To bypass the proxy, the item will call the skill with a
    -- called_by_proxy argument.
	proxy = {
		name = "fbrawl:aoe_proxy", -- the skill that will act as a proxy
        args = {
            item = "fantasy_brawl:cry_of_gaia",
            broadcast = S("Click to unleash a meteor storm"),
            max_range = 200,
            particlespawner = area_particle_spawner,
            pointer_texture = "fbrawl_smash_item.png"
        }
	},

	-- METEORS TEMPLATE PROPERTIES TO OVERRIDE
	meteor_texture = "fbrawl_meteor_entity.png",
	meteor_size = 2,
	impact_range = 10,
	speed = 20,
	damage = 10,
	meteors_origin = {
		{x=6, y=-2, z=0},
		{x=-6, y=-2, z=0},
		{x=0, y=-2, z=-6},
	},
	waiting_time_before_throwing = 0.5,
	throw_sound = {name = "fbrawl_meteor_thrown", max_hear_distance = 46},
	crush_sound = {name = "fbrawl_meteor_hit", max_hear_distance = 46},
})
```
</details>


## Skill creation guidelines
Here are guidelines to help you design your skill:
- Undo any temporary changes applied in `on_start` within `on_stop`.
- Reset or initialize skill data in `on_start`, since `on_stop` won't be called if the server crashes while a skill is being cast.
- Avoid abusing skill data, as it gets serialized into mod storage.
- Modularize skill behavior: if you have ultimate skills that require 5 kills, move the kills check to a separate layer; if you have multiple ways of making a skill start, manage input in a separate layer (and so on...).
- Remember that you can declare your own functions in the skill definition: do it to keep the main callbacks clean and readable.
- Don't neglect graphics and audio - use `attachments`, `hud`, and `celestial_vault`!


## Assigning a skill
To unlock or remove a skill from a player just use `skills.unlock_skill/remove_skill(pl_name, skill_name)` function. You can also use the shorter form:
```lua
local pl_name = "giov4"
pl_name:unlock_skill("example_mod:counter")
pl_name:remove_skill("example_mod:counter")
```

## Using a skill
To use a player's skill you can use the short method or the long one: for the short one use `pl_name:cast_skill/start_skill/stop_skill("skill_name"[, ...])` (if the player can't use it, because they didn't unlock it, these will return false);

for the long one, you first have to get the player's skill table, using `skills.get_skill(pl_name, "skill_name")` or `pl_name:get_skill("skill_name")` (as before, if the player can't use it, it'll return false).

<a name="final_skill_table"></a>

The function will return the player's skill table, composed of the [definition properties](#registering) + the following new properties:
- `disable()`: to disable the skill: when disabled the `cast` and `start` functions won't work;
- `enable()`: to enable the skill;
- `data._enabled` (boolean): true if the skill is enabled;
- `internal_name` (string): the name used to refer to the skill in the code;
- `cooldown_timer` (number): the time left until the end of the cooldown;
- `is_active` (boolean): true if the skill is active;
- `pl_name` (string): the name of the player using this skill;
- `player` (ObjectRef): the player using this skill. Only use this while the skill is being casted!

Once you have it, just call `skill_table:cast([...])` or `skill_table:start([...])` to cast the skill. To stop it use `skill_table:stop()`.


## Utils function

### Skills
- `skills.register_on_unlock(function(skill_table), [prefix])`: this is called everytime a player unlocks a skill having the specified prefix; if the prefix isn't specified the function will be called everytime a player unlocks a skill;
- `skills.disable/enable_skill(pl_name, skill_name) / pl_name:enable/disable_skill(skill_name)`: short methods to enable or disable a skill;
- `skills.get_skill_def(skill_name)`: returns the skill's definition table;
- `skills.does_skill_exist(skill_name)`: to check if a skill exists (not case-sensitive). Always returns false for layers;
- `skills.get_registered_skills([prefix])`: returns the registered non-layers skills; if a prefix is specified, only the skills having that prefix will be listed (`{"prefix1:skill1" = {def}}`);
- `skills.get_registered_layers([prefix])`: same as the previous one, but returns a list of layers;
- `skills.get_unlocked_skills(pl_name, [prefix]) / pl_name:get_unlocked_skills(prefix)`: returns the unlocked skills; if a prefix is specified, only the skills having that prefix will be listed (`{"prefix1:skill1" = {def}}`);
- `skills.has_skill(pl_name, skill_name) / pl_name:has_skill(skill_name)`: returns true if the player has the skill;
- `skills.for_each_player_in_db(callback)`: calls `callback(pl_name, skills)` for each player in the DB. Always use this function if you need to operate on a lot of offline players, if you don't the Lua table storing the players data may become too big and generate lag spikes.

### Player
- `skills.add/sub/multiply/divide_physics(pl_name, property, value) / pl_name:add/sub/multiply/divide_physics(property, value)`: add/subtract/multiply/divide `value` from the `property` [physics property](https://github.com/minetest/minetest/blob/master/doc/lua_api.md?plain=1#L8084) (e.g. pl_name:add_physics("speed", 1));

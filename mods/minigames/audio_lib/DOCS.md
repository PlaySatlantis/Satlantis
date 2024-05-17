## 1. Audio_lib

Audio_lib is a library to easily manage the audio system of your game and mods.

### 1.1. Music types
The strong point of audio_lib is that it categorises sounds according to their type. This allows manipulation of category-specific audio settings (e.g. background music) without altering the rest (e.g. sound effects).

By default there are two music types: `"bgm"` (background music) and `"sfx"` (sound effects). However, it's possible to add custom types.

#### 1.1.1 BGM
Background music acts in a peculiar way: audio_lib won't allow the overlapping of two or more bgm, meaning it won't reproduce more tracks at the same time. Why? Well, because it'd be unusual to have more background tracks running together :D
Background music is always `loop = true`

#### 1.1.2 SFX
Sound effects are always ephemeral, meaning they can't be stopped. Use it for short sounds like a door closing. Sound effects are always `loop = false`

#### 1.1.3 Custom types
Custom types have no built-in rules and they can be used to add more layers to your sound management system. Useful types could be "ambient", "dialogues", "notifications". To register one, do:
```lua
audio_lib.register_type(mod, s_type, <readable_names>)
```

`mod` is the technical name of your mod, `s_type` is the technical name of the type (only lowercase letters, numbers and underscores allowed); `readable_names` is a table `{mod = name, type= name}` for human readable names. Multiple mods might register the same type: in this case they will co-exist, but only the first readable name will be used (first as in, according to the mod registration order).

### 1.2 Registering new sounds
Sounds must be registered before using them, as audio_lib stores their data in a local table. To do that:
* `audio_lib.register_sound(type, track_name, desc, def)`: registers a new sound of type `type` (see [1.1 Music types](###11-music-types)), using `track_name` audio file.
  * `desc` is a short description of the sound. It'll be very useful once accessibility options are integrated
  * `def` is a mix of:
    * Minetest [Sound parameter table](https://github.com/minetest/minetest/blob/master/doc/lua_api.md#sound-parameter-table). `pos`, `object`, `to_player` and `exclude_player` won't work. If it's a bgm, nor will `loop = false`. If it's an sfx, nor will `loop = true`
    * custom parameters, namely:
      * `ephemeral`: (boolean) whether the sound shouldn't be trackable, so it can't be altered during its lifetime. Default is `true`
      * `cant_overlap`: (boolean) whether playing the sound whilst it's already being played will stop the first instance or it'll overlap the two. It requires the sound not to be ephemeral. Default is `nil`. BEWARE: due to MT current limitations (see [here](https://github.com/minetest/minetest/issues/12375)), this will only work if the sound is called again within 1 second since the first instance
  * if the same sound is registered more than once, it'll just get overridden by the last function call featuring it

Some examples:
```lua
-- register a bgm
audio_lib.register_sound("bgm", "mymod_bgm1", "The adventure begins")

-- register an sfx and tweaks its parameters
audio_lib.register_sound("sfx", "mymod_sfx1", "Door closing", {gain = 1.2, pitch = 0.9})

-- register a sound for the custom type "ambient"
audio_lib.register_sound("ambient", "mymod_spookyambient", "Eerie sound")
```

When you want to use a sound in the audio_lib functions, simply use the `track_name` name you've used during the registration.

#### 1.2.1 Registering sound variants
audio_lib uses the Minetest native [sound groups system](https://github.com/minetest/minetest/blob/master/doc/lua_api.md#sound-group); simply register a sound as usual and then put as many audio files you need in the designated folder by following Minetest syntax

### 1.3 Utils
* `audio_lib.play_bgm(p_name, track_name, <override_params>)`: plays `track_name`, if registered, to `p_name`.
  * `override_params` is a parameters table that, if declared, will override the default Minetest parameters of `track_name` (e.g. if `track_name` is registered with `gain = 0.8`, declaring `gain = 0.5` won't be result in `gain = 0.4` (0.8 * 0.5), but in 0.5 (1.0 * 0.5))
  * if `track_name` is the track that's already being played, nothing will happen
* `audio_lib.change_bgm_volume(p_name, gain, <fade_duration>)`: change the volume of the bgm `p_name` is listening to, if any. `fade_duration` is the seconds needed to reach such volume (`0` by default)
* `audio_lib.continue_bgm(p_name)`: resumes the last bgm `p_name` previously heard, starting from where it had left (MT 5.8+)
* `audio_lib.stop_bgm(p_name, <fade_duration>)`: interrupts the bgm `p_name` was currently listening to, if any. Specify a number for `fade_duration` for a fade out effect
* `audio_lib.play_sound(track_name, <override_params>)`: plays sounds that are sfx or custom types. See `play_bgm(..)` for `override_params`.
  * Sfx are always ephemeral and can't be looped, no matter what's declared in the function
  * If ephemeral, it can't be stopped
  * if you're passing an `object` or a `pos` that don't exist, the sound will be played server-wide. For this reason it's good practice to check the existence of these values before actually calling the function
* `audio_lib.stop_sound(p_name, track_name)`: stop the custom sound `track_name` for `p_name`, if any. CURRENTLY NOT WORKING, waiting for https://github.com/minetest/minetest/issues/12375 as I refuse to implement and maintain a hacky workaround to handle durations. The same applies to a fade duration and a hypothetical `change_sound_volume(..)`
* `audio_lib.reload_music(p_name, old_settings)`: applies to `p_name` their new audio settings at runtime. `old_settings` is needed for calculation
* `audio_lib.is_sound_registered(track_name, <type>)`: returns whether the specified track name exists within audio_lib or not
* `audio_lib.open_settings(p_name)`: opens the audio settings formspec for `p_name`

### 1.4 Getters
* `audio_lib.get_player_bgm(p_name, <in_detail>)`: returns the name of the bgm file currently played for `p_name`.
  * If `in_detail` is `true`, it returns a table instead. The table contains in-depth information about the track. Namely:
    ```lua
    {
      -- name of the file
      name = "",
      -- description put in the registration
      description = "",
      -- sound handle
      handle = 7,
      -- default MT sound parameters
      params = {}
    }
    ```
* `audio_lib.get_player_sounds(s_type, p_name, <in_detail>)`: returns a table of names of the sound files of type `s_type` (`"sfx"` or custom types) currently played for `p_name`.
  * If more instances of the same sound are played, audio_lib will register and print them as `"name__1"`, `"name__2"` etc.
  * If `in_detail` is `true`, it returns a table of tables instead. Those contain in-depth information about each track. Namely:
    ```lua
    {
      -- name of the file
      name = "",
      -- description put in the registration
      description = "",
      -- default MT sound parameters
      params = {}
    }
    ```
  * Due to current engine limitations, there's no way to know when a track really ends, so every non-bgm sound is kept in memory for 1s. This is needed: https://github.com/minetest/minetest/issues/14022
  * Currently it's not possible to keep track of the same sound played more times in less than a second, so it'll only return the data of the last one
* `audio_lib.get_types()`: returns a table with all the registered custom types with the format `{"technical_name1", "technical_name2"}`. It returns an empty table if no custom types are found
* `audio_lib.get_type_name(s_type)`: returns the human readable name of custom type `s_type`
* `audio_lib.get_mods_of_type(s_type)`: returns a table containing the technical name of mods that have registered `s_type`. Format `{name = true}`
* `audio_lib.get_settings(p_name)`: returns a table containing `p_name` settings


## 2. About the author
I'm Zughy, a professional Italian pixel artist who fights for free software and digital ethics. If this library spared you a lot of time and you want to support me somehow, please consider donating on [Liberapay](https://liberapay.com/Zughy/)

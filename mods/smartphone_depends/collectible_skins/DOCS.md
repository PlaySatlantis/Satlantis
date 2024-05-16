# Collectible skins docs

> THIS IS AN ALPHA, EXPECT BREAKAGES

# Table of Contents
* [1 Skins](#1-skins)
* [2 API](#2-api)
    * [2.1 Skins handlers](#21-skins-handlers)
    * [2.2 Utils](#22-utils)
    * [2.3 Getters](#23-getters)
    * [2.4 Setters](#24-setters)
    * [2.5 Callbacks](#25-callbacks)
* [3 About the author(s)](#3-about-the-authors)

## 1 Skins
A skin is a table with the following fields:
```yaml
skinID:
    name:
    description:
    texture:
    collection: (optional, currently unused, default "Default")
    hint: (optional, default "(locked)")
    model: (optional, default none)
    tier: (optional, default 1)
    author: (optional, default "???")
```

Check the README to know how to add new skins

When a skin is correctly loaded, it also adds the extra field `id` for cross-referencing.

## 2 API
TODO: spiega

### 2.1 Skins handlers
* `collectible_skins.unlock_skin(p_name, skin_ID)`: unlocks skin with ID `skin_ID` for `p_name`
* `collectible_skins.remove_skin(p_name, skin_ID)`: removes skin with ID `skin_ID` from `p_name`

### 2.2 Utils
* `collectible_skins.is_skin_unlocked(p_name, skin_ID)`: returns whether `p_name` has the skin with ID `skin_ID`, as a boolean
* `collectible_skins.does_collection_exist(collection)`: returns whether a collection with the specified name exists, as boolean

### 2.3 Getters
* `collectible_skins.get_skins()`: returns a table with all the loaded skins, with their IDs as a key and the skin table as a value
* `collectible_skins.get_skins_by_collection(collection)`: returns a table containing all the skins belonging to the specified collection. Format `{id = skin}`
* `collectible_skins.get_skin(skin_ID)`: returns the skin corresponding to `skin_ID`, if any
* `collectible_skins.get_portrait(skin)`: returns the portrait associated to the skin, if any
* `collectible_skins.get_player_skins(p_name)`: returns a table containing all the skins that `p_name` has unlocked
* `collectible_skins.get_player_skin(p_name)`: returns the skin that `p_name` has currently equipped
* `collectible_skins.get_player_skin_ID(p_name)`: returns the ID of the skin that `p_name` has currently equipped

### 2.4 Setters
* `collectible_skins.set_skin(player, skin_ID, <is_permanent>)`: sets skin with ID `skin_ID` to `player`. `is_permanent` is an optional boolean indicating whether the skin should be remembered the next time they log in if they didn't change it before logging out (defaults to `false`)

### 2.5 Callbacks
* `collectible_skins.register_on_set_skin(function(p_name, skin_ID))`: additional behaviour when a player changes skin. This callback is not launched when people log in

## 3. About the author(s)
I'm Zughy (Marco), a professional Italian pixel artist who fights for FOSS and digital ethics. If this library spared you a lot of time and you want to support me somehow, please consider donating on [Liberapay](https://liberapay.com/Zughy/). Also, this project wouldn't have been possible if it hadn't been for some friends who helped me testing through: `Giov4`, `SonoMichele`, `_Zaizen_` and `Xx_Crazyminer_xX`

# API Usage

Hunger NG provides an API so other mods can have interoperability functionality. The API is represented by the global table `hunger_ng`. To reliably use the API, modders need to depend or opt-depend their mod to Hunger NG (`hunger_ng`).

## Adding hunger data

Modders can easily add satiation and health information to their custom food by running the function `add_hunger_data` from the global `hunger_ng` table after they registered their food.

    hunger_ng.add_hunger_data('modname:itemname', {
        satiates = 2.5,
        heals = 0,
        returns = 'mymod:myitem',
        timeout = 4
    })

Floats are allowed for `satiates` only. Health points and the timeout are always integers. Using food to satiate only is preferred. The item defined in `returns` will be returned when the food is eaten. If there is no space in the inventory the food can’t be eaten.

Values not to be set can be omitted in the table.

### On the timeout attribute …

Foods can have a timeout set. When set it prevents the food (and all other foods that have a similar or higher timeout or a timeout that’s within the current timeout time) to be eaten again while the timeout is active. The timeout also takes place when trying to eat the food after another food.

Foods without timeout can be eaten at any time if no default timeout is set. See the configuration readme for more details on setting a default timeout. To make sure the food can be eaten regardless of the default timeout set `timeout = 0` in the definition. Otherwise the default timeout is applied.

All foods reset the timeout period. Example: When eating food with timeout `10` right after eating something (food item and set timeout for that item do not matter) you need to wait 10 seconds. When eating an item with timeout `0` after 9 seconds it works but now you need to wait 10 more seconds to eat the other item with timeout `10`.

## Changing hunger

It is possible for modders to change hunger in their mods without having to care about the correct attributes. In the global table there is a function for that.

    hunger_ng.alter_hunger('Foobar', -5, 'optional reason')

This removes 5 hunger points from Foobar’s hunger value with the reason “optional reason”. Since the reason is optional it can be omitted. If given it should be as short as possible. If it is longer than 3 words reconsider it.

The function can be used in a globalstep that loops over all players, too.

```Lua
local timer = 0
minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer >= 1 then
        timer = 0
        for _,player in ipairs(minetest.get_connected_players()) do
            if player ~= nil then
                hunger_ng.alter_hunger(player:get_player_name(), 1, 'because I can')
            end
        end
    end
end)
```

This globalstep iterates over all players and gives them 1 hunger point every second with the reason “because I can”. The reason is shown in the log files if Hunger NG’s debug mode is enabled (you should not do that, it spams your logs with A LOT of lines).

Be careful with globalsteps because they can cause server lag.

### Enable/Disable hunger

An API function for enabling or disabling hunger on a per-player basis is available. The function can be used by other mods to disable and re-enable the hunger functionality.

    hunger_ng.configure_hunger('Foobar', 'disable')

The example disables all hunger functionality for the player “Foobar”. When passing `enable` to the function the hunger gets enabled.

While disabled the normal eating functionality is restored (eating directly heals the player) and the default hunger bar is removed.

#### Automatic server-wide disabling

On server start it is checked if damage is enabled. If this is the case then the mod loading is stopped right at the beginning. No hunger functionality is enabled and the mod is not loaded.

If there are no food items registered using `hunger_ng.add_hunger_data()` then the mod is loaded but none of the hunger-related functions are running and the hunger bar is not shown. Mods registering their food without using the API function can change the “registered food items” amount manually.

```Lua
-- Scheme
hunger_ng.food_itmes = {
    satiating = 0,
    starving = 0,
    healing = 0,
    injuring = 0,
}

-- Manually add one satiating food item to the check
hunger_ng.food_items.satiating = hunger_ng.food_items.satiating + 1
```

This is of course not recommended. Always use `hunger_ng.add_hunger_data()` in order to register hunger information to edible food. This automatically handles all the necessary checks.

## Getting hunger information

If modders want to get a player’s hunger information they can use `hunger_ng.get_hunger_information()` This returns a table with all relevant hunger-related information for the given player name.

```Lua
local info = hunger_ng.get_hunger_information('Foobar')
```

The information of the returned table can be used for further processing. Be aware that the value should not be stored for too long because the actual value will change over time and actions basing on the hunger value might not be exact anymore.

```Lua
{
    player_name = 'Foobar',
    hunger = {
        floored = 18,
        ceiled = 19
        exact = 18.928,
        disabled = false,
        enabled = true
    },
    maximum = {
        hunger = 20,
        health = 20,
        breath = 11
    },
    effects = {
        starving = { enabled = true, status = false },
        healing = { enabled = true, status = true },
        current_breath = 11
    },
    timestamps = {
        last_eaten = 1549670580,
        request = 1549671198
    }
}
```

The `hunger` sub-table contains five values. `floored` is the next lower full number while `ceiled` is the next higher full number (this value is used to create the hunger bar from). The `exact` value represents the hunger value at the moment when the request was made and can be a floating point number.

The `disabled` value indicates if hunger is generally disabled for the player either because the player has no interact permission or the player has the corresponding meta information set. This can be used by other mods to control hunger management as a whole.

The `enabled` value indicates if the hunger effect (i.e. losing hunger points when moving, when placing nodes, etc.) is enabled. This can be used by mods to control the effects that causing the loss of hunger points without disabling hunger as a whole.

The `maximum` sub-table is a convenient way to get the maximum values of the settings for this user.

In `effects` the current player effects are given. The `starving` and `healing` tables indicate if the player is below the starving limit or above the healing limit (the respective `status` values are `true` then) and if the effect is enabled (`enabled` is `true` then). If the status of both values is `false` then the user is within the frame between those two limits. `current_breath` gives the current breath of the player.

The sub-table `timestamps` contains timestamps according to the server time. `last_eaten` is the value of when the player ate something for the last time or is `0` if the player never ate anything before. `request` is the value of when the request was made. It can be used to determine the age of the information.

If the given player name is not a name of a currently available player the returned table contains two entries.

```Lua
{
    invalid = true,
    player_name = 'Foobar'
}
```

The `player_name` is the name of the player that can’t be found and `invalid` can be used as check if the request was successful.

```Lua
local info = hunger_ng.get_hunger_information('Foobar')
if info.invalid then
    print(info.player_name..' can’t be found.')
else
    print('Hunger of '..info.player_name..' is at '..info.hunger.exact..'.')
end
```

This example prints either `Foobar can’t be found.` or `Hunger of Foobar is at 18.928.` depending on if the user is available or not.

## Mod compatibility

The hunger bar is in the same position as the breath bar (the bubbles that appear when a player is awash) and disappears if the breath bar becomes visible. Any mod changing the position of the breath bar needs to change the position of the hunger bar as well.

Mods that alter or replace food with own versions ignoring custom item attributes will render them unusable for *Hunger NG* resulting in not being processed by *Hunger NG* but handled regularly.

Mods using the `/hunger` or `/myhunger` chat commands will either break or be broken when used in combination with *Hunger NG*.

Mods deleting or overwriting the global table `hunger_ng` break any mods that use the functions that are stored in the table.

### Change hunger bar image

By default a simple fallback bread image is used by *Hunger NG*. This image can easily be changed by setting `hunger_ng.hunger_bar_image` to a valid texture file name. This can be done from other mods as well as from within interoperability files.

```Lua
hunger_ng.hunger_bar_image = 'mymod_texturename.png'
```

The change does not need a restart and is applied automatically for all players as soon as the value is changed.

### Change hunger effects

Mods can control the effects that the hunger value has on a polayer as well as the change of the hunger value when actions are performed that cost hunger points.

```Lua
hunger_ng.set_effect('Playername', 'effect', 'setting')
```

The `'setting'` can be either `'enabled'` or `'disabled'`. The follwoing values for `'effect'` are valid:

* `heal` - If disabled the player won’t heal even if all conditions for healing are met.
* `hunger` - If disabled actions that normally cost hunger points do not cost hunger points, basal metabolism is also disabled.
* `starve` - If disabled the player won’t starve even if all conditions for starving are met.

The changes to the hunger effects are not persistent by design. This circumvents issues when effects were changed by a mod that then is unloaded or does not alter the effects after disbaling them.

Mods that need the effects to be persistent between logins need to track the changes on their own and need to disable the effects again **after** the player joined. Hunger NG resets the effect values in a `minetest.register_on_joinplayer` definition. Mods doing the same might cause race conditions.

### Interoperability

Hunger NG provides an interoperability system. This system allows adding support for mods (for example adding hunger information to the items of that mod).

If you want to change this for your own server (you need to track changes on mod updates by yourself, though) simply add a file named after the mod you want to support in the `interoperability` directory.

The interoperability system is seen as a temporary solution or a fallback solution. The preferred way is to contact the original mod’s author and ask them to add Hunger NG support and point them to this API documentation. If they’re not interested in supporting Hunger NG feel free to file an issue or create a merge request.

#### Additional interoperability functions

The API table provides additional function for interoperability reasons in the sub table `hunger_ng.interoperability`.

`attributes` provides the attribute names for the various meta data that is stored in the player objects.

`get_data` and `set_data` allow getting and setting a player’s meta data via the Hunger NG system. The functions both take the player name, the field to get/set and an optional `true` for getting the result as string instead of a number. It is advised not to use this functions in interoperability files to set or get hunger data. This is what `hunger_ng.alter_hunger` is for.

`settings` is a table containing the Hunger NG configuration. For example: You can check via `hunger_ng.interoperability.settings.hunger_bar.use` if the hunger bar is to be used. There are also timer information and hunger information (maximum hunger, timeout, etc.) available. Changing values here does not change the configuration. The table is solely informational.

`translator` is a preconfigured Minetest translation functionality instance. It can be used like the normal translation function but automatically uses the correct textdomain. Strings that can be translated are seen in the mod’s `locale` directory.

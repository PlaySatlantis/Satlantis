# Configuration

The mod allows a lot of configuration. All of the following attributes are editable on global level either via the advanced configuration within the client or by manually adding the options to `minetest.conf`.

In addition to the global settings in `minetest.conf` the values can also be stored in a world-specific configuration file located at `./worlds/worldname/_hunger_ng/hunger_ng_settings.conf`. Settings in this file overwrite the global settings and/or default values.

## Healing and starving

By default players heal to the maximum of 20 health points (10 hearts) when their hunger level is above 16 (8 breads). When the hunger is lower than 1 (no breads) players start starving. Their health will be reduced to 1 (0.5 hearts). If set players can starve to death. This is not active by default.

    hunger_ng_heal_above
    hunger_ng_heal_amount
    hunger_ng_starve_below
    hunger_ng_starve_amount
    hunger_ng_starve_die

Set this values somewhere between 1 and 20 (floats are allowed for hunger values only, health values have to be integers due to technical limitations). Make sure not to use paradox values. This would result in unforeseen consequences.

## Hunger persistence and values

By default the hunger value is persistent. That means if a player leaves the game and comes back later the hunger value will not be reset but will be the same as when the player left.

The hunger value is configured to have a maximum of 20 (10 breads in default configuration, the image used for the bar can be changed, too). If a new player joins (or players that have to respawn because they died) they start with this value. Both of them are configurable.

    hunger_ng_hunger_persistent
    hunger_ng_hunger_maximum
    hunger_ng_hunger_start_with
    hunger_ng_hunger_bar_image
    hunger_ng_hunger_timeout

If the value to start with is larger than the maximum value the maximum value is used.

The timeout is added to all foods that do not have a timeout set and defines how long after eating the last food the next food can be eaten. See section “Adding hunger data” for information about the per-food configuration.

## Debugging and mod configuration

Those values should be left untouched if not instructed otherwise or if you know what you are doing.

    hunger_ng_debug_mode
    hunger_ng_use_hunger_bar

Listen to the mod author or check `settingtypes.txt` for any further details.

## Hunger manipulation

### Costs for activities

This mod adds a basal metabolism. Players lose hunger points regardless of what they do. Digging and placing nodes also costs some hunger points. When moving around very little hunger points are subtracted regularly, too.

    hunger_ng_cost_base
    hunger_ng_cost_dig
    hunger_ng_cost_place
    hunger_ng_cost_movement

When setting any of the values to `0` the functionality will be disabled.

### Timers

There are also timers that can be set to allow even more detailed configuration of hunger manipulation

    hunger_ng_timer_heal
    hunger_ng_timer_starve
    hunger_ng_timer_basal_metabolism
    hunger_ng_timer_movement

All timers take floats as seconds value. The minimum value is 0.1 for all of the values because 0.1 seconds roughly is the time one server step takes.

### Conclusion of default values

After some balancing tests the following rules apply.

* By default players can walk for a whole accumulated ingame day before their hunger is at 0. Direction (or multiple directions at the same time) does not matter.
* Placing nodes costs 1 hunger point for 100 nodes and digging nodes costs 1 hunger point for 200 nodes.
* The basal metabolism takes roughly 10 ingame days to use up the maximum hunger value. (Which is actually pretty common in reality to survive 10 days without eating something when not doing anything else except drinking enough water.)
* Starvation (below 1 hunger point) results in 1 health point removed every 20 seconds ending up with 1 health point (starving to death is disabled by default) and when healing (above 16 hunger points, or 8 breads) 1 health point is restored every 5 seconds

One bread consists of 2 hunger points. That means that removing 1 hunger point results in 0.5 breads removed.

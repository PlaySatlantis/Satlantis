# Management

Currently there are two chat commands that allow changing one’s hunger value manually or viewing the own hunger value.

## Management chat command

A custom chat command `/hunger` is added. The chat command can be used by anyone having the `manage_hunger` privilege. It provides some hunger-related features for players that are currently online.

    /hunger set Foobar 10
    /hunger set 7.5
    /hunger change -10
    /hunger change Foobar 15
    /hunger get
    /hunger get Foobar

The first example sets the hunger value of player “Foobar” to 10 (5 breads). The second example sets the own hunger value to 7.5 (ceiled 8, so this looks like 4 breads). The third example reduces the own hunger value by 10, the fourth example raises Foobar’s hunger value by 15.

The two last examples either return a list of all currently online player’s hunger values or the hunger value of the given player.

You can also toggle the hunger status for yourself or for a given player.

    /hunger toggle
    /hunger toggle Foobar

The first example toggles the own hunger status. The second example toggles the hunger status of the player “Foobar”.

## Personal information chat command

Players that have the `interact` permission can query their own hunger value as numeric information using the `/myhunger` chat command

    /myhunger

This commands displays the player name and the hunger value to the player who invoked the command.

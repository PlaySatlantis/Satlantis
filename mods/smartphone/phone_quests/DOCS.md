# Server Admin
You can plan your month quests by editing the `QUESTS.lua` file in the `<YOUR_WORLD_FOLDER>/phone_quests/` folder. From there you'll be able to list which quests must be shown in the app, and when.

# <YOUR_WORLD_FOLDER>/phone_quests/QUESTS.lua
```
phone_quests.start_day =  {year = 2024, month = 6,	day = 8, hour = 0, min = 0, sec = 0}
```

Set a custom epoch from which the days and weeks are calculated. The first day will last 24 hours from this point in system time, and the first week will last 7 days from this point in system time. The daily and weekly quests cycle after the defined number of weeks.

```
phone_quests.daily_quests = {
    -- day 1 quests
    {"quest_technical_name_day_1_quest_1",
     "quest_technical_name_day_1_quest_2",},

    -- day 2 quests
    {"quest_technical_name_day_2_quest_1",
     "quest_technical_name_day_2_quest_2",},

    ...
}
```
```
phone_quests.weekly_quests = {
    -- week 1 quests
    {"quest_technical_name_week_1_quest_1",
     "quest_technical_name_week_1_quest_2",},

    -- week 2 quests
    {"quest_technical_name_week_2_quest_1",
     "quest_technical_name_week_2_quest_2",},

    ...
}
```

Quests are defined as ordered lists of days or weeks. Each entry for a day or week is a list of quest techical names. The quests shown in the app are chosen by this list for each day and week.
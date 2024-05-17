
--- Cleaner Settings
--
--  @topic settings


--- Enables unsafe methods & chat commands.
--
--  - `cleaner.remove_ore`
--  - `/remove_ores`
--
--  @setting cleaner.unsafe
--  @settype bool
--  @default false
cleaner.unsafe = core.settings:get_bool("cleaner.unsafe", false)

-- HUD bars
--
-- Author  Wuzzy
-- Forums  https://forum.minetest.net/viewtopic.php?t=11153
-- VCS     https://repo.or.cz/w/minetest_hudbars.git


-- Localize and Prepare
local a = hunger_ng.interoperability.attributes
local s = hunger_ng.interoperability.settings
local S = hunger_ng.interoperability.translator
local get_data = hunger_ng.interoperability.get_data
local set_data = hunger_ng.interoperability.set_data
local bar_id = 'hungernghudbar'
local hudbar_image_filters = '^[noalpha^[colorize:#c17d11ff^[resize:2x16'
local hudbar_image = s.hunger_bar.image..hudbar_image_filters


-- register the hud bar
hb.register_hudbar(
    bar_id,
    '0xFFFFFF',
    S('Satiation'),
    {
        bar = hudbar_image,
        icon = s.hunger_bar.image
    },
    s.hunger.maximum,
    s.hunger.maximum,
    false
)


-- Remove normal hunger bar and add hudbar version of it
minetest.register_on_joinplayer(function(player)
    local player_name = player:get_player_name()
    local hud_id = tonumber(get_data(player_name, a.hunger_bar_id))
    local current_hunger = get_data(player_name, a.hunger_value)
    local hunger_ceiled = math.ceil(current_hunger)

    if s.hunger_bar.use then
        -- Since we don’t have register_after_joinplayer() we need to delay
        -- the removal of the default hunger bar because without delay this
        -- results in a race condition with Hunger NG’s register_on_joinplayer
        -- callback that defines and sets the default hunger bar.
        --
        -- If for some reason the hud bar is not hidden try raising the delay
        -- before the bar is hidden by adding hunger_ng_i14y_hudbars_delay to
        -- your configuration and setting it to a value of your liking (the
        -- value is giving in seconds and decimals are allowed).
        local parameter_name = 'hunger_ng_i14y_hudbars_delay'
        local delay = minetest.settings:get(parameter_name) or 0.5

        if minetest.settings:get('hunger_ng_debug_mode') and delay ~= 0.5 then
            local message = 'Using delay of +d to hide the hunger bar for +p.'
            minetest.log('action', '[hungerng] '..message:gsub('%+%a+', {
                ['+d'] = delay..'s',
                ['+p'] = player_name
            }))
        end

        minetest.after(delay, function () player:hud_remove(hud_id) end)
    end

    hb.init_hudbar(player, bar_id, hunger_ceiled, s.hunger.maximum, false)
end)


-- Globalstep for updating the hundbar version of the hunger bar without
-- any additional code outside the interoperability system.
local hudbars_timer = 0
minetest.register_globalstep(function(dtime)
    hudbars_timer = hudbars_timer + dtime
    if hudbars_timer >= 1 then
        hudbars_timer = 0
        for _,player in ipairs(minetest.get_connected_players()) do
            if player ~= nil then
                local playername = player:get_player_name()
                local hunger = get_data(playername, a.hunger_value)
                local ceiled = math.ceil(hunger)
                hb.change_hudbar(player, bar_id, ceiled, s.hunger.maximum)
            end
        end
    end
end)

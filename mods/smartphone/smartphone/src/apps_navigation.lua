-- This file implements tracing and history for smartphone apps.
-- It traces when apps are opened and maintains a stack of opened apps per player.
-- This allows going back to the previous app when the back button is pressed.

local show_formspec = minetest.show_formspec
local function trace_formspec(pl_name, formname) end
local function go_to_prev_page(pl_name) end

local opened_app_history = {} -- "pl_name" = stack of app names



minetest.show_formspec = function(pl_name, formname, formspec)
	if formname == "smartphone:smartphone" then
		opened_app_history[pl_name] = stack.new() -- reset stack when opening home page
	elseif smartphone.is_app(formname) then
		trace_formspec(pl_name, formname)
	end

	return show_formspec(pl_name, formname, formspec)
end


minetest.register_on_player_receive_fields(function(player, formname, fields)
	local pl_name = player:get_player_name()

	if not smartphone.is_app(formname) then return false end

	if fields.smtphone_back then
		go_to_prev_page(pl_name)
		return true
	elseif fields.smtphone_home then
		smartphone.open_smartphone(player)
		return true
	end
end)



function trace_formspec(pl_name, formname)
	if opened_app_history[pl_name]:peek() ~= formname then
		opened_app_history[pl_name]:push(formname)
	end
end


function go_to_prev_page(pl_name)
	opened_app_history[pl_name]:pop() -- remove currently opened app from stack
	local prev_app_name = opened_app_history[pl_name]:pop() or "no app"
	local player = minetest.get_player_by_name(pl_name)

	if smartphone.is_app(prev_app_name) then
		smartphone.open_app(player, prev_app_name)
	else
		smartphone.open_smartphone(player)
	end
end
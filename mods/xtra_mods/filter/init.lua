
--[[

	Copyright 2017-8 Auke Kok <sofar@foo-projects.org>
	Copyright 2018 rubenwardy <rw@rubenwardy.com>

	Permission is hereby granted, free of charge, to any person obtaining
	a copy of this software and associated documentation files (the
	"Software"), to deal in the Software without restriction, including
	without limitation the rights to use, copy, modify, merge, publish,
	distribute, sublicense, and/or sell copies of the Software, and to
	permit persons to whom the Software is furnished to do so, subject
	to the following conditions:

	The above copyright notice and this permission notice shall be included
	in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
	KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
	WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
	LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
	OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
	WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

]]--

filter = { registered_on_violations = {} }
local words = {}
local muted = {}
local violations = {}
local s = minetest.get_mod_storage()

function filter.init()
	local sw = s:get_string("words")
	if sw and sw ~= "" then
		words = minetest.parse_json(sw)
	end

	if #words == 0 then
		filter.import_file(minetest.get_modpath("filter") .. "/words.txt")
	end
end

function filter.import_file(filepath)
	local file = io.open(filepath, "r")
	if file then
		for line in file:lines() do
			line = line:trim()
			if line ~= "" then
				words[#words + 1] = line:trim()
			end
		end
		return true
	else
		return false
	end
end

function filter.register_on_violation(func)
	table.insert(filter.registered_on_violations, func)
end

function filter.check_message(name, message)
	for _, w in ipairs(words) do
		if string.match(message:lower(), w) then
			return false
		end
	end

	return true
end

function filter.mute(name, duration)
	do
		local privs = minetest.get_player_privs(name)
		privs.shout = nil
		minetest.set_player_privs(name, privs)
	end

	minetest.chat_send_player(name, "Watch your language! You have been temporarily muted")

	muted[name] = true

	minetest.after(duration * 60, function()
		local privs = minetest.get_player_privs(name)
		if privs.shout == true then
			return
		end

		muted[name] = nil
		minetest.chat_send_player(name, "Chat privilege reinstated. Please do not abuse chat.")

		privs.shout = true
		minetest.set_player_privs(name, privs)
	end)
end

function filter.show_warning_formspec(name)
	local formspec = "size[7,3]bgcolor[#080808BB;true]" .. [[
		image[0,0;2,2;filter_warning.png]
		label[2.3,0.5;Please watch your language!]
	]]

	if minetest.global_exists("rules") and rules.show then
		formspec = formspec .. [[
				button[0.5,2.1;3,1;rules;Show Rules]
				button_exit[3.5,2.1;3,1;close;Okay]
			]]
	else
		formspec = formspec .. [[
				button_exit[2,2.1;3,1;close;Okay]
			]]
	end
	minetest.show_formspec(name, "filter:warning", formspec)
end

function filter.on_violation(name, message)
	violations[name] = (violations[name] or 0) + 1

	local resolution

	for _, cb in pairs(filter.registered_on_violations) do
		if cb(name, message, violations) then
			resolution = "custom"
		end
	end

	if not resolution then
		if violations[name] == 1 and minetest.get_player_by_name(name) then
			resolution = "warned"
			filter.show_warning_formspec(name)
		elseif violations[name] <= 3 then
			resolution = "muted"
			filter.mute(name, 1)
		else
			resolution = "kicked"
			minetest.kick_player(name, "Please mind your language!")
		end
	end

	local logmsg = "VIOLATION (" .. resolution .. "): <" .. name .. "> "..  message
	minetest.log("action", logmsg)

	local email_to = minetest.settings:get("filter.email_to")
	if email_to and minetest.global_exists("email") then
		email.send_mail(name, email_to, logmsg)
	end
end

table.insert(minetest.registered_on_chat_messages, 1, function(name, message)
	if message:sub(1, 1) == "/" then
		return
	end

	local privs = minetest.get_player_privs(name)
	if not privs.shout and muted[name] then
		minetest.chat_send_player(name, "You are temporarily muted.")
		return true
	end

	if not filter.check_message(name, message) then
		filter.on_violation(name, message)
		return true
	end
end)


local function make_checker(old_func)
	return function(name, param)
		if not filter.check_message(name, param) then
			filter.on_violation(name, param)
			return false
		end

		return old_func(name, param)
	end
end

for name, def in pairs(minetest.registered_chatcommands) do
	if def.privs and def.privs.shout then
		def.func = make_checker(def.func)
	end
end

local old_register_chatcommand = minetest.register_chatcommand
function minetest.register_chatcommand(name, def)
	if def.privs and def.privs.shout then
		def.func = make_checker(def.func)
	end
	return old_register_chatcommand(name, def)
end


local function step()
	for name, v in pairs(violations) do
		violations[name] = math.floor(v * 0.5)
		if violations[name] < 1 then
			violations[name] = nil
		end
	end
	minetest.after(10*60, step)
end
minetest.after(10*60, step)

minetest.register_chatcommand("filter", {
	params = "filter server",
	description = "manage swear word filter",
	privs = {server = true},
	func = function(name, param)
		local cmd, val = param:match("(%w+) (.+)")
		if param == "list" then
			return true, #words .. " words: " .. table.concat(words, ", ")
		elseif cmd == "add" then
			table.insert(words, val)
			s:set_string("words", minetest.write_json(words))
			return true, "Added \"" .. val .. "\"."
		elseif cmd == "remove" then
			for i, w in ipairs(words) do
				if w == val then
					table.remove(words, i)
					s:set_string("words", minetest.write_json(words))
					return true, "Removed \"" .. val .. "\"."
				end
			end
			return true, "\"" .. val .. "\" not found in list."
		else
			return true, "I know " .. #words .. " words.\nUsage: /filter <add|remove|list> [<word>]"
		end
	end,
})

if minetest.global_exists("rules") and rules.show then
	minetest.register_on_player_receive_fields(function(player, formname, fields)
		if formname == "filter:warning" and fields.rules then
			rules.show(player)
		end
	end)
end

minetest.register_on_shutdown(function()
	for name, _ in pairs(muted) do
		local privs = minetest.get_player_privs(name)
		privs.shout = true
		minetest.set_player_privs(name, privs)
	end
end)

filter.init()

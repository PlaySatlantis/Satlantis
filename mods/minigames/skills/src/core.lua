-- { "mod:skill1" = {...}, ...}
skills.registered_skills = {}
skills.blocking_skills = {}  -- {"pl_name" = "mod:active_skill"}, to disable skills non-permanently

local S = minetest.get_translator("skills")
local NS = function (string) return string end

local get_player_by_name = minetest.get_player_by_name

local function initialize_def(internal_name, def) end
local function initialize_callbacks(def) end
local function init_empty_subtable(t, st) end
local function update_pl_skill_data(pl_name, internal_name) end
local function join_defs(s1, s2) end

local string_metatable = getmetatable("")

local on_unlocks = {
	globals = {},
	specific = {}  -- {"skill_prefix" = {callback1, callback2...}}
}



--
--
-- CALLBACKS
--
--

minetest.register_on_joinplayer(function(player)
	skills.cast_passive_skills(player:get_player_name())
end)



minetest.register_on_leaveplayer(function(player, timed_out)
	local pl_name = player:get_player_name()
	local pl_skills = pl_name:get_unlocked_skills()

	for skill_name, def in pairs(pl_skills) do
		def:stop()
	end
end)





--
--
-- PUBLIC API
--
--

function skills.register_skill(internal_name, def)
	def = initialize_def(internal_name, def)
   skills.registered_skills[internal_name:lower()] = def
end



function skills.register_layer(internal_name, def)
	def.is_layer = true
	skills.register_skill(internal_name, def)
end



function skills.register_skill_based_on(original, variant_name, def)
	def.internal_name = variant_name:lower()
	def.is_layer = false -- to avoid inheriting this from lower layers

	if type(original) == "string" then
		local original_def = table.copy(skills.get_skill_def(original))
		def = join_defs(original_def, initialize_callbacks(def))
	elseif type(original) == "table" then
		local previous = nil

		-- joining the base skills definition
		for _, name in ipairs(original) do
			local current = table.copy(skills.get_skill_def(name))

			if previous then
				previous = join_defs(previous, current)
			else
				previous = current
			end
		end

		def = join_defs(previous, initialize_callbacks(def))
	end

	skills.registered_skills[def.internal_name] = def
end



function skills.register_on_unlock(func, prefix)
	if prefix then
		init_empty_subtable(on_unlocks.specific, prefix)
		table.insert(on_unlocks.specific[prefix], func)
	else
		table.insert(on_unlocks.globals, func)
	end
end



function skills.unlock_skill(pl_name, skill_name)
	skills.import_player_from_db(pl_name)

	skill_name = skill_name:lower()

	if
		not skills.does_skill_exist(skill_name)
		or pl_name:has_skill(skill_name)
	then
		return false
	end

	init_empty_subtable(skills.player_skills, pl_name)
	init_empty_subtable(skills.player_skills[pl_name], skill_name)
	init_empty_subtable(skills.player_skills[pl_name][skill_name], "data")

	local pl_skill = skills.construct_player_skill(pl_name, skill_name)

	-- on_unlock callbacks
	local skill_prefix = skill_name:split(":")[1]
	if on_unlocks.specific[skill_prefix] then
		for _, specific_callback in pairs(on_unlocks.specific[skill_prefix]) do
			specific_callback(pl_skill)
		end
	end
	for _, global_callback in pairs(on_unlocks.globals) do global_callback(pl_skill) end

	if pl_skill.passive then pl_skill:start() end

	return true
end
string_metatable.__index["unlock_skill"] = skills.unlock_skill



function skills.remove_skill(pl_name, skill_name)
	skill_name = skill_name:lower()
	local skill = pl_name:get_skill(skill_name)

	if not skill then return false end

	skill:disable()
	skills.player_skills[pl_name][skill_name] = nil

	return true
end
string_metatable.__index["remove_skill"] = skills.remove_skill



function skills.get_skill(pl_name, skill_name)
	skills.import_player_from_db(pl_name)
   local pl_skills = skills.player_skills[pl_name]

	if not skills.does_skill_exist(skill_name) or pl_skills[skill_name:lower()] == nil then
   	return false
	end

   return pl_skills[skill_name:lower()]
end
string_metatable.__index["get_skill"] = skills.get_skill



function skills.has_skill(pl_name, skill_name)
   return pl_name:get_skill(skill_name) ~= false
end
string_metatable.__index["has_skill"] = skills.has_skill



function skills.cast_skill(pl_name, skill_name, ...)
   local skill = pl_name:get_skill(skill_name)

	if skill then
		return skill:cast(...)
	else
		return false
	end

end
string_metatable.__index["cast_skill"] = skills.cast_skill



function skills.start_skill(pl_name, skill_name, ...)
   local skill = pl_name:get_skill(skill_name)

	if skill then
		return skill:start(...)
	else
		return false
	end

end
string_metatable.__index["start_skill"] = skills.start_skill



function skills.stop_skill(pl_name, skill_name)
   local skill = pl_name:get_skill(skill_name)

	if skill then
		return skill:stop()
	else
		return false
	end

end
string_metatable.__index["stop_skill"] = skills.stop_skill



function skills.enable_skill(pl_name, skill_name)
	local skill = pl_name:get_skill(skill_name)

	if not skill then return false end

	return skill:enable()
end
string_metatable.__index["enable_skill"] = skills.enable_skill



function skills.disable_skill(pl_name, skill_name)
   local skill = pl_name:get_skill(skill_name)

	if not skill then return false end

	return skill:disable()
end
string_metatable.__index["disable_skill"] = skills.disable_skill



function skills.get_skill_def(skill_name)
   if not skills.registered_skills[skill_name:lower()] then
   	return false
   end

   return skills.registered_skills[skill_name:lower()]
end



function skills.does_skill_exist(skill_name)
   return
		skill_name
		and skills.registered_skills[skill_name:lower()]
		and not skills.registered_skills[skill_name:lower()].is_layer
end



function skills.get_registered_skills(prefix)
	local registered_skills = {}

	for name, def in pairs(skills.registered_skills) do
		if def.is_layer then goto continue end

		if prefix and string.split(name, ":")[1]:match(prefix) then
			registered_skills[name] = def
		elseif prefix == nil then
			registered_skills[name] = def
		end

		::continue::
	end

   return registered_skills
end



function skills.get_registered_layers(prefix)
	local registered_layers = {}

	for name, def in pairs(skills.registered_skills) do
		if not def.is_layer then goto continue end

		if prefix and string.split(name, ":")[1]:match(prefix) then
			registered_layers[name] = def
		elseif prefix == nil then
			registered_layers[name] = def
		end

		::continue::
	end

   return registered_layers
end



function skills.get_unlocked_skills(pl_name, prefix)
	local skills = skills.get_registered_skills(prefix)
	local unlocked_skills = {}

	for name, def in pairs(skills) do
		if pl_name:has_skill(name) then
			unlocked_skills[name] = def
		end
	end

	return unlocked_skills
end
string_metatable.__index["get_unlocked_skills"] = skills.get_unlocked_skills



function skills.basic_checks_in_order_to_cast(skill)
	local active_blocking_skill = skills.blocking_skills[skill.pl_name]
	local is_blocked_by_another_skill = (
		active_blocking_skill
		and active_blocking_skill ~= skill.internal_name
		and skill.can_be_blocked_by_other_skills
	)

	if is_blocked_by_another_skill then return false end

	if not skill.data._enabled then
		if skills.settings.chat_warnings.disabled ~= false then
			skills.error(skill.pl_name, S("You can't use the @1 skill now", skill.name))
		end

		return false
	end

	return get_player_by_name(skill.pl_name)
end



function skills.construct_player_skill(pl_name, skill_name)
	local def = skills.get_skill_def(skill_name)
	local skill = pl_name:get_skill(skill_name)
	local pl_skills = skills.player_skills[pl_name]

	if skill then
		skill = table.copy(def)

		skill.pl_name = pl_name
		skill.player = get_player_by_name(pl_name)
		skill.data = update_pl_skill_data(pl_name, skill.internal_name)

		pl_skills[skill_name] = skill
	else
		return false
	end

	return pl_skills[skill_name]
end





--
--
-- PRIVATE FUNCTIONS
--
--

function initialize_def(internal_name, def) -- cooldown, passive
	local empty_func = function() end
	def.internal_name = internal_name
	def.description = def.description or NS("No description.")
	def.sounds = def.sounds or {}
	def.attachments = def.attachments or {}
	def.cooldown_timer = 0
	def.is_active = false
	def.data = def.data or {}
	def.on_start = def.on_start or empty_func
	def.on_stop = def.on_stop or empty_func
	def.data = def.data or {}
	def.data._enabled = true
	if def.can_be_blocked_by_other_skills == nil then def.can_be_blocked_by_other_skills = true end

	if def.attachments.entities then
		minetest.register_on_mods_loaded(function()
			for _, entity in ipairs(def.attachments.entities) do
				skills.register_expiring_entity(entity.name)
			end
		end)
	end

	local sounds = def.sounds
	if sounds.bgm then
		if not skills.is_sound_pool(sounds.bgm) then
			sounds.bgm.loop = true
		else
			for _, sound in ipairs(sounds.bgm) do
				sound.loop = true
			end
		end
	end

	initialize_callbacks(def)

   return def
end



function initialize_callbacks(def)
	-- copying cast to preserve the unwrapped version
	def.logic = def.cast or function ()	end

	def.cast = function(self, ...)
		return skills.cast(self, ...)
	end

	def.start = function(self, ...)
		return skills.start(self, def, ...)
   end

	def.stop = function(self, cancelled)
		return skills.stop(self, cancelled)
   end

	def.disable = function(self)
		if not self.data._enabled then return false end

		self:stop()
		self.data._enabled = false

		return true
	end

	def.enable = function(self)
		if self.data._enabled then return false end

		self.data._enabled = true
		if self.passive then
			self.pl_name:start_skill(self.internal_name)
		end

		return true
	end

	return def
end



function init_empty_subtable(table, subtable_name)
   table[subtable_name] = table[subtable_name] or {}
end



function update_pl_skill_data(pl_name, skill_name)
	local skill_def = skills.get_skill_def(skill_name)
	local pl_data = table.copy(skills.player_skills[pl_name][skill_name].data)

   -- adding any new data's properties declared in the def table
   -- to the already existing player's data table
   for key, def_value in pairs(skill_def.data) do
		if pl_data[key] == nil then pl_data[key] = def_value end

		-- if an old property's type changed, then reset it
		if type(pl_data[key]) ~= type(def_value) then pl_data[key] = def_value end
   end

	return pl_data
end



function join_defs(s1, s2)
	local excluded = {
		cast = true, start = true, stop = true,  -- since these are just the wrappers
		disable = true, enable = true -- these are not customizable
	}

	for key, value in pairs(s1) do
		if not excluded[key] and type(s1[key]) == "function" and type(s2[key]) == "function" then
			local original_s1_func = s1[key]

			s1[key] = function (self, ...)
				if original_s1_func(self, ...) ~= false then
					return s2[key](self, ...)
				else
					return false
				end
			end
		end
	end

	-- to copy functions that are not in s1
	return skills.override_params(s1, s2)
end
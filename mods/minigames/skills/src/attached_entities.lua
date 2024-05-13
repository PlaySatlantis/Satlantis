local expire_entities = {} -- "entity" = true



function skills.register_expiring_entity(name)
	local on_step = minetest.registered_entities[name].on_step or function(_, _, _) end
	local on_activate = minetest.registered_entities[name].on_activate or function(_, _, _) end

	-- Overriding the entity's callbacks & properties
	if not expire_entities[name] then
		minetest.registered_entities[name].initial_properties.static_save = false
		minetest.registered_entities[name].pl_name = ""

		minetest.registered_entities[name].on_activate = function(self, staticdata, dtime_s)
			self.pl_name = staticdata

			if staticdata == "" then
				self.object:remove()
				return
			end

			on_activate(self, staticdata, dtime_s)
		end

		minetest.registered_entities[name].on_step = function(self, dtime, moveresult)
			local infotext = self.object:get_properties().infotext

			-- if spawned by a skill, remove the entity if the skill has stopped
			if #infotext:split("skill->") == 1 then
				local skill_name = infotext:split("skill->")[1]
				local skill = self.pl_name:get_skill(skill_name)

				if not skill or not skill.is_active then
					self.object:remove()
					return
				end
			end

			on_step(self, dtime, moveresult)
  		end
	else
		expire_entities[name] = true
	end
end



function skills.attach_expiring_entity(skill, def)
	local pos = def.pos
	local name = def.name
	local bone = def.bone or ""
	local rotation = def.rotation or {x=0, y=0, z=0}
	local forced_visible = def.forced_visible or false

	local entity = minetest.add_entity(pos, name, skill.pl_name)
	entity:set_properties({infotext = "skill->"..skill.internal_name})
	entity:set_attach(skill.player, bone, pos, rotation, forced_visible)
end
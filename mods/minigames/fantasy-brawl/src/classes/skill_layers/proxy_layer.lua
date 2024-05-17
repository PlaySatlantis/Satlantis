skills.register_layer("fbrawl:proxy_layer", {
	--[[
	proxy = {
		name = "skill_name",
		args = {...}
	}
	--]]
	name = "Proxied Skill Layer",
	on_start = function (self, args)
		args = args or {}
		if not args.called_by_proxy then
			self.pl_name:unlock_skill(self.proxy.name)
			self.pl_name:start_skill(self.proxy.name, self.proxy.args)
			return false
		end
	end,
	cast = function (self, args)
		args = args or {}
		if not args.called_by_proxy and not self.loop_params then
			self.pl_name:unlock_skill(self.proxy.name)
			self.pl_name:start_skill(self.proxy.name, self.proxy.args)
			return false
		end
	end
})

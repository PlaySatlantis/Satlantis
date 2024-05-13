function log(msg)
	minetest.log(msg)
end

skills.register_layer("aa", {
	loop_params = {
		cast_rate = 0.4
	},
	passive = true,
	data = {
		p1 = "some string",
		p2 = "some other longer string",
		p3 = 45,
		p4 = 12,
		p5 = {
			p5_1 = 12,
			p5_2 = "a string in a subparameter",
			p5_3 = {
				p5_3_1 = "so many subtables",
				p5_3_2 = 300,
				p5_3_3 = false
			}
		}
	},
	on_start = function (self, x, y, z)
		log(("aa start and calls bb with params %s%s%s"):format(x,y,z))
	end,
	cast = function (self)
		log("aa cast")
	end
})
skills.register_layer("bb", {
	data = {
		b = "bb"
	},
	on_start = function (self, x, y, z)
		log((self.data.b .. " start with params %s%s%s"):format(x,y,z))
	end,
	cast = function (self)
		log("bb cast but won't call cc")
		return false
	end
})
skills.register_layer("cc", {
	data = {
		c = "cc"
	},
	on_start = function (self)
		log(self.data.c .. " start")
	end,
	cast = function (self)
		log("cc cast")
	end
})

skills.register_skill_based_on({"aa","bb","cc"}, "dd", {
	cast = function (self)
		log("-- DD --")
	end,
	on_stop = function (self)
		minetest.log("dd has stopped")
	end
})




function test_layered(pl_name)
	pl_name = pl_name or "Giov4"
	pl_name:start_skill("dd", "x", "y", "z")
end

local S = fbrawl.T



skills.register_skill("fbrawl:fire_sprint", {
    name = S("Fire Sprint"),
    icon = "fbrawl_fire_sprint_skill.png",
    description = S("Sprint forward damaging whoever stands in the way."),
    loop_params = {
        duration = 1.3,
        cast_rate = 0
    },
    sounds = {
        start = {name = "fbrawl_whoosh"}
    },
    data = {
        damage_inflicted = 0
    },
    cooldown = 8,
    max_damage = 4,
    damage = 4,
    attachments = {
        particles = {{
            amount = 240,
            time = 0,
            minpos = {x = -0.3, y =  0, z = -0.3},
            maxpos = {x = 0.3, y = 1.5, z = 0.3},
            minvel = {x = 0, y = -0.2, z = 0},
            maxvel = {x = 0, y = -0.1, z = 0.2},
            minsize = 1,
            maxsize = 4,
            glow = 12,
            texture = {
                name = "fbrawl_fire_particle.png",
                alpha_tween = {1, 0},
                scale_tween = {
                    {x = 1, y = 1},
                    {x = 0, y = 0},
                },
                animation = {
                    type = "vertical_frames",
                    aspect_w = 16, aspect_h = 16,
                    length = 0.3,
                },
            },
            minexptime = 1.5,
            maxexptime = 2,
        },
        {
            amount = 25,
            time = 0,
            minpos = {x = -0.3, y =  0, z = -0.3},
            maxpos = {x = 0.3, y = 1.5, z = 0.3},
            minvel = {x = 0, y = -0.4, z = 0},
            maxvel = {x = 0, y = -0.2, z = 0.2},
            minsize = 2,
            maxsize = 4,
            texture = {
               name = "fbrawl_smoke_particle.png",
               alpha_tween = {0.7, 0},
               scale_tween = {
                    {x = 0, y = 0},
                    {x = 0.5, y = 0.5},
                }
            },
            minexptime = 1.5,
            maxexptime = 1.5,
        }}
    },
    sprint_force = 27,
    on_start = function(self)
        local pl = self.player
        local velocity = vector.multiply(pl:get_look_dir(), self.sprint_force)
        velocity.y = 0

        self.data.damage_inflicted = 0
        
        pl:add_velocity(velocity)
    end,
    cast = function(self)
        if self.data.damage_inflicted >= self.max_damage or self.player:get_hp() <= 0 then 
			self:stop()
			return
		end

        local pl = self.player
        fbrawl.damage_players_near(pl, pl:get_pos(), 2.3, self.damage, nil, function ()
            self.data.damage_inflicted = self.data.damage_inflicted + self.damage
        end)
    end
})

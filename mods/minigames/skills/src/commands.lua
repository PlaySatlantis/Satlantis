local S = minetest.get_translator("skills")



ChatCmdBuilder.new("skills", function(cmd)

    cmd:sub("list", function(name)
        minetest.chat_send_player(name, "\nSkills > Skills list")

        for internal_name, def in pairs(skills.get_registered_skills()) do
            local skill_name = def.name or def.internal_name
            local skill_desc = def.description

            minetest.chat_send_player(name, skill_name:upper() .. " (" .. internal_name .. ")\n" .. skill_desc .. "\n\n")
        end
    end)

    cmd:sub("list :prefix", function(name, prefix)
        minetest.chat_send_player(name, "\nskills > " .. prefix .. " skills list")

        local skill_list = skills.get_registered_skills(prefix)

        if skills.player_skills[prefix] then -- if the prefix is a pl_name
            skill_list = skills.get_unlocked_skills(prefix)
        end

        for internal_name, def in pairs(skill_list) do
            local skill_name = def.name or internal_name
            local skill_desc = def.description

            minetest.chat_send_player(name, skill_name:upper() .. " (" .. internal_name .. ")\n" .. skill_desc .. "\n\n")
        end
    end)

    cmd:sub("unlock :player:username :skill", function(name, pl_name, skill_name)
        if not skills.does_skill_exist(skill_name) then
            skills.error(name, S("The skill @1 doesn't exist!", skill_name))
            return
        end

        if not pl_name:unlock_skill(skill_name) then
            skills.error(name, S("@1 already has that skill", pl_name))
            return
        end

        skills.print(name, S("@1 skill unlocked to @2", skill_name, pl_name))
    end)

    cmd:sub("remove :player:username :skill", function(name, pl_name, skill_name)
        if not skills.does_skill_exist(skill_name) then
            skills.error(name, S("The skill @1 doesn't exist!", skill_name))
            return
        end

        if not pl_name:has_skill(skill_name) then
            skills.error(name, S("@1 doesn't have that skill", pl_name))
            return
        end

        pl_name:remove_skill(skill_name)

        skills.print(name, S("@1 skill removed from @2", skill_name, pl_name))
    end)

    cmd:sub("disable :player:username :skill", function(name, pl_name, skill_name)
        if not skills.does_skill_exist(skill_name) then
            skills.error(name, S("The skill @1 doesn't exist!", skill_name))
            return
        end

        if not pl_name:has_skill(skill_name) then
            skills.error(name, S("@1 doesn't have that skill", pl_name))
            return
        end

        if not pl_name:disable_skill(skill_name) then
            skills.error(name, S("The @1 skill is already disabled", skill_name))
            return
        end

        skills.print(name, S("@1 skill disabled to @2", skill_name, pl_name))
    end)

    cmd:sub("enable :player:username :skill", function(name, pl_name, skill_name)
        if not skills.does_skill_exist(skill_name) then
            skills.error(name, S("The skill @1 doesn't exist!", skill_name))
            return
        end

        if not pl_name:has_skill(skill_name) then
            skills.error(name, S("@1 doesn't have that skill", pl_name))
            return
        end

        if not pl_name:enable_skill(skill_name) then
            skills.error(name, S("The @1 skill is already enabled", skill_name))
            return
        end

        skills.print(name, S("@1 skill enabled to @2", skill_name, pl_name))
    end)

    cmd:sub("flushdatabase", function(name)
        skills.remove_unregistered_skills_from_db()
        skills.print(name, S("Database flushed"))
    end)

end, {
    description = [[

      - list [prefix]: lists every registered skill
      - list <player>: lists all the skills of the specified player
      - unlock <player> <skill>
      - remove <player> <skill>
      - disable <player> <skill>
      - enable <player> <skill>
      - flushdatabase: removes any unregistered skill from the database
    ]],
    privs = {skills_admin = true}
})



minetest.register_privilege("skills_admin")
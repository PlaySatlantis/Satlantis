skills.register_skill("fbrawl:item_proxy", {
   name = "Item proxy",
   loop_params = {
      cast_rate = 0
   },
   -- args: item = "name", broadcast = "text"
   on_start = function (self, args)
      fbrawl.replace_weapon(self.player, args.item)
      arena_lib.HUD_send_msg("broadcast", self.pl_name, args.broadcast)
   end,
   cast = function (self, args)
      if fbrawl.get_weapon(self.player):get_name() ~= args.item then
         self:stop()
         return false
      end
   end,
   on_stop = function (self)
      if not fbrawl.is_player_playing(self.pl_name) then
         return
      end
      local arena = arena_lib.get_arena_by_player(self.pl_name)
      local weapon = arena.classes[self.pl_name].weapon

      fbrawl.replace_weapon(self.player, weapon)
      arena_lib.HUD_hide("broadcast", self.pl_name)
   end
})
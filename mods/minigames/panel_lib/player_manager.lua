minetest.register_on_leaveplayer(function(player)
  -- li rimuovo con 1 decimo di ritardo onde evitare che mod esterne effettuino
  -- calcoli quando un giocatore si disconnette. Questo evita la possibilità che
  -- venga effettuata prima la rimozione e poi il calcolo, causando un crash.
  -- Non ho inoltre bisogno di eseguire 'hud_remove', dato che le HUD vengono
  -- rimosse in automatico allo sconnettersi
  local p_name = player:get_player_name()

  minetest.after(0.1, function()
    panel_lib.remove_all(p_name)
  end)
end)

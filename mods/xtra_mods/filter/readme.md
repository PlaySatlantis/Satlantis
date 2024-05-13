# filter mod

This mod adds a simple chat filter. There is no default word list,
and adding words to the filter list is done through the `/filter`
chat command. You need the `server` priv to use the chat command.

The `/filter` chat command can `add`, `remove` or `list` words. The
words are stored in `mod_storage`, which means that this mod requires
0.4.16 or above to function.

If a player speaks a word that is listed in the filter list, they are
muted for 1 minute. After that, their `shout` privilege is restored.
If they leave, their `shout` privilege is still restored, but only after
the time expires, not before.

## API

### Callbacks

* filter.register_on_violation(func(name, message, violations))
	* Violations is the value of the player's violation counter - which is
	  incremented on a violation, and halved every 10 minutes.
	* Return true if you've handled the violation. No more callbacks will be
	  executation, and the default behaviour (warning/mute/kick) on violation
	  will be skipped.

### Methods

* filter.import_file(path)
	* Input bad words from a file (`path`) where each line is a new word.
* filter.check_message(name, message)
	* Checks message for violation. Returns true if okay, false if bad.
	  If it returns false, you should cancel the sending of the message and
	  call filter.on_violation()
* filter.on_violation(name, message)
	* Increments violation count, runs callbacks, and punishes the players.
* filter.mute(name, duration)
* filter.show_warning_formspec(name)

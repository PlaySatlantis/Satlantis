# Keyboard event binding

This mod provides an API for handling key pressed. Currently, the following keys are supported by the engine and hence supported by this mod:

* The direction keys (`W` `A` `S` `D`), with internal names `up`, `down`, `left`, and `right`.
* The jump key (*space*), with internal name `jump`.
* The aux1 or "sprint" key (`E`), with internal name `aux1`.
* The sneak key (`Shift`), with internal name `sneak`.
* The dig and place key (*left* and *right* mouse buttons), with the internal names `dig` and `place`.
* The zoom key (`Z`), with internal name `zoom`.

In the brackets are their default associated key, which may or may not be different. Every key is referred to by its internal name, called `key` below in the functions.

## API Reference

In the following functions, the `key` is the internal name of the desired key, and `func` is the function to be called, accepting one parameter (the player's `ObjectRef`).

* `keybinding.register_on_press(key, func)`: Register functions to be called once the key is pressed.
* `keybinding.register_hold_step(key, func)`: Register functions to be called on every globalsteps while the key is held. This is also called in the same globalstep as the key is pressed, but always after those registered by `register_on_press`.
* `keybinding.register_on_release(key, func)`: Register functions to be called once the key is released.
* `keybinding.register_on_leave_while_holding(key, func)`: Register functions to be called if a player leaves while holding a key
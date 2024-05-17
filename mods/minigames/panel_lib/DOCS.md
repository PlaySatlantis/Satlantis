# Panel_lib docs

## 1. Panel structure

A panel is a custom object made of 2 HUD elements, the title and the background, plus a group of two sub-elements: the text and the images. Picture the background as the container of all the things you want to showcase in your HUD. Those things go in the sub-elements.

### 1.1. Declaration
To declare a new panel, simply do
`local panel = Panel:new(name, {parameters})`

The parameters it takes are the following:
* `player`: required. The player to assign the panel to
* `position`: the panel position (as in any other HUD)
* `alignment`: same
* `offset`: same
* `z_index`: as in the Minetest HUD API
* `bg`: the picture to put in the background
* `bg_scale`: its scaling
* `title`: the default text. Default is empty (`""`)
* `title_size`: (table) as a multiplier, where Y is not considered. Ie. `{ x = 2}` will double up the font size
* `title_alignment`
* `title_offset`: if `offset` is declared already, it'll add/subtract the two values
* `title_color`
* `visible`: (bool) whether the panel is visible right after its creation. Default is `true`
* `sub_img_elems`: (table) whatever image to add to the panel
* `sub_txt_elems`: (table) whatever text to add to the panel

### 1.2. Sub-elements
Sub-elements are HUDs added on top of the main container, sharing the same position. This means two things:
1. As a HUD, they take the same parameters a HUD takes. They are clones respectively of the background and the title, so if you skip some parameter, they'll keep their reference default value.
2. If you wanna move them around, you must tweak the offset, **NOT** the position. If you change the position, they may look fine in a screen resolution, but not in another. In order to prevent it, `panel_lib` automatically overrides the position with the panel's.

Have a look at [the example file](https://gitlab.com/zughy-friends-minetest/panel_lib/-/blob/master/panel.example) to see a complete panel declaration.

## 2. Configuration

Install it as any other mod `¯\_(ツ)_/¯`

## 2.1. Functions

* `new({params})`: creates a new panel
* `get_info()`: returns a table containing the following fields:
  * `bg`: (table) a copy of the HUD of the background (with MT values such as `hud_elem_type`, `position`, `scale` etc.)
  * `title`: (table) same as `bg` but for the title HUD
* `show()`: makes the panel appear
* `hide()`: makes the panel disappear (but it's still assigned to the player)
* `is_visible()`: whether the panel is currently displayed
* `remove()`: deletes it
* `update(panel_params, txt_elems, img_elems)`: updates only the mentioned parameters. Beware: `panel_params` only supports a few. They are `position`, `offset`, `bg`, `title` and `title_color`.For instance, calling

```
panel:update(nil, nil, {my_custom_img = {
      text = "pic2.png"
    })
```
updates just the text of the sub-element `my_custom_img`.

* `add_sub_elem(type, name, HUD_elem)`: adds a sub-element at runtime. `type` must be either `text` or `image`. `HUD_elem` is the table representing the HUD
* `remove_sub_elem(name)`: removes a sub-element at runtime

## 2.2 Getters
* `panel_lib.get_panel(player_name, panel_name)`: obtains the panel associated with a player

## 3. Utils
* `panel_lib.has_panel(player_name, panel_name)`: returns true if the player has the specified panel

## 4. About the author(s)
I'm Zughy (Marco), a professional Italian pixel artist who fights for FOSS and digital ethics. If this library spared you a lot of time and you want to support me somehow, please consider donating on [LiberaPay](https://liberapay.com/Zughy/). Also, this project wouldn't have been possible if it hadn't been for some friends who helped me testing through: `SonoMichele`, `_Zaizen_` and `Xx_Crazyminer_xX`

# Server admins
To change background, overwrite the `phone_bg_img` image in `/textures`. Keep the same size or it'll break


# Developers
### Functions:
* `smartphone.register_app(technical_name, def)`: to register a new app that will appear on the home page. They will be displayed in alphabetical order
    * `technical_name` (string): the formspec name that will be opened when clicking on the icon. It must follow the formspec naming convention `modname:appname`
	* `def` (table): the app definition, having the following fields:
        * `icon` (string): the app icon texture (200x200 pixels)
        * `name` (string): the name that will be showed in the home page, under the icon
        * `bg_color` (string, hexadecimal color, optional): the app's background color
        * `priv_to_open` (string, optional): the privilege that the player must have to open the app. If not declared, everyone will be able to open it
        * `priv_to_visualize` (string, optional): the privilege that the player must have to see the app in the home page (and to open it, if the previous one wasn't specified). If not declared, everyone will be able to see it
        * `get_height` (function(self, player, [page, ...]), optional): should return (as a number) the actual app height, to allow scrolling it in case it's more than the screen height. If not declared, the app's height will default to `smartphone.content_height`
        * `get_content` (function(self, player, [page, ...])): a function that will receive the app definition table, the player ObjectRef, and a string indicating the page as parameters, it must return the formspec elements that will be placed in a scrollable container
        * `...other properties you may need`: they will be accessible in the `self` parameter of the `get_content` function
* `smartphone.open_smartphone(player)`: opens the smartphone formspec to the player
* `smartphone.open_app(player, technical_name, ...)`: opens the desired app formspec to the player
* `smartphone.is_app(technical_name)`: returns true if the app has been registered - can be useful to check whether formnames are apps
* `smartphone.get_app(app_name_or_page)`: returns the app definition table, if the app has been registered, or false otherwise
* `smartphone.open_page(player, page_formname, ...)`: you can use this to open a page in an app.
    * `page_formname` (string): it *must* follow the naming convention `app_technical_name.page_name` (e.g. "smartphone:wiki.first_steps"). After you call this function, the mod will display the content returned by `get_content_<page_formname>(self, player, ...)` function or, if it doesn't exist, it will call `smartphone.open_app(player, app_name, page_name, ...)` where page_name is a string containing just the page name (e.g. "first_steps")

### Smartphone formspec properties:
* `smartphone.fs_width` (number): the smartphone formspec width
* `smartphone.fs_height` (number): the smartphone formspec height
* `smartphone.content_y` (number): the content container y position, everything in it will be vertically offsetted by this value
* `smartphone.nav_bar_height` (number): the navigation bar height
* `smartphone.content_height` (number): the app content height (the height of the screen minus the header and footer heights)
* `smartphone.get_header([def])` (returns formspec string): returns everything that is drawn above the app content
    * `def` (table, optional as any of its parameters)
        * `bg_color` (string, hexadecimal color)
* `smartphone.smartphone_footer` (string, formspec): everything that is drawn below the app content (e.g. the navigation bar)
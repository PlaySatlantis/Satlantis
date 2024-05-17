# Markdown2Formspec

A super simple mod to covert markdown text into part of a formspec, specifically a `hypertext[]` element.

There are two functions provided:

```lua
md2f.md2f(x,y,w,h,markdown_string, settings)

md2f.md2ff(x,y,w,h,markdown_file, settings)
```

Both will result in correctly formatted hypertext elements that match markdown output.

### Settings

`settings` is an optional argument, and if present, can override any of the following default settings:

```lua
settings = {
    background_color = "#bababa25",
    font_color = "#FFF",
    heading_1_color = "#AFA",
    heading_2_color = "#FAA",
    heading_3_color = "#AAF",
    heading_4_color = "#FFA",
    heading_5_color = "#AFF",
    heading_6_color = "#FAF",
    heading_1_size = "26",
    heading_2_size = "24",
    heading_3_size = "22",
    heading_4_size = "20",
    heading_5_size = "18",
    heading_6_size = "16",
    code_block_mono_color = "#6F6",
    code_block_font_size = 14,
    mono_color = "#6F6",
    block_quote_color = "#FFA",
}
```

### Notes

1. All images will be centered
2. Images have extra syntax: `![w,h](image.png)` will result in an image scaled to those provided dimensions in pixels.
3. Nesting is not supported at this time (such as headings inside block quotes)
4. \`\`\` are supported, but they must begin a line to count.
5. Headings are not auto-bolded or auto underlined

-----------------------------------------
-----------------------------------------

# Sample of tested and supported markdown:
````markdown
# Level 1
## Level 2
### Level 3
#### Level 4
##### Level 5
###### Level 6

Paragraph 1 is a test paragaph, hopefully this is long enough to justify going to the next few lines.

This is another paragraph, should have worked.

```
int a = 5;
std::cout << a << std::endl;
```

**Bold Text**

*Italics Text*

***Bold and Italics***

> Block quote attempt

> Multiline, and multi paragraph
>
> Block Quote

1. Numbers will
3. Be Somewhat difficult
2. To support

- Unordered
- Lists
- Should be a breeze, hopefully
* Personally, 
* I think this should start a new 
* list set


`test`
`test`

![24,24](text)
![36,36](text2)
![48,48](text3)

Nested `code text` should be monospaced

These
--- 
Should
*** 
All be lines
_______

<htts://www.google.com>

----------
----------

````
# Output in formspec

![screenshot](screenshot.jpg)

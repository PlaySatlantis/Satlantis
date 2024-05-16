--                    _       _                     ____    ___                                        
--   /\/\   __ _ _ __| | ____| | _____      ___ __ |___ \  / __\__  _ __ _ __ ___  ___ _ __   ___  ___ 
--  /    \ / _` | '__| |/ / _` |/ _ \ \ /\ / / '_ \  __) |/ _\/ _ \| '__| '_ ` _ \/ __| '_ \ / _ \/ __|
-- / /\/\ \ (_| | |  |   < (_| | (_) \ V  V /| | | |/ __// / | (_) | |  | | | | | \__ \ |_) |  __/ (__ 
-- \/    \/\__,_|_|  |_|\_\__,_|\___/ \_/\_/ |_| |_|_____\/   \___/|_|  |_| |_| |_|___/ .__/ \___|\___|
--                                                                                    |_|              
--
-- Markdown2Formspec (md2f)
-- MIT License
-- Copyright ExeVirus 2021
--
-- This file has all local parsing functions first,
-- followed by the global api access for other mods
-- to work with markdown 2 formspec.

----------------Local Functions----------------

local function D(msg)
    minetest.log("verbose", msg)
end

local function loadFile(filename)
    local file = io.open(filename, "rb") -- r read mode and b binary mode
    if not file then return nil end
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return content
end

-- The returned formspec header
local function header(x,y,w,h,name)
    return "hypertext["..x..","..y..";"..w..","..h..";"..name..";"
end

-- The returned formspec footer
local function footer()
    return "]"
end

-- Predeclare parseLine, because it's a large function,
-- and it makes sense to have it defined later
local parseLine = nil

------------------------The main parsing function for md2f-------------------------------
local function unpack(text,width, settings)

    -- 1. Convert newlines to \n
    text = text:gsub("\r\n", "\n") --windows
    text = text:gsub("\r", "\n") -- MacOs 9 and older

    -- 2. Break apart lines into array
    local _lines = {}
    for s in text:gmatch("([^\n]*)\n?") do
        table.insert(_lines, s)
    end

    -- 3. Handle Settings
    settings = settings or {}
    settings.background_color = settings.background_color or "#bababa25"
    settings.font_color = settings.font_color or "#FFF"
    settings.heading_1_color = settings.heading_1_color or "#AFA"
    settings.heading_2_color = settings.heading_2_color or "#FAA"
    settings.heading_3_color = settings.heading_3_color or "#AAF"
    settings.heading_4_color = settings.heading_4_color or "#FFA"
    settings.heading_5_color = settings.heading_5_color or "#AFF"
    settings.heading_6_color = settings.heading_6_color or "#FAF"
    settings.heading_1_size = settings.heading_1_size or "26"
    settings.heading_2_size = settings.heading_2_size or "24"
    settings.heading_3_size = settings.heading_3_size or "22"
    settings.heading_4_size = settings.heading_4_size or "20"
    settings.heading_5_size = settings.heading_5_size or "18"
    settings.heading_6_size = settings.heading_6_size or "16"
    settings.code_block_mono_color = settings.code_block_mono_color or "#6F6"
    settings.code_block_font_size = settings.code_block_font_size or 14
    settings.mono_color = settings.mono_color or "#6F6"
    settings.block_quote_color = settings.block_quote_color or "#FFA"

    -- 4. declare tracking table for keeping track of our state (text, bold, block quote, etc.)
    local state = { 
        formspec = "<global background="..settings.background_color.. " color=".. settings.font_color ..">",
        width = width,
        carried_text = "",
        settings = settings
    }

    -- 5. iterate over lines, parsing linearly
    for lineNumber=1, #_lines, 1 do
        parseLine(_lines[lineNumber], state) --state is changed within function
    end
   
    -- 6. return the parsed formspec
    return state.formspec
end

-- parseLine helper functions
local function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

--Remove extra whitespace in between words or characters
local function trimMd(s)
    return s:gsub("\t", " "):gsub("%s+", " ")
end

local function escapeHypertext(s)
    return s:gsub("<", "\\<"):gsub(";","\\;"):gsub("]","\\]")
end

------------------------------------------------------------
-- escape()
-- escapes any characters that need escaped
------------------------------------------------------------
local function escape(text)
    local function replace(char)
        text = text:gsub("\\"..char, "Qqo"..string.byte(char:sub(-1)).."Qqo")
    end
    replace("\\")
    replace("`")
    replace("%*")
    replace("_")
    replace("{")
    replace("}")
    replace("%[")
    replace("]")
    replace("<")
    replace(">")
    replace("%(")
    replace("%)")
    replace("#")
    replace("%+")
    replace("%-")
    replace("%.")
    replace("!")
    replace("|")
    return text
end

------------------------------------------------------------
-- escape()
-- reverts any characters that are escaped
------------------------------------------------------------
local function unescape(text)
    local function replace(char)
        text = text:gsub("Qqo"..string.byte(char:sub(-1)).."Qqo", char)
    end
    replace("\\")
    replace("`")
    replace("%*")
    replace("_")
    replace("{")
    replace("}")
    replace("%[")
    replace("]")
    replace("<")
    replace(">")
    replace("%(")
    replace("%)")
    replace("#")
    replace("%+")
    replace("%-")
    replace("%.")
    replace("!")
    replace("|")
    return text
end

------------------------------------------------------------
-- emphasisParse()
-- handles bold, italics, etc. for a group of text
-- It also handles formspec escaping such as \] and \\\\ messiness
-- text: text to be added
------------------------------------------------------------
local function emphasisParse(text, state)
    text = escape(text)
    local finished = false
    local last = 1
    while finished == false do
        if text:find("<%S.-%S>", last) then --url
            local start,finish = text:find("<%S.-%S>", last)
            text = text:sub(1,start-1) .. "<style color=#77AAFF>" .. text:sub(start+1,finish-1) .. "</style>" .. text:sub(finish+1)
            last = finish + 36 --number of characters added minus 2
        else
            finished = true
        end
    end
    finished = false
    while finished == false do
        if text:find("`%S.-%S`") then --monospaced
            local start,finish = text:find("`%S.-%S`")
            local mono_start, mono_end
            if state.settings ~= nil then
                mono_start = "<mono><style color=".. state.settings.mono_color ..">"
                mono_end = "</mono></style>"
            else
                mono_start = "<mono>"
                mono_end = "</mono>"
            end
            text = text:sub(1,start-1) .. mono_start .. text:sub(start+1,finish-1) .. mono_end .. text:sub(finish+1)
        else
            finished = true
        end
    end
    finished = false
    while finished == false do
        if text:find("%*%*%*%S.-%S?%*%*%*") then --Handle all Bold and Italics combo first
            local start,finish = text:find("%*%*%*%S.-%S?%*%*%*")
            text = text:sub(1,start-1) .. "<b><i>" .. text:sub(start+3,finish-3) .. "</b></i>" .. text:sub(finish+1)
        elseif text:find("%*%*%S.-%S%*%*") then -- then all bold
            local start,finish = text:find("%*%*%S.-%S%*%*")
            text = text:sub(1,start-1) .. "<b>" .. text:sub(start+2,finish-2) .. "</b>" .. text:sub(finish+1)
        elseif text:find("%*%S.-%S%*") then -- then all italics
            local start,finish = text:find("%*%S.-%S%*")
            text = text:sub(1,start-1) .. "<i>" .. text:sub(start+1,finish-1) .. "</i>" .. text:sub(finish+1)
        else
            finished = true
        end
    end
    text = unescape(text)

    --Now to handle formspec escaping
    text = text:gsub("]", "\\]") -- ]
    text = text:gsub(";", "\\;") -- ;

    return escapeHypertext(text)
end

--This function will close all states such as 
-- bold, italics, block quote, etc.
local function finishParse(state)
    --Finish Plain Text first
    if state.carried_text ~= "" then
        state.formspec = state.formspec .. emphasisParse(state.carried_text, state) .. "\n"
        state.carried_text = ""
    end

    --Finish Block Quote
    if state.in_quote then
        --revert the color and add the bottom image
        state.formspec = state.formspec .. 
        "<img name=md2f_line.png width=".. (60*state.width) * 0.8 .." height=5>\n"
        if state.settings ~= nil then
            state.formspec = state.formspec .. "<global color=".. state.settings.font_color ..">"
        else
            state.formspec = state.formspec .. "<global color=#FFF>"
        end
        state.in_quote = nil
    end

    --Finish Ordered List
    state.in_ordered_list = nil

    --Finish Unordered List
    state.in_unordered_list = nil
end

------------------------------------------------------------
-- handlePlainText()
-- Handles Emphasis and carries text until the end of a
-- paragraph or similar
-- text: text to be added
-- state: Shared state variable of parser
------------------------------------------------------------
local function handlePlainText(text, state)
    --track if we handled it
    local handled = false

    if text:find(".+") then -- 'something' sanity check
        state.carried_text = state.carried_text .. " " .. text
        handled = true
    end

    return handled
end

------------------------------------------------------------
-- handleHeading()
-- Checks/Handles if the given line is a '## heading' line
-- Automatically ends previous lines
-- line: Line to be handled
-- state: Shared state variable of parser
------------------------------------------------------------
local function handleHeading(line, state)
    --track if we handled it
    local handled = false

    if line:find("^#+%s+") then --heading
        local _,_,text = line:find("^#+%s+(.*)")
        text = text or "" -- handle no characters
        text = trimMd(text) -- remove superluous whitespace
        local _,count = line:find("#+")

        --check that this is a valid header:
        if text:find("%w") and count > 0 and count < 7 then
            -- Finish any previous parsing whenever a new header is started
            finishParse(state)
            
            --handle colors from settings
            local color = { [1]="", [2]="", [3]="", [4]="", [5]="", [6]=""}
            local size  = { [1]="48", [2]="36", [3]="30", [4]="24", [5]="16", [6]="12"}
            if state.settings ~= nil then 
                color = {
                    [1]=" color=" .. state.settings.heading_1_color,
                    [2]=" color=" .. state.settings.heading_2_color,
                    [3]=" color=" .. state.settings.heading_3_color,
                    [4]=" color=" .. state.settings.heading_4_color,
                    [5]=" color=" .. state.settings.heading_5_color,
                    [6]=" color=" .. state.settings.heading_6_color,
                }
                size = {
                    [1]= state.settings.heading_1_size,
                    [2]= state.settings.heading_2_size,
                    [3]= state.settings.heading_3_size,
                    [4]= state.settings.heading_4_size,
                    [5]= state.settings.heading_5_size,
                    [6]= state.settings.heading_6_size,
                }
            end
            if count == 1 then
                state.formspec = state.formspec .. "<style size="..size[1]..color[1]..">"..emphasisParse(text, state).."</style>\n"
            elseif count == 2 then
                state.formspec = state.formspec .. "<style size="..size[2]..color[2]..">"..emphasisParse(text, state).."</style>\n"
            elseif count == 3 then
                state.formspec = state.formspec .. "<style size="..size[3]..color[3]..">"..emphasisParse(text, state).."</style>\n"
            elseif count == 4 then
                state.formspec = state.formspec .. "<style size="..size[4]..color[4]..">"..emphasisParse(text, state).."</style>\n"
            elseif count == 5 then
                state.formspec = state.formspec .. "<style size="..size[5]..color[5]..">"..emphasisParse(text, state).."</style>\n"
            elseif count == 6 then
                state.formspec = state.formspec .. "<style size="..size[6]..color[6]..">"..emphasisParse(text, state).."</style>\n"
            end
            handled = true
        end
    end
    return handled
end

------------------------------------------------------------
-- handleQuote()
-- Checks/Handles if the given line is a '> quote' line
-- Automatically ends previous lines
-- Note: even though quotes are supposed to be contiguous, we can't
-- do indents safely, so each will be considered on its own. We'll
-- use an image on the left and different colored text. Probably
-- will become a setting.
-- line: Line to be handled
-- state: Shared state variable of parser
------------------------------------------------------------
local function handleQuote(line, state)
    --track if we handled it
    local handled = false
    local is_quote = false
    local _,text = nil,""
    
    if line:find("^>%s+") then --quote
        _,_,text = line:find("^>%s+(.*)")
        is_quote = true
    elseif line:find("^>") then -- empty quote
        _,_,text = line:find("^>(.*)")
        is_quote = true
    end

    if is_quote then
        text = text or "" -- handle no characters
        text = trimMd(text) -- remove superluous whitespace

        if not state.in_quote then
            --Finish any previous lines
            finishParse(state)

            --Place the image bar on the top
            state.formspec = state.formspec .. 
            "<img name=md2f_line.png width=" .. (60*state.width) * 0.8 .. " height=5>\n"

            --Change the text color
            if state.settings ~= nil then
                state.formspec = state.formspec .. "<global color=".. state.settings.block_quote_color ..">"
            else
                state.formspec = state.formspec .. "<global color=#CC8>"
            end

            --Then modify our state to being in a quote block
            state.in_quote = true
        else
            if text == "" or text == " " then
                state.in_quote = false
                finishParse(state)
                state.in_quote = true
            end
        end
    end
    if is_quote and state.in_quote then
        --Now process as normal plaintext (which handles continuations)
        handlePlainText(text, state)
        handled = true
    end
    return handled
end

------------------------------------------------------------
-- handleCodeBlock()
-- handles ``` codeblocks
-- line: Line to be handled
-- state: Shared state variable of parser
------------------------------------------------------------
local function handleCodeBlock(line, state)
    --track if we handled it
    local handled = false
    
    if state.block_quote then
        if line:find("^```") then
            state.block_quote = nil
            state.formspec = state.formspec .. "</mono>"
            if state.settings ~= nil then
                state.formspec = state.formspec .. "</style>"
            end
            handled = true
        else
           state.formspec = state.formspec .. escapeHypertext(line) .. "\n"
           handled = true
        end
    else
        if line:find("^```") then
            --Finish any previous lines
            finishParse(state)
            state.block_quote = true
            state.formspec = state.formspec .. "<mono>"
            if state.settings ~= nil then
                state.formspec = state.formspec ..
                "<style color=".. state.settings.code_block_mono_color
                .." size=".. state.settings.code_block_font_size .. ">"
            end
            handled = true
        end
    end

    return handled
end

------------------------------------------------------------
-- handleOrderedList()
-- Any number followed by a '.' and space will
-- count for this List
-- line: Line to be handled
-- state: Shared state variable of parser
------------------------------------------------------------
local function handleOrderedList(line, state)
    --track if we handled it
    local handled = false
    
    if line:find("^%d+%.%s+") then -- '#. '
        local _,_,text = line:find("^%d+%.%s+(.*)")
        text = text or "" -- handle no characters
        text = trimMd(text) -- remove superluous whitespace

        if not state.in_ordered_list then
            --Finish any previous lines
            finishParse(state)

            --Place the number followed by the line
            state.formspec = state.formspec .. " 1. " .. emphasisParse(text, state) .. "\n"

            -- Then make note of our state
            state.in_ordered_list = true
            state.listnum = 2
        else
            -- Place next number followed by line
            state.formspec = state.formspec .. " "..state.listnum.. ". " .. emphasisParse(text, state) .. "\n"
            -- Increment for next number
            state.listnum = state.listnum + 1
        end
        handled = true
    end

    return handled
end

------------------------------------------------------------
-- handleUnorderedList()
-- Any number followed by a '.' and space will
-- count for this List
-- line: Line to be handled
-- state: Shared state variable of parser
------------------------------------------------------------
local function handleUnorderedList(line, state)
    --track if we handled it
    local handled = false
    
    if line:find("^[%-%*]%s+") then -- '#. '
        local _,_,text = line:find("^[%-%*]%s+(.*)")
        text = text or "" -- handle no characters
        text = trimMd(text) -- remove superluous whitespace

        if not state.in_unordered_list then
            --Finish any previous lines
            finishParse(state)

            --Place the number followed by the line
            state.formspec = state.formspec .. " - " .. emphasisParse(text, state) .. "\n"

            -- Then make note of our state
            state.in_unordered_list = true
        else
            state.formspec = state.formspec .. " - " .. emphasisParse(text, state) .. "\n"
        end
        handled = true
    end

    return handled
end

------------------------------------------------------------
-- handleImage()
-- ![###,###,lr](filename) the ###,### allows the image to
-- be absolutely sized; either l or r (optionally) floats the image left or right
-- i.e. 25,25 = 25width/height in pixels
-- line: Line to be handled
-- state: Shared state variable of parser
------------------------------------------------------------
local function handleImage(line, state)
    --track if we handled it
    local handled = false
    D("handleImage("..line..")")
    
    if line:find("^!%[%d*,?%d*,?[lr]?%]%([%w%p]*%)") then -- ![##,##](filename)
        --Finish any previous lines
        finishParse(state)

        local _,_,w,h,float,filename = line:find("^!%[(%d*),?(%d*),?([lr]*)%]%(([%w%p]*)%)")
        local tag = "<img name="..escapeHypertext(filename)
        local lf = "\n"
        if filename:find("item:///.*") then
            tag = "<item name="..escapeHypertext(filename:gsub("item:///", ""))
        end
        if float == "l" then
            tag = tag .. " float=left"
            lf = ""
        elseif float == "r" then
            tag = tag .. " float=right"
            lf = ""
        end
        if w ~= "" and h ~= "" then
            state.formspec = state.formspec .. "<global halign=center>"..lf..tag.." width="..w.." height="..h.."><global halign=left>"..lf
        else
            state.formspec = state.formspec .. "<global halign=center>"..lf..tag.."><global halign=left>"..lf
        end
        handled = true
    end

    return handled
end

------------------------------------------------------------
-- handleHorizontalRule()
-- ___ or *** or --- or more on a line by themselves will result
-- in a horizontal rule (line) output
-- line: Line to be handled
-- state: Shared state variable of parser
------------------------------------------------------------
local function handleHorizontalRule(line, state)
    --track if we handled it
    local handled = false
    -- track if it matched any of the line patterns
    local doline = false

    if line:find("^%-%-%-+") then -- '---'
        local _,_,stuff = line:find("^%-%-%-+(.*)")
        if stuff == "" then
            doline = true
        end
    elseif line:find("^___+") then -- '___'
        local _,_,stuff = line:find("^___+(.*)")
        if stuff == "" then
            doline = true
        end
    elseif line:find("^%*%*%*+") then -- '***'
        local _,_,stuff = line:find("^%*%*%*+(.*)")
        if stuff == "" then
            doline = true
        end
    end

    if doline then
        --Finish any previous lines
        finishParse(state)
        -- Add horizontal rule
        state.formspec = state.formspec .. "<img name=md2f_line.png width="..(60*state.width).." height=4>\n"
        handled = true
    end

    return handled
end

------------------------------------------------------------
-- handleNewline()
-- Just Finish the previous parsing
-- line: Line to be handled
-- state: Shared state variable of parser
------------------------------------------------------------
local function handleNewLine(line, state)
    --track if we handled it
    local handled = false

    if trimMd(line) == " " or line == "" then -- '\n'
        finishParse(state)
        handled = true
    end

    return handled
end

------------------------------------------------------------
-- parseLine()
-- line: line of text to be unparsed
-- state: current state of parser
------------------------------------------------------------
parseLine = function(line, state)
    if handleCodeBlock(line,state) then
        D("CODEBLOCK: "..line)
        return
    end
    -- Remove preceding and trailing whitespace
    line = trim(line)
    if handleHeading(line,state) then
        D("HEADING: "..line)
        return
    elseif handleQuote(line,state) then
        D("QUOTE: "..line)
        return
    elseif handleOrderedList(line,state) then
        D("OL: "..line)
        return
    elseif handleUnorderedList(line,state) then
        D("UL: "..line)
        return
    elseif handleImage(line,state) then
        D("IMG: "..line)
        return
    elseif handleHorizontalRule(line,state) then
        D("RULE: "..line)
        return
    elseif handleNewLine(line,state) then
        D("NEWLINE: "..line)
        return
    else --plaintext
        if state.in_quote or state.in_ordered_list or state.in_unordered_list then
            finishParse(state)
        end
        if handlePlainText(line,state) then
            D("PLAIN: "..line)
            return
        end
    end
    --Only errors should get here
    state.formspec = state.formspec or ""
    state.formspec = state.formspec + "\nMarkdown2Formspec ERROR, please report\n"
end


-----------------------------------------------------------------------
----------------------------global namespace---------------------------
md2f = {}

-- md2f()
--
-- x: position of hypertext[] element
-- y: position of hypertext[] element
-- w: width of hypertext element. roughly 60 pixels per 1 unit
-- h: height of hypertext element. Scrollbar appears when it overflows
-- text: markdown text to convert
-- name: optional name for hypertext element
md2f.md2f = function(x,y,w,h,text,name,settings)
    if text == nil then
        minetest.log(filename .. "does not exist or is empty")
        return ""
    end
    name = name or "markdown"
    return header(x,y,w,h,name) .. unpack(text,w,settings) .. footer()
end

-- md2ff()
--
-- x: position of hypertext[] element
-- y: position of hypertext[] element
-- w: width of hypertext element. roughly 60 pixels per 1 unit
-- h: height of hypertext element. Scrollbar appears when it overflows
-- file: exact name and location of the markdown file to convert
-- name: optional name for hypertext element
md2f.md2ff = function(x,y,w,h,filename,name,settings)
    local text = loadFile(filename)
    return md2f.md2f(x,y,w,h,text,name,settings)
end

-- header()
--
-- Default formspec header for the lazy
md2f.header = function()
	return "formspec_version[4]size[20,20]position[0.5,0.5]bgcolor[#111E]\n"
end
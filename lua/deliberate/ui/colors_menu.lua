local PopUp = require("deliberate.lib.ui.PopUp")
local Input = require("deliberate.lib.ui.Input")
local tcm = require("deliberate.api.tailwind_class_modifier")
local transformer = require("deliberate.lib.arbitrary_transformer")
local menu_repeater = require("deliberate.api.menu_repeater")
local reader = require("deliberate.lib.custom_tailwind_color_reader")
local lua_patterns = require("deliberate.lib.lua_patterns")

local M = {}

local base_colors = {
    { text = "", keymaps = { "0" }, hidden = true },
    { text = "slate", keymaps = { "sl" } },
    { text = "gray", keymaps = { "G" } },
    { text = "zinc", keymaps = { "z" } },
    { text = "neutral", keymaps = { "n" } },
    { text = "stone", keymaps = { "st" } },
    { text = "red", keymaps = { "r" } },
    { text = "orange", keymaps = { "o" } },
    { text = "amber", keymaps = { "a" } },
    { text = "yellow", keymaps = { "y" } },
    { text = "lime", keymaps = { "l" } },
    { text = "green", keymaps = { "g" } },
    { text = "emerald", keymaps = { "e" } },
    { text = "teal", keymaps = { "t" } },
    { text = "cyan", keymaps = { "c" } },
    { text = "sky", keymaps = { "sk" } },
    { text = "blue", keymaps = { "b" } },
    { text = "indigo", keymaps = { "i" } },
    { text = "violet", keymaps = { "v" } },
    { text = "purple", keymaps = { "p" } },
    { text = "fuchsia", keymaps = { "f" } },
    { text = "pink", keymaps = { "P" } },
    { text = "rose", keymaps = { "R" } },
    "",
    { text = "white", keymaps = { "w" }, single = true },
    { text = "black", keymaps = { "B" }, single = true },
    "",
    { text = "inherit", keymaps = { "I" }, single = true },
    { text = "current", keymaps = { "C" }, single = true },
    { text = "transparent", keymaps = { "T" }, single = true },
    { text = "", keymaps = { "," }, arbitrary = true, hidden = true },
}

local steps = {
    { text = "100", keymaps = { "m", "1", "q" } },
    { text = "200", keymaps = { ",", "2", "w" } },
    { text = "300", keymaps = { ".", "3", "e" } },
    { text = "400", keymaps = { "j", "4", "r" } },
    { text = "500", keymaps = { "k", "5", "a" } },
    { text = "600", keymaps = { "l", "6", "s" } },
    { text = "700", keymaps = { "u", "7", "d" } },
    { text = "800", keymaps = { "i", "8", "f" } },
    { text = "900", keymaps = { "o", "9", "g" } },
}

local show_arbitrary_input = function(metadata, prefix, fn, property)
    local input = Input:new({
        title = "Input Color",
        width = 15,
        on_change = function(result)
            local value = transformer.input_to_color(result)
            value = string.format("%s-[%s]", prefix, value)
            fn({ value = value, property = property })
        end,
    })

    local row, col = unpack(vim.api.nvim_win_get_position(0))
    input:show(metadata, row, col)
end

-------------------------------------------- Load custom colors config in tailwind.config.js

local custom_config_colors = {}
local auto_loaded = false

M.auto_load_tailwind = function()
    if not auto_loaded then M.load_custom_tailwind_colors() end
    auto_loaded = true
end

local aliases = {
    main = { "m" },
    secondary = { "S" },
    primary = { "<C-p>" },
}

local filter_substr = function(tbl, substr)
    for _, item in ipairs(tbl) do
        if string.find(item, substr, 1) then return true end
    end
end

local find_hints = function(colors_object)
    local hints = {}
    local existing_hints = {}

    for _, item in ipairs(base_colors) do
        if type(item) == "table" then
            for _, keymap in ipairs(item.keymaps) do
                table.insert(existing_hints, keymap)
            end
        end
    end

    for key, _ in pairs(colors_object) do
        -- has alias
        if aliases[key] then
            hints[key] = aliases[key]
            goto continue
        end

        -- try to find valid hint
        local first_char = string.sub(key, 1, 1)
        local first_2_chars = string.sub(key, 1, 1)
        local tries = { string.lower(first_char), string.upper(first_char), string.lower(first_2_chars), string.upper }

        for _, try in ipairs(tries) do
            if not filter_substr(existing_hints, try) then
                hints[key] = try
                table.insert(existing_hints, try)
                goto continue
            end
        end

        -- else
        hints[key] = ""

        ::continue::
    end

    return hints
end

M.load_custom_tailwind_colors = function()
    custom_config_colors = {}

    local tailwind = reader.get_json_data_from_tailwind_config()
    local colors_object = tailwind.theme.extend.colors
    local hints = find_hints(colors_object)

    for key, value in pairs(colors_object) do
        if type(value) == "string" then
            table.insert(
                custom_config_colors,
                1,
                { text = key, single = true, keymaps = hints[key] }
            )
            lua_patterns.add_to_postfixes(string.format("%%-%s", key))
        end
        if type(value) == "table" then table.insert(custom_config_colors, 1, { text = key }) end
    end

    lua_patterns.initialize_patterns()
end

local get_base_and_custom_colors = function()
    local all_colors = vim.deepcopy(base_colors)
    if #custom_config_colors > 0 then table.insert(all_colors, 1, "") end
    for _, item in ipairs(custom_config_colors) do
        table.insert(all_colors, 1, item)
    end
    return all_colors
end

--------------------------------------------

M._menu = function(filetype, prefix, fn, property)
    menu_repeater.register(M._menu, filetype, prefix, fn, property)

    local all_colors = get_base_and_custom_colors()

    local popup = PopUp:new({
        filetype = filetype,
        steps = {
            {
                items = all_colors,
                format_fn = function(_, current_item)
                    return string.format("%s-%s", prefix, current_item.text)
                end,
                callback = function(_, current_item, metadata)
                    if current_item.arbitrary == true then
                        show_arbitrary_input(metadata, prefix, fn, property)
                        return true
                    end
                    if current_item.text == "" then
                        fn({ value = "", property = property })
                        return true
                    end
                    if current_item.single then
                        local value = string.format("%s-%s", prefix, current_item.text)
                        fn({ value = value, property = property })
                        return true
                    end
                end,
            },
            {
                items = steps,
                format_fn = function(results, current_item)
                    return string.format("%s-%s-%s", prefix, results[1], current_item.text)
                end,
                callback = function(results)
                    local value = string.format("%s-%s-%s", prefix, results[1], results[2])
                    fn({ value = value, property = property })
                end,
            },
        },
    })

    popup:show()
end

-------------------------------------------- Public Methods

local txt_ft = "tailwind-text-color-picker"
local bg_ft = "tailwind-bg-color-picker"
local fn = tcm._change

M.text = function() M._menu(txt_ft, "text", tcm.change_text_color) end
M.background = function() M._menu(bg_ft, "bg", tcm.change_background_color) end
M.border = function() M._menu(bg_ft, "border", fn, "border-color") end
M.divide = function() M._menu(bg_ft, "divide", fn, "divide-color") end
M.ring = function() M._menu(bg_ft, "ring", fn, "ring-color") end
M.ring_offset = function() M._menu(bg_ft, "ring-offset", fn, "ring-offset-color") end
M.from = function() M._menu(bg_ft, "from", fn, "from-color") end
M.via = function() M._menu(bg_ft, "via", fn, "via-color") end
M.to = function() M._menu(bg_ft, "to", fn, "to-color") end
M.decoration = function() M._menu(bg_ft, "decoration", fn, "text-decoration-color") end
M.shadow = function() M._menu(bg_ft, "shadow", fn, "shadow-color") end
M.accent = function() M._menu(bg_ft, "accent", fn, "accent-color") end
M.caret = function() M._menu(bg_ft, "caret", fn, "caret-color") end
M.fill = function() M._menu(bg_ft, "fill", fn, "fill-color") end
M.stroke = function() M._menu(bg_ft, "stroke", fn, "stroke-color") end
M.outline = function() M._menu(bg_ft, "outline", fn, "outline-color") end

return M

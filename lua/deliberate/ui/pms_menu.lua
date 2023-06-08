local PopUp = require("deliberate.lib.ui.PopUp")
local Input = require("deliberate.lib.ui.Input")
local tcm = require("deliberate.api.tailwind_class_modifier")
local transformer = require("deliberate.lib.arbitrary_transformer")
local menu_repeater = require("deliberate.api.menu_repeater")

local M = {}

-------------------------------------------- Format Functions

local get_3_separator_class = function(axis, property, current_item)
    return string.format("%s-%s-%s", property, axis, current_item.text)
end

local dashy_group = {
    "border",
    "space",
    "divide",
    "border-opacity",
    "divide-opacity",
    "ring-opacity",
    "text",
    "ring",
    "ring-offset",
    "w",
    "h",
    "min-w",
    "min-h",
    "max-w",
    "max-h",
}
local in_dashy_group = function(property) return vim.tbl_contains(dashy_group, property) end

local format_class = function(property, axis, current_item)
    if current_item.text == "" and current_item.absolute then return current_item.absolute end
    if current_item.text == "" then return "" end
    if not axis or axis == "" then return string.format("%s-%s", property, current_item.text) end
    if in_dashy_group(property) then return get_3_separator_class(axis, property, current_item) end
    return string.format("%s%s-%s", property, axis, current_item.text)
end

-------------------------------------------- Window Functions

local general_dict = {
    { keymaps = "0", text = "", hidden = true },
    { keymaps = ",", text = "", hidden = true, arbitrary = true },
}

local prepare_popup_items = function(...)
    local tables = {}
    local last_page = 1
    local dictionaries = { ... }

    table.insert(dictionaries, general_dict)

    for _, dict in ipairs(dictionaries) do
        for _, item in ipairs(dict) do
            if item == "" then
                table.insert(tables[last_page], item)
            else
                local page = item.page or 1
                if not tables[page] then tables[page] = {} end
                table.insert(tables[page], item)
                last_page = page
            end
        end
    end
    return tables
end

local show_arbitrary_input = function(metadata, property, axis, fn)
    local input = Input:new({
        title = "Input Value",
        width = 15,
        on_change = function(result)
            local value = transformer.input_to_pms_value(result, property)

            if in_dashy_group(property) then
                if not axis or axis == "" then
                    value = string.format("%s-[%s]", property, value)
                else
                    value = string.format("%s-%s-[%s]", property, axis, value)
                end
            else
                value = string.format("%s%s-[%s]", property, axis, value)
            end

            fn({ property = property, axis = axis, value = value })
        end,
    })

    local row, col = unpack(vim.api.nvim_win_get_position(0))
    input:show(metadata, row, col)
    return true
end

local pms_callback = function(property, axis, fn, current_item, metadata)
    if current_item.absolute ~= "next-page" then
        if current_item.arbitrary == true then
            return show_arbitrary_input(metadata, property, axis, fn)
        else
            fn({
                property = property,
                axis = axis,
                value = format_class(property, axis, current_item),
            })
        end

        return true
    end
end

M._menu = function(property, axis, fn, ...)
    menu_repeater.register(M._menu, property, axis, fn, ...)

    local item_tables = prepare_popup_items(...)

    local popup = PopUp:new({
        steps = {
            {
                items = item_tables[1],
                format_fn = function(_, current_item)
                    return format_class(property, axis, current_item)
                end,
                callback = function(_, current_item, metadata)
                    return pms_callback(property, axis, fn, current_item, metadata)
                end,
            },
            {
                items = item_tables[2],
                format_fn = function(_, current_item)
                    return format_class(property, axis, current_item)
                end,
                callback = function(_, current_item, metadata)
                    return pms_callback(property, axis, fn, current_item, metadata)
                end,
            },
        },
    })

    popup:show()
end

-------------------------------------------- Menus

-- PMS
local pms_dict = {
    { keymaps = "1", text = "1", hidden = true },
    { keymaps = "2", text = "2", hidden = true },
    { keymaps = "3", text = "3", hidden = true },
    { keymaps = "4", text = "4", hidden = true },
    { keymaps = "5", text = "5", hidden = true },
    { keymaps = "6", text = "6", hidden = true },
    { keymaps = "7", text = "7", hidden = true },
    { keymaps = "8", text = "8", hidden = true },
    { keymaps = "9", text = "9", hidden = true },

    { keymaps = "w", text = "10" },
    { keymaps = "e", text = "11" },
    { keymaps = "r", text = "12" },
    { keymaps = "t", text = "14" },
    "",
    { keymaps = "y", text = "16" },
    { keymaps = "u", text = "20" },
    { keymaps = "i", text = "24" },
    { keymaps = "o", text = "28" },
    { keymaps = "p", text = "32" },
    "",
    { keymaps = "a", text = "36" },
    { keymaps = "s", text = "40" },
    { keymaps = "d", text = "44" },
    { keymaps = "f", text = "48" },
    { keymaps = "g", text = "52" },
    "",
    { keymaps = "z", text = "56" },
    { keymaps = "x", text = "60" },
    { keymaps = "c", text = "64" },
    { keymaps = "v", text = "72" },
    { keymaps = "b", text = "80" },
    { keymaps = "n", text = "96" },
    { keymaps = "/", text = "0" },
    "",
    { keymaps = ")", text = "0.5" },
    { keymaps = "!", text = "1.5" },
    { keymaps = "@", text = "2.5" },
    { keymaps = "#", text = "3.5" },
}
M.change_padding = function(o) M._menu("p", o.axis, tcm.change_padding, pms_dict) end
M.change_margin = function(o) M._menu("m", o.axis, tcm.change_margin, pms_dict) end
M.change_spacing = function(o) M._menu("space", o.axis, tcm.change_spacing, pms_dict) end

-- Border Width
local border_width_dict = {
    { keymaps = { "j", "2" }, text = "2" },
    { keymaps = { "k", "4" }, text = "4" },
    { keymaps = { "l", "8" }, text = "8" },
    { keymaps = { "/" }, text = "0" },
}
M.change_border = function(o)
    M._menu("border", o.axis, tcm._change_tailwind_classes, border_width_dict)
end

-- Opacity
local opacity_dict = {
    { keymaps = { "/" }, text = "0" },
    { keymaps = { "~" }, text = "5" },
    { keymaps = { "m", "1" }, text = "10" },
    { keymaps = { ",", "2" }, text = "20" },
    { keymaps = { "@" }, text = "25" },
    { keymaps = { ".", "3" }, text = "30" },
    { keymaps = { "j", "4" }, text = "40" },
    { keymaps = { "k", "5" }, text = "50" },
    { keymaps = { "l", "6" }, text = "60" },
    { keymaps = { "u", "7" }, text = "70" },
    { keymaps = { "&" }, text = "75" },
    { keymaps = { "i", "8" }, text = "80" },
    { keymaps = { "o", "9" }, text = "90" },
    { keymaps = { "(" }, text = "95" },
    { keymaps = { ")", ";" }, text = "100" },
}
M.change_opacity = function() M._menu("opacity", false, tcm._change_tailwind_classes, opacity_dict) end
M.change_border_opacity = function()
    M._menu("border-opacity", false, tcm._change_tailwind_classes, opacity_dict)
end
M.change_divide_opacity = function()
    M._menu("divide-opacity", false, tcm._change_tailwind_classes, opacity_dict)
end
M.change_ring_opacity = function()
    M._menu("ring-opacity", false, tcm._change_tailwind_classes, opacity_dict)
end

-- Font Size
local font_size_dict = {
    { keymaps = { "x" }, text = "xs" },
    { keymaps = { "m" }, text = "sm" },
    { keymaps = { "b" }, text = "base" },
    { keymaps = { "l" }, text = "lg" },
    { keymaps = { "q", "1" }, text = "xl" },
    { keymaps = { "w", "2" }, text = "2xl" },
    { keymaps = { "e", "3" }, text = "3xl" },
    { keymaps = { "r", "4" }, text = "4xl" },
    { keymaps = { "t", "5" }, text = "5xl" },
    { keymaps = { "a", "6" }, text = "6xl" },
    { keymaps = { "s", "7" }, text = "7xl" },
    { keymaps = { "d", "8" }, text = "8xl" },
    { keymaps = { "f", "9" }, text = "9xl" },
}
M.change_font_size = function() M._menu("text", false, tcm._change_tailwind_classes, font_size_dict) end

-- Divide
local divide_dict = {
    { keymaps = { "m" }, text = "0" },
    { keymaps = { "2" }, text = "2" },
    { keymaps = { "4" }, text = "4" },
    { keymaps = { "8" }, text = "8" },
    { keymaps = { "r" }, text = "reverse" },
}

local divide_x_dict = { { keymaps = { "x" }, text = "", absolute = "divide-x" } }
M.change_divide_x = function(o)
    M._menu("divide", o.axis, tcm._change_tailwind_classes, divide_x_dict, divide_dict)
end

local divide_y_dict = { { keymaps = { "y" }, text = "", absolute = "divide-y" } }
M.change_divide_y = function(o)
    M._menu("divide", o.axis, tcm._change_tailwind_classes, divide_y_dict, divide_dict)
end

-- Ring
local ring_dict = {
    { keymaps = { "m" }, text = "0" },
    { keymaps = { "1" }, text = "1" },
    { keymaps = { "2" }, text = "2" },
    { keymaps = { "4" }, text = "4" },
    { keymaps = { "8" }, text = "8" },
}
local ring_width_dict = {
    { keymaps = { "r" }, text = "", absolute = "ring" },
    { keymaps = { "i" }, text = "inset" },
}
M.change_ring_wdith = function()
    M._menu("ring", false, tcm._change_tailwind_classes, ring_width_dict, ring_dict)
end

M.change_ring_offset = function()
    M._menu("ring-offset", false, tcm._change_tailwind_classes, ring_dict)
end

-- Width / Height

local width_height_dict = {
    "",
    { keymaps = { "A" }, text = "auto" },
    { keymaps = { "F" }, text = "full" },
    { keymaps = { "S" }, text = "screen" },
    { keymaps = { "m" }, text = "min" },
    { keymaps = { "M" }, text = "max" },

    "",
    { keymaps = { "l" }, text = "", absolute = "next-page" },

    { page = 2, keymaps = { "q" }, text = "1/2" },
    { page = 2, keymaps = { "w" }, text = "1/3" },
    { page = 2, keymaps = { "e" }, text = "1/4" },
    { page = 2, keymaps = { "r" }, text = "1/5" },
    { page = 2, keymaps = { "t" }, text = "1/6" },
    "",
    { page = 2, keymaps = { "u" }, text = "2/3" },
    { page = 2, keymaps = { "i" }, text = "2/4" },
    { page = 2, keymaps = { "o" }, text = "2/5" },
    { page = 2, keymaps = { "p" }, text = "2/6" },
    "",
    { page = 2, keymaps = { "s" }, text = "3/4" },
    { page = 2, keymaps = { "d" }, text = "3/5" },
    { page = 2, keymaps = { "f" }, text = "3/6" },
    "",
    { page = 2, keymaps = { "x" }, text = "4/5" },
    { page = 2, keymaps = { "c" }, text = "4/6" },
    { page = 2, keymaps = { "v" }, text = "5/6" },
    "",
    { page = 2, keymaps = { "Q" }, text = "1/12" },
    { page = 2, keymaps = { "W" }, text = "2/12" },
    { page = 2, keymaps = { "E" }, text = "3/12" },
    { page = 2, keymaps = { "R" }, text = "4/12" },
    { page = 2, keymaps = { "T" }, text = "5/12" },
    "",
    { page = 2, keymaps = { "U" }, text = "6/12" },
    { page = 2, keymaps = { "I" }, text = "7/12" },
    { page = 2, keymaps = { "O" }, text = "8/12" },
    { page = 2, keymaps = { "O" }, text = "9/12" },
    { page = 2, keymaps = { "J" }, text = "10/12" },
    { page = 2, keymaps = { "K" }, text = "11/12" },
}

M.change_width = function()
    M._menu("w", false, tcm._change_tailwind_classes, pms_dict, width_height_dict)
end
M.change_height = function()
    M._menu("h", false, tcm._change_tailwind_classes, pms_dict, width_height_dict)
end

-- min Width / min Height

local min_width_dict = {
    { keymaps = { "/" }, text = "0" },
    { keymaps = { "f" }, text = "full" },
    { keymaps = { "m" }, text = "min" },
    { keymaps = { "x" }, text = "max" },
}
M.change_min_width = function()
    M._menu("min-w", false, tcm._change_tailwind_classes, min_width_dict)
end

local min_height_dict = {
    { keymaps = { "/" }, text = "0" },
    { keymaps = { "f" }, text = "full" },
    { keymaps = { "s" }, text = "screen" },
}
M.change_min_height = function()
    M._menu("min-h", false, tcm._change_tailwind_classes, min_height_dict)
end

-- Max Width / Max Height

local max_width_dict = {
    { keymaps = { "/" }, text = "0" },
    { keymaps = { "n" }, text = "none" },
    "",
    { keymaps = { "x" }, text = "xs" },
    { keymaps = { "s" }, text = "sm" },
    { keymaps = { "l" }, text = "lg" },
    "",
    { keymaps = { "1" }, text = "xl" },
    { keymaps = { "2" }, text = "2xl" },
    { keymaps = { "3" }, text = "3xl" },
    { keymaps = { "4" }, text = "4xl" },
    { keymaps = { "5" }, text = "5xl" },
    { keymaps = { "6" }, text = "6xl" },
    { keymaps = { "7" }, text = "7xl" },
    { keymaps = { "8" }, text = "8xl" },
    { keymaps = { "9" }, text = "9xl" },
    "",
    { keymaps = { "f" }, text = "full" },
    { keymaps = { "m" }, text = "min" },
    { keymaps = { "x" }, text = "max" },
    { keymaps = { "p" }, text = "prose" },
    "",
    { keymaps = { "ss" }, text = "screen-sm" },
    { keymaps = { "sm" }, text = "screen-md" },
    { keymaps = { "sl" }, text = "screen-lg" },
    { keymaps = { "s1" }, text = "screen-xl" },
    { keymaps = { "s2" }, text = "screen-2xl" },
}
M.change_max_width = function()
    M._menu("max-w", false, tcm._change_tailwind_classes, max_width_dict)
end

return M

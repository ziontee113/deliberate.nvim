local PopUp = require("deliberate.lib.ui.PopUp")
local Input = require("deliberate.lib.ui.Input")
local tcm = require("deliberate.api.tailwind_class_modifier")
local transformer = require("deliberate.lib.arbitrary_transformer")
local menu_repeater = require("deliberate.api.menu_repeater")
local lua_patterns = require("deliberate.lib.lua_patterns")

local M = {}

-------------------------------------------- Format Function

local non_dashy_group = { "p", "m" }
local in_non_dashy_group = function(property) return vim.tbl_contains(non_dashy_group, property) end

local format_class = function(property, axis, current_item)
    if current_item.text == "" then
        if current_item.property_and_axis then
            if axis == "" then
                return property
            else
                return string.format("%s-%s", property, axis)
            end
        elseif current_item.absolute then
            return current_item.absolute
        else
            return ""
        end
    end

    if not axis or axis == "" then return string.format("%s-%s", property, current_item.text) end

    if in_non_dashy_group(property) then
        return string.format("%s%s-%s", property, axis, current_item.text)
    else
        return string.format("%s-%s-%s", property, axis, current_item.text)
    end
end

local format_and_negatize_class = function(property, axis, current_item)
    local class = format_class(property, axis, current_item)
    if current_item.negative and not current_item.ironclad then class = "-" .. class end
    return class
end

-------------------------------------------- Window Functions

local general_dict = {
    { keymaps = "0", text = "", hidden = true, ironclad = true },
    { keymaps = ",", text = "", hidden = true, arbitrary = true, ironclad = true },
}

local prepare_popup_items = function(dictionaries)
    local tables = {}
    local last_page = 1

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

local show_arbitrary_input = function(metadata, property, axis, fn, negatives)
    local input = Input:new({
        title = "Input Value",
        width = 15,
        on_change = function(result)
            local value = transformer.input_to_pms_value(result, property)

            if in_non_dashy_group(property) then
                value = string.format("%s%s-[%s]", property, axis, value)
            else
                if not axis or axis == "" then
                    value = string.format("%s-[%s]", property, value)
                else
                    value = string.format("%s-%s-[%s]", property, axis, value)
                end
            end

            fn({
                property = property,
                axis = axis,
                value = value,
                negative_patterns = negatives,
            })
        end,
    })

    local row, col = unpack(vim.api.nvim_win_get_position(0))
    input:show(metadata, row, col)
end

local negatize_items = function(metadata)
    local updated_items = {}
    for _, item in ipairs(metadata.current_step_items) do
        if type(item) == "table" then
            if not item.negative then
                item.negative = true
            else
                item.negative = false
            end
        end
        table.insert(updated_items, item)
    end
    return updated_items
end

local pms_callback = function(property, axis, fn, current_item, metadata, negatives)
    if current_item.absolute ~= "next-page" then
        if current_item.negatize == true then
            return {
                increment_step_index_by = -1,
                updated_items = negatize_items(metadata),
            }
        elseif current_item.arbitrary == true then
            show_arbitrary_input(metadata, property, axis, fn)
            return true
        else
            fn({
                property = property,
                axis = axis,
                value = format_and_negatize_class(property, axis, current_item),
                negative_patterns = negatives,
            })
        end

        return true
    end
end

M._menu = function(property, axis, fn, dictionaries, negatives)
    menu_repeater.register(M._menu, property, axis, fn, dictionaries)

    local item_tables = prepare_popup_items(dictionaries)

    local popup = PopUp:new({
        steps = {
            {
                items = item_tables[1],
                format_fn = function(_, current_item)
                    return format_and_negatize_class(property, axis, current_item)
                end,
                callback = function(_, current_item, metadata)
                    return pms_callback(property, axis, fn, current_item, metadata, negatives)
                end,
            },
            {
                items = item_tables[2],
                format_fn = function(_, current_item)
                    return format_and_negatize_class(property, axis, current_item)
                end,
                callback = function(_, current_item, metadata)
                    return pms_callback(property, axis, fn, current_item, metadata, negatives)
                end,
            },
        },
    })

    popup:show()
end

-------------------------------------------- Padding / Margin / Spacing

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
    { keymaps = ".", text = "px" },
    { keymaps = ")", text = "0.5" },
    { keymaps = "!", text = "1.5" },
    { keymaps = "@", text = "2.5" },
    { keymaps = "#", text = "3.5" },
}
M.change_padding = function(o) M._menu("p", o.axis, tcm.change_padding, { pms_dict }) end

local negative_D = {
    { keymaps = { "-", "N" }, text = "", negatize = true, hidden = true },
}
local margin_D = { { keymaps = "A", text = "auto", ironclad = true } }
M.change_margin = function(o)
    M._menu("m", o.axis, tcm.change_margin, { pms_dict, margin_D, negative_D })
end

local spacing_D = { { keymaps = "R", text = "reverse", ironclad = true } }
M.change_spacing = function(o)
    M._menu("space", o.axis, tcm.change_spacing, { pms_dict, spacing_D, negative_D })
end

-------------------------------------------- Border Width

local border_width_dict = {
    { keymaps = { "j", "2" }, text = "2" },
    { keymaps = { "k", "4" }, text = "4" },
    { keymaps = { "l", "8" }, text = "8" },
    { keymaps = { "/" }, text = "0" },
}
M.change_border_width = function(o) M._menu("border", o.axis, tcm._change, { border_width_dict }) end

-------------------------------------------- Opacity

local opacity_dict = {
    { keymaps = { "/" }, text = "0" },
    { keymaps = { "?", "~" }, text = "5" },
    { keymaps = { "m", "1" }, text = "10" },
    { keymaps = { ",", "2" }, text = "20" },
    { keymaps = { "<", "@" }, text = "25" },
    { keymaps = { ".", "3" }, text = "30" },
    { keymaps = { "j", "4" }, text = "40" },
    { keymaps = { "k", "5" }, text = "50" },
    { keymaps = { "l", "6" }, text = "60" },
    { keymaps = { "u", "7" }, text = "70" },
    { keymaps = { "U", "&" }, text = "75" },
    { keymaps = { "i", "8" }, text = "80" },
    { keymaps = { "o", "9" }, text = "90" },
    { keymaps = { "O", "(" }, text = "95" },
    { keymaps = { ")", ";" }, text = "100" },
}
M.change_opacity = function() M._menu("opacity", false, tcm._change, { opacity_dict }) end
M.change_border_opacity = function() M._menu("border-opacity", false, tcm._change, { opacity_dict }) end
M.change_divide_opacity = function() M._menu("divide-opacity", false, tcm._change, { opacity_dict }) end
M.change_ring_opacity = function() M._menu("ring-opacity", false, tcm._change, { opacity_dict }) end

-------------------------------------------- Font Size

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
M.change_font_size = function() M._menu("text", false, tcm._change, { font_size_dict }) end

-------------------------------------------- Font Family

local font_family_dict = {
    { keymaps = { "s" }, text = "sans" },
    { keymaps = { "S" }, text = "serif" },
    { keymaps = { "m" }, text = "mono" },
}
M.change_font_family = function() M._menu("font", false, tcm._change, { font_family_dict }) end

-------------------------------------------- Letter Spacing

local tracking_D = {
    { keymaps = { "T" }, text = "tighter" },
    { keymaps = { "t" }, text = "tight" },
    { keymaps = { "n", "/" }, text = "normal" },
    { keymaps = { "w" }, text = "wide" },
    { keymaps = { "W" }, text = "wider" },
    { keymaps = { "S", "s" }, text = "widest" },
}
M.change_tracking = function() M._menu("tracking", false, tcm._change, { tracking_D, negative_D }) end

-------------------------------------------- Divide

local divide_dict = {
    { keymaps = { "m" }, text = "0" },
    { keymaps = { "2" }, text = "2" },
    { keymaps = { "4" }, text = "4" },
    { keymaps = { "8" }, text = "8" },
    { keymaps = { "r" }, text = "reverse" },
}

local divide_x_dict = { { keymaps = { "x" }, text = "", absolute = "divide-x" } }
local change_divide_x = function()
    M._menu("divide", "x", tcm._change, { divide_x_dict, divide_dict })
end

local divide_y_dict = { { keymaps = { "y" }, text = "", absolute = "divide-y" } }
local change_divide_y = function()
    M._menu("divide", "y", tcm._change, { divide_y_dict, divide_dict })
end

M.change_divide = function(o)
    if o.axis == "x" then
        change_divide_x()
    else
        change_divide_y()
    end
end

-------------------------------------------- Ring

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
M.change_ring_width = function() M._menu("ring", false, tcm._change, { ring_width_dict, ring_dict }) end

M.change_ring_offset = function() M._menu("ring-offset", false, tcm._change, { ring_dict }) end

-------------------------------------------- Width / Height

local percentage_dict = {
    "",
    { keymaps = { "l" }, text = "", absolute = "next-page", ironclad = true },

    { page = 2, keymaps = { "q" }, text = "1/2", ironclad = true },
    { page = 2, keymaps = { "w" }, text = "1/3", ironclad = true },
    { page = 2, keymaps = { "e" }, text = "1/4", ironclad = true },
    { page = 2, keymaps = { "r" }, text = "1/5", ironclad = true },
    { page = 2, keymaps = { "t" }, text = "1/6", ironclad = true },
    "",
    { page = 2, keymaps = { "u" }, text = "2/3", ironclad = true },
    { page = 2, keymaps = { "i" }, text = "2/4", ironclad = true },
    { page = 2, keymaps = { "o" }, text = "2/5", ironclad = true },
    { page = 2, keymaps = { "p" }, text = "2/6", ironclad = true },
    "",
    { page = 2, keymaps = { "s" }, text = "3/4", ironclad = true },
    { page = 2, keymaps = { "d" }, text = "3/5", ironclad = true },
    { page = 2, keymaps = { "f" }, text = "3/6", ironclad = true },
    "",
    { page = 2, keymaps = { "x" }, text = "4/5", ironclad = true },
    { page = 2, keymaps = { "c" }, text = "4/6", ironclad = true },
    { page = 2, keymaps = { "v" }, text = "5/6", ironclad = true },
    "",
    { page = 2, keymaps = { "Q" }, text = "1/12", ironclad = true },
    { page = 2, keymaps = { "W" }, text = "2/12", ironclad = true },
    { page = 2, keymaps = { "E" }, text = "3/12", ironclad = true },
    { page = 2, keymaps = { "R" }, text = "4/12", ironclad = true },
    { page = 2, keymaps = { "T" }, text = "5/12", ironclad = true },
    "",
    { page = 2, keymaps = { "U" }, text = "6/12", ironclad = true },
    { page = 2, keymaps = { "I" }, text = "7/12", ironclad = true },
    { page = 2, keymaps = { "O" }, text = "8/12", ironclad = true },
    { page = 2, keymaps = { "O" }, text = "9/12", ironclad = true },
    { page = 2, keymaps = { "J" }, text = "10/12", ironclad = true },
    { page = 2, keymaps = { "K" }, text = "11/12", ironclad = true },
}

local width_height_dict = {
    "",
    { keymaps = { "A" }, text = "auto" },
    { keymaps = { "F" }, text = "full" },
    { keymaps = { "S" }, text = "screen" },
    { keymaps = { "m" }, text = "min" },
    { keymaps = { "M" }, text = "max" },
    { keymaps = { "N" }, text = "fit" },
}

M.change_width = function()
    M._menu("w", false, tcm._change, { pms_dict, width_height_dict, percentage_dict })
end
M.change_height = function()
    M._menu("h", false, tcm._change, { pms_dict, width_height_dict, percentage_dict })
end

-------------------------------------------- Min Width / Min Height

local min_width_dict = {
    { keymaps = { "/" }, text = "0" },
    { keymaps = { "f" }, text = "full" },
    { keymaps = { "m" }, text = "min" },
    { keymaps = { "x" }, text = "max" },
}
M.change_min_width = function() M._menu("min-w", false, tcm._change, { min_width_dict }) end

local min_height_dict = {
    { keymaps = { "/" }, text = "0" },
    { keymaps = { "f" }, text = "full" },
    { keymaps = { "s" }, text = "screen" },
}
M.change_min_height = function() M._menu("min-h", false, tcm._change, { min_height_dict }) end

-------------------------------------------- Max Width / Max Height

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
M.change_max_width = function() M._menu("max-w", false, tcm._change, { max_width_dict }) end

local max_height_dict = {
    { keymaps = { "F" }, text = "full" },
    { keymaps = { "S" }, text = "screen" },
}
M.change_max_height = function() M._menu("max-h", false, tcm._change, { pms_dict, max_height_dict }) end

-------------------------------------------- Rounded (Border Radius)

local rounded_dict = {
    { keymaps = { "r" }, text = "", property_and_axis = true },
    "",
    { keymaps = { "s" }, text = "sm" },
    { keymaps = { "m" }, text = "md" },
    { keymaps = { "l" }, text = "lg" },
    "",
    { keymaps = { "1" }, text = "xl" },
    { keymaps = { "2" }, text = "2xl" },
    { keymaps = { "3" }, text = "3xl" },
    "",
    { keymaps = { "f" }, text = "full" },
    { keymaps = { "n" }, text = "none" },
}

M.change_border_radius = function(o) M._menu("rounded", o.axis, tcm._change, { rounded_dict }) end

-------------------------------------------- Flex

local flex_dict = {
    { keymaps = { "o", "1" }, text = "1" },
    { keymaps = { "a" }, text = "auto" },
    { keymaps = { "i" }, text = "initial" },
    { keymaps = { "n", "/" }, text = "none" },
}

M.change_flex = function() M._menu("flex", false, tcm._change, { flex_dict }) end

-------------------------------------------- Grow / Shrink (Flex Grow / Flex Shrink)

local grow_dict = {
    { keymaps = { "g" }, text = "", absolute = "grow" },
    { keymaps = { "/" }, text = "0" },
}
M.change_grow = function() M._menu("grow", false, tcm._change, { grow_dict }) end

local shrink_dict = {
    { keymaps = { "g" }, text = "", absolute = "shrink" },
    { keymaps = { "/" }, text = "0" },
}
M.change_shrink = function() M._menu("shrink", false, tcm._change, { shrink_dict }) end

-------------------------------------------- Basis (Flex Basis)

local basis_dict = {
    "",
    { keymaps = { "A" }, text = "auto" },
    { keymaps = { "F" }, text = "full" },
}
M.change_basis = function()
    M._menu("basis", false, tcm._change, { pms_dict, basis_dict, percentage_dict })
end

-------------------------------------------- Order

local one_to_twelve_dict = {
    { keymaps = { "1" }, text = "1" },
    { keymaps = { "2" }, text = "2" },
    { keymaps = { "3" }, text = "3" },
    { keymaps = { "4" }, text = "4" },
    { keymaps = { "5" }, text = "5" },
    { keymaps = { "6" }, text = "6" },
    { keymaps = { "7" }, text = "7" },
    { keymaps = { "8" }, text = "8" },
    { keymaps = { "9" }, text = "9" },
    { keymaps = { "w" }, text = "10" },
    { keymaps = { "e" }, text = "11" },
    { keymaps = { "r" }, text = "12" },
}

local order_dict = {
    "",
    { keymaps = { "f" }, text = "first" },
    { keymaps = { "l" }, text = "last" },
    { keymaps = { "n" }, text = "none" },
}
M.change_order = function() M._menu("order", false, tcm._change, { one_to_twelve_dict, order_dict }) end

-------------------------------------------- Aspect Ratio

local aspect_ratio_dict = {
    { keymaps = { "a" }, text = "auto" },
    { keymaps = { "s" }, text = "square" },
    { keymaps = { "v" }, text = "video" },
}
M.change_aspect_ratio = function()
    M._menu("aspect-ratio", false, tcm._change, { aspect_ratio_dict })
end

-------------------------------------------- Columns

local columns_dict = {
    "",
    { keymaps = { "A" }, text = "auto" },
    "",
    { keymaps = { "#" }, text = "3xs" },
    { keymaps = { "@" }, text = "2xs" },
    { keymaps = { "x" }, text = "xs" },
    { keymaps = { "s" }, text = "sm" },
    { keymaps = { "M" }, text = "md" },
    { keymaps = { "L" }, text = "lg" },
    "",
    { keymaps = { "m" }, text = "xl" },
    { keymaps = { "," }, text = "2xl" },
    { keymaps = { "." }, text = "3xl" },
    { keymaps = { "j" }, text = "4xl" },
    { keymaps = { "k" }, text = "5xl" },
    { keymaps = { "l" }, text = "6xl" },
    { keymaps = { "u" }, text = "7xl" },
}
M.change_columns = function()
    M._menu("columns", false, tcm._change, { one_to_twelve_dict, columns_dict })
end

-------------------------------------------- Top / Bottom / Left / Right

local tlbr_D = {
    { keymaps = "A", text = "auto", ironclad = true },
    { keymaps = "F", text = "full", ironclad = true },
}
local tlbr_P_D = {
    "",
    { keymaps = { "l" }, text = "", absolute = "next-page", ironclad = true },

    { page = 2, keymaps = { "q" }, text = "1/2", ironclad = true },
    { page = 2, keymaps = { "w" }, text = "1/3", ironclad = true },
    { page = 2, keymaps = { "e" }, text = "1/4", ironclad = true },
    "",
    { page = 2, keymaps = { "u" }, text = "2/3", ironclad = true },
    { page = 2, keymaps = { "i" }, text = "2/4", ironclad = true },
    "",
    { page = 2, keymaps = { "s" }, text = "3/4", ironclad = true },
}

local tlbr_x = {
    lua_patterns.left,
    lua_patterns.right,
}
local tlbr_y = {
    lua_patterns.top,
    lua_patterns.bottom,
}

M.change_top = function()
    M._menu("top", false, tcm._change, { pms_dict, tlbr_D, tlbr_P_D, negative_D }, tlbr_y)
end
M.change_bottom = function()
    M._menu("bottom", false, tcm._change, { pms_dict, tlbr_D, tlbr_P_D, negative_D }, tlbr_y)
end
M.change_left = function()
    M._menu("left", false, tcm._change, { pms_dict, tlbr_D, tlbr_P_D, negative_D }, tlbr_x)
end
M.change_right = function()
    M._menu("right", false, tcm._change, { pms_dict, tlbr_D, tlbr_P_D, negative_D }, tlbr_x)
end

-------------------------------------------- Inset / Start / End

M.change_inset = function(o)
    M._menu("inset", o.axis, tcm._change, { pms_dict, tlbr_D, tlbr_P_D, negative_D })
end
M.change_inset_start = function()
    M._menu("start", false, tcm._change, { pms_dict, tlbr_D, tlbr_P_D, negative_D })
end
M.change_inset_end = function()
    M._menu("end", false, tcm._change, { pms_dict, tlbr_D, tlbr_P_D, negative_D })
end

-------------------------------------------- Z-Index

local z_index_D = {
    { keymaps = { "/", "n", "z", "N" }, text = "0", ironclad = true },
    { keymaps = { "j", "1" }, text = "10" },
    { keymaps = { "k", "2" }, text = "20" },
    { keymaps = { "l", "3" }, text = "30" },
    { keymaps = { "u", "4" }, text = "40" },
    { keymaps = { "i", "o", "5" }, text = "50" },
    { keymaps = { "a", "A" }, text = "auto", ironclad = true },
}
M.change_z_index = function() M._menu("z", false, tcm._change, { z_index_D, negative_D }) end

-------------------------------------------- Grid Template Columns

local grid12_D = {
    { keymaps = { "j", "1" }, text = "1" },
    { keymaps = { "k", "2" }, text = "2" },
    { keymaps = { "l", "3" }, text = "3" },
    { keymaps = { "u", "4" }, text = "4" },
    { keymaps = { "i", "5" }, text = "5" },
    { keymaps = { "o", "6" }, text = "6" },
    { keymaps = { "7" }, text = "7" },
    { keymaps = { "8" }, text = "8" },
    { keymaps = { "9" }, text = "9" },
    { keymaps = { "w", "a" }, text = "10" },
    { keymaps = { "e", "s" }, text = "11" },
    { keymaps = { "r", "d" }, text = "12" },
}
local grid_none_D = { { keymaps = { "/", "n", "N" }, text = "none" } }

M.change_grid_cols = function() M._menu("grid-cols", false, tcm._change, { grid12_D, grid_none_D }) end

-------------------------------------------- Grid Column Start / End

local grid_full_D = { { keymaps = { "f", "F" }, text = "full" } }
local grid_auto_D = { { keymaps = { "a", "A" }, text = "auto" } }

M.change_col_span = function()
    M._menu("col-span", false, tcm._change, { grid12_D, grid_full_D, grid_auto_D })
end
M.change_col_start = function() M._menu("col-start", false, tcm._change, { grid12_D, grid_auto_D }) end
M.change_col_end = function() M._menu("col-end", false, tcm._change, { grid12_D, grid_auto_D }) end

-------------------------------------------- Grid Template Rows

local grid6_D = {
    { keymaps = { "j", "1" }, text = "1" },
    { keymaps = { "k", "2" }, text = "2" },
    { keymaps = { "l", "3" }, text = "3" },
    { keymaps = { "u", "4" }, text = "4" },
    { keymaps = { "i", "5" }, text = "5" },
    { keymaps = { "o", "6" }, text = "6" },
}
M.change_grid_rows = function() M._menu("grid-rows", false, tcm._change, { grid6_D, grid_none_D }) end

-------------------------------------------- Grid Row Start / End

M.change_row_span = function()
    M._menu("row-span", false, tcm._change, { grid12_D, grid_full_D, grid_auto_D })
end
M.change_row_start = function() M._menu("row-start", false, tcm._change, { grid12_D, grid_auto_D }) end
M.change_row_end = function() M._menu("row-end", false, tcm._change, { grid12_D, grid_auto_D }) end

-------------------------------------------- Grid Auto Rows / Columns

local auto_rows_cols_D = {
    { keymaps = { "a", "A" }, text = "auto" },
    { keymaps = { "m" }, text = "min" },
    { keymaps = { "M" }, text = "max" },
    { keymaps = { "f" }, text = "fr" },
}
M.change_auto_rows = function() M._menu("auto-rows", false, tcm._change, { auto_rows_cols_D }) end
M.change_auto_cols = function() M._menu("auto-cols", false, tcm._change, { auto_rows_cols_D }) end

-------------------------------------------- Gap

M.change_gap = function(o) M._menu("gap", o.axis, tcm._change, { pms_dict }) end

return M

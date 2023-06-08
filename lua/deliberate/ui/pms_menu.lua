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

local dashy_group = { "border", "space", "border-opacity", "divide-opacity", "ring-opacity" }
local in_dashy_group = function(property) return vim.tbl_contains(dashy_group, property) end

local format_class = function(property, axis, current_item)
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
    local items_tbl, dictionaries = {}, { ... }
    table.insert(dictionaries, general_dict)
    for _, dict in ipairs(dictionaries) do
        for _, item in ipairs(dict) do
            table.insert(items_tbl, item)
        end
    end
    return items_tbl
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
end

M._menu = function(property, axis, fn, ...)
    menu_repeater.register(M._menu, property, axis, fn, ...)

    local popup = PopUp:new({
        steps = {
            {
                items = prepare_popup_items(...),
                format_fn = function(_, current_item)
                    return format_class(property, axis, current_item)
                end,
                callback = function(_, current_item, metadata)
                    if current_item.arbitrary == true then
                        return show_arbitrary_input(metadata, property, axis, fn)
                    else
                        fn({
                            property = property,
                            axis = axis,
                            value = format_class(property, axis, current_item),
                        })
                    end
                end,
            },
        },
    })

    popup:show()
end

-------------------------------------------- Menus

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

local border_width_dict = {
    { keymaps = { "j", "2" }, text = "2" },
    { keymaps = { "k", "4" }, text = "4" },
    { keymaps = { "l", "8" }, text = "8" },
    { keymaps = { "/" }, text = "0" },
}
M.change_border = function(o)
    M._menu("border", o.axis, tcm._change_tailwind_classes, border_width_dict)
end

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

return M

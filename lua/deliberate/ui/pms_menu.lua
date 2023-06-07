local PopUp = require("deliberate.lib.ui.PopUp")
local Input = require("deliberate.lib.ui.Input")
local tcm = require("deliberate.api.tailwind_class_modifier")
local transformer = require("deliberate.lib.arbitrary_transformer")
local menu_repeater = require("deliberate.api.menu_repeater")

local M = {}

-------------------------------------------- Dictionaries

local pms_dict = {
    { keymaps = "0", text = "", hidden = true },
    { keymaps = "1", text = "1", hidden = true },
    { keymaps = "2", text = "2", hidden = true },
    { keymaps = "3", text = "3", hidden = true },
    { keymaps = "4", text = "4", hidden = true },
    { keymaps = "5", text = "5", hidden = true },
    { keymaps = "6", text = "6", hidden = true },
    { keymaps = "7", text = "7", hidden = true },
    { keymaps = "8", text = "8", hidden = true },
    { keymaps = "9", text = "9", hidden = true },
    -- "",
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
    { keymaps = "m", text = "0" },

    { keymaps = ")", text = "0.5", hidden = true },
    { keymaps = "!", text = "1.5", hidden = true },
    { keymaps = "@", text = "2.5", hidden = true },
    { keymaps = "#", text = "3.5", hidden = true },

    { keymaps = ",", text = "", hidden = true, arbitrary = true },
}

local border_width_dict = {
    { keymaps = "0", text = "", hidden = true },
    { keymaps = ",", text = "", hidden = true, arbitrary = true },

    { keymaps = { "j", "2" }, text = "2" },
    { keymaps = { "k", "4" }, text = "4" },
    { keymaps = { "l", "8" }, text = "8" },
    { keymaps = { "m" }, text = "0" },
}

-------------------------------------------- Format Functions

local get_3_separator_class = function(axis, property, current_item)
    if axis == "" then return string.format("%s-%s", property, current_item.text) end
    return string.format("%s-%s-%s", property, axis, current_item.text)
end

local format_class = function(property, axis, current_item)
    if current_item.text == "" then return "" end
    if property == "border" or property == "space" then
        return get_3_separator_class(axis, property, current_item)
    end
    return string.format("%s%s-%s", property, axis, current_item.text)
end

-------------------------------------------- Window Functions

local show_arbitrary_input = function(metadata, property, axis, fn)
    local input = Input:new({
        title = "Input Value",
        width = 15,
        on_change = function(result)
            local value = transformer.input_to_pms_value(result)
            value = string.format("%s%s-[%s]", property, axis, value)
            fn({ axis = axis, value = value })
        end,
    })

    local row, col = unpack(vim.api.nvim_win_get_position(0))
    input:show(metadata, row, col)
end

M._menu = function(property, axis, fn, items)
    menu_repeater.register(M._menu, property, axis, fn, items)

    local popup = PopUp:new({
        steps = {
            {
                items = items,
                format_fn = function(_, current_item)
                    return format_class(property, axis, current_item)
                end,
                callback = function(_, current_item, metadata)
                    if current_item.arbitrary == true then
                        return show_arbitrary_input(metadata, property, axis, fn)
                    else
                        fn({ axis = axis, value = format_class(property, axis, current_item) })
                    end
                end,
            },
        },
    })

    popup:show()
end

-------------------------------------------- Public Methods

M.change_padding = function(o) M._menu("p", o.axis, tcm.change_padding, pms_dict) end
M.change_margin = function(o) M._menu("m", o.axis, tcm.change_margin, pms_dict) end
M.change_spacing = function(o) M._menu("space", o.axis, tcm.change_spacing, pms_dict) end
M.change_border = function(o) M._menu("border", o.axis, tcm.change_border, border_width_dict) end

return M

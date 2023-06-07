local PopUp = require("deliberate.lib.ui.PopUp")
local Input = require("deliberate.lib.ui.Input")
local tcm = require("deliberate.api.tailwind_class_modifier")
local transformer = require("deliberate.lib.arbitrary_transformer")

local M = {}

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
    { keymaps = "2", text = "2", hidden = true },
    { keymaps = "4", text = "4", hidden = true },
    { keymaps = "8", text = "8", hidden = true },

    { keymaps = { "j" }, text = "2" },
    { keymaps = { "k" }, text = "4" },
    { keymaps = { "l" }, text = "8" },
    { keymaps = { "m" }, text = "0" },
}

local show_arbitrary_input = function(metadata, property, axis, fn)
    local input = Input:new({
        title = "Input Value",
        width = 15,
        callback = function(result)
            local value = transformer.input_to_pms_value(result)
            value = string.format("%s%s-[%s]", property, axis, value)
            fn({ axis = axis, value = value })
        end,
    })

    local row, col = unpack(vim.api.nvim_win_get_position(0))
    input:show(metadata, row, col)
end

local get_border_class = function(axis, property, current_item)
    if axis == "" then
        return string.format("%s-%s", property, current_item.text)
    else
        return string.format("%s-%s-%s", property, axis, current_item.text)
    end
end

---@class pms_menu_Opts
---@field axis "" | "x" | "y" | "l" | "r" | "t" | "b"

local change_pms = function(property, axis, fn, items)
    local popup = PopUp:new({
        steps = {
            {
                items = items,
                format_fn = function(_, current_item)
                    if property == "border" then
                        return get_border_class(axis, property, current_item)
                    else
                        return string.format("%s%s-%s", property, axis, current_item.text)
                    end
                end,
                callback = function(_, current_item, metadata)
                    if current_item.arbitrary == true then
                        show_arbitrary_input(metadata, property, axis, fn)
                        return
                    else
                        local value = ""
                        if current_item.text ~= "" then
                            if property == "border" then
                                value = get_border_class(axis, property, current_item)
                            else
                                value = string.format("%s%s-%s", property, axis, current_item.text)
                            end
                        end
                        fn({ axis = axis, value = value })
                    end
                end,
            },
        },
    })

    popup:show()
end

---@param o pms_menu_Opts
M.change_padding = function(o) change_pms("p", o.axis, tcm.change_padding, pms_dict) end

---@param o pms_menu_Opts
M.change_margin = function(o) change_pms("m", o.axis, tcm.change_margin, pms_dict) end

---@param o pms_menu_Opts
M.change_spacing = function(o) change_pms("s", o.axis, tcm.change_spacing, pms_dict) end

---@param o pms_menu_Opts
M.change_border = function(o) change_pms("border", o.axis, tcm.change_border, border_width_dict) end

return M

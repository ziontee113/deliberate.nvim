local PopUp = require("stormcaller.lib.ui.PopUp")
local tcm = require("stormcaller.api.tailwind_class_modifier")

local M = {}

local key_value_dictionary = {
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
}

---@class pms_menu_Opts
---@field axis "" | "x" | "y" | "l" | "r" | "t" | "b"

local change_pms = function(property, axis, fn)
    local popup = PopUp:new({
        steps = {
            {
                items = key_value_dictionary,
                format_fn = function(_, current_item)
                    return string.format("%s%s-%s", property, axis, current_item.text)
                end,
                callback = function(results)
                    local value = ""
                    if results[1] ~= "" then
                        value = string.format("%s%s-%s", property, axis, results[1])
                    end
                    fn({ axis = axis, value = value })
                end,
            },
        },
    })

    popup:show()
end

---@param o pms_menu_Opts
M.change_padding = function(o) change_pms("p", o.axis, tcm.change_padding) end

---@param o pms_menu_Opts
M.change_margin = function(o) change_pms("m", o.axis, tcm.change_margin) end

---@param o pms_menu_Opts
M.change_spacing = function(o) change_pms("s", o.axis, tcm.change_spacing) end

return M

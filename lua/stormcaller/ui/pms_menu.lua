local PopUp = require("stormcaller.lib.ui.PopUp")
local tcm = require("stormcaller.api.tailwind_class_modifier")

local M = {}

local key_value_dictionary = {
    { keymaps = "0", text = "", hide = true },
    { keymaps = "1", text = "1", hide = true },
    { keymaps = "2", text = "2", hide = true },
    { keymaps = "3", text = "3", hide = true },
    { keymaps = "4", text = "4", hide = true },
    { keymaps = "5", text = "5", hide = true },
    { keymaps = "6", text = "6", hide = true },
    { keymaps = "7", text = "7", hide = true },
    { keymaps = "8", text = "8", hide = true },
    { keymaps = "9", text = "9", hide = true },
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

    { keymaps = ")", text = "0.5", hide = true },
    { keymaps = "!", text = "1.5", hide = true },
    { keymaps = "@", text = "2.5", hide = true },
    { keymaps = "#", text = "3.5", hide = true },
}

local popup_format_fn
local popup_callback

local popup = PopUp:new({
    steps = {
        {
            items = key_value_dictionary,
            format_fn = popup_format_fn,
            callback = popup_callback,
        },
    },
})

M.change_padding = function()
    -- TODO:
end

return M

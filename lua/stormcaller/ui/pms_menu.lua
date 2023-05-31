local tcm = require("stormcaller.api.tailwind_class_modifier")

local M = {}

local dict = {
    { key = "0", value = "", hide = true },
    { key = "1", value = "1", hide = true },
    { key = "2", value = "2", hide = true },
    { key = "3", value = "3", hide = true },
    { key = "4", value = "4", hide = true },
    { key = "5", value = "5", hide = true },
    { key = "6", value = "6", hide = true },
    { key = "7", value = "7", hide = true },
    { key = "8", value = "8", hide = true },
    { key = "9", value = "9", hide = true },
    -- "",
    { key = "w", value = "10" },
    { key = "e", value = "11" },
    { key = "r", value = "12" },
    { key = "t", value = "14" },
    "",
    { key = "y", value = "16" },
    { key = "u", value = "20" },
    { key = "i", value = "24" },
    { key = "o", value = "28" },
    { key = "p", value = "32" },
    "",
    { key = "a", value = "36" },
    { key = "s", value = "40" },
    { key = "d", value = "44" },
    { key = "f", value = "48" },
    { key = "g", value = "52" },
    "",
    { key = "z", value = "56" },
    { key = "x", value = "60" },
    { key = "c", value = "64" },
    { key = "v", value = "72" },
    { key = "b", value = "80" },
    { key = "n", value = "96" },
    { key = "m", value = "0" },

    { key = ")", value = "0.5", hide = true },
    { key = "!", value = "1.5", hide = true },
    { key = "@", value = "2.5", hide = true },
    { key = "#", value = "3.5", hide = true },
}

M.change_padding = function()
    -- TODO:
end

return M

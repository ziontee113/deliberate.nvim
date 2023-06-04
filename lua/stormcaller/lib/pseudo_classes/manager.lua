local M = {}

local current_pseudo_classes = ""

M.update = function(input)
    current_pseudo_classes =
        require("stormcaller.lib.pseudo_classes.mixer").translate_alias_string(input)
end

M.get_current = function() return current_pseudo_classes end

return M

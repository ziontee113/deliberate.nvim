local M = {}

local current_pseudo_classes = ""

M.update = function(content) current_pseudo_classes = content end
M.get_current = function() return current_pseudo_classes end

return M

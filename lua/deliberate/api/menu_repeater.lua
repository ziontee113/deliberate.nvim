local M = {}

local latest_menu, latest_args

M.register = function(fn, ...)
    latest_menu = fn
    latest_args = { ... }
end

M.call = function() latest_menu(unpack(latest_args)) end

return M

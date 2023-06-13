local M = {}

local latest_fn, latest_args

M.register = function(fn, ...)
    latest_fn = fn
    latest_args = { ... }
end

M.call = function()
    if not latest_fn and not latest_args then return end
    latest_fn(unpack(latest_args))
end

return M

local M = {}

local latest_fn, latest_args

M.register = function(fn, args)
    latest_fn = fn
    latest_args = args
end

M.call = function() latest_fn(latest_args) end

return M

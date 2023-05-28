local M = {}

M.get_count = function()
    local count = vim.v.count
    if count < 1 then count = 1 end
    return count
end

M.reset_count = function() vim.cmd("norm! ") end

M.execute_with_count = function(fn, ...)
    local count = M.get_count()
    for _ = 1, count do
        fn(...)
    end
    M.reset_count()
end

return M

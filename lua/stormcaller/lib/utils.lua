local M = {}

M.get_count = function()
    local count = vim.v.count
    if count < 1 then count = 1 end
    return count
end

M.reset_count = function() vim.cmd("norm! ") end

return M

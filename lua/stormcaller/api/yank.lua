local selection = require("stormcaller.lib.selection")

local M = {}

---@type string[][]
local contents = {}

M.call = function()
    contents = {}
    for _, item in ipairs(selection.items()) do
        local start_row, _, end_row, _ = item.node:range()
        local lines = vim.api.nvim_buf_get_lines(item.buf, start_row, end_row + 1, false)
        table.insert(contents, lines)
    end
end

M.contents = function() return contents end

return M

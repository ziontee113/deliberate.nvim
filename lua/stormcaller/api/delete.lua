local M = {}

local catalyst = require("stormcaller.lib.catalyst")
local selection = require("stormcaller.lib.selection")

M.call = function()
    vim.bo[catalyst.buf()].undolevels = vim.bo[catalyst.buf()].undolevels
    selection.archive_current_state()

    local sorted_nodes = selection.sorted_nodes()
    for i = #sorted_nodes, 1, -1 do
        local node = sorted_nodes[i]
        local start_row, _, end_row, _ = node:range()
        vim.api.nvim_buf_set_lines(catalyst.buf(), start_row, end_row + 1, false, {})
    end

    require("stormcaller.api.visual_collector").stop()
    selection.clear()
    catalyst.initiate({ win = catalyst.win(), buf = catalyst.buf() })
end

return M

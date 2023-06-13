local M = {}

local catalyst = require("deliberate.lib.catalyst")
local selection = require("deliberate.lib.selection")
local yank = require("deliberate.api.yank")

---@class delete_Args
---@field archive_state boolean

---@type delete_Args
local default_delete_opts = {
    archive_state = true,
}

---@param opts delete_Args | nil
M.call = function(opts)
    require("deliberate.api.dot_repeater").register(M.call, opts)

    opts = vim.tbl_deep_extend("force", default_delete_opts, opts or {})

    if opts.archive_state then
        vim.bo[catalyst.buf()].undolevels = vim.bo[catalyst.buf()].undolevels
        selection.archive_for_undo()
    end

    yank.call({ keep_selection = true })

    local sorted_nodes = selection.sorted_nodes()
    for i = #sorted_nodes, 1, -1 do
        local node = sorted_nodes[i]
        local start_row, _, end_row, _ = node:range()
        vim.api.nvim_buf_set_lines(catalyst.buf(), start_row, end_row + 1, false, {})
    end

    require("deliberate.api.visual_collector").stop()
    selection.clear()
    catalyst.initiate({ win = catalyst.win(), buf = catalyst.buf() })
end

return M

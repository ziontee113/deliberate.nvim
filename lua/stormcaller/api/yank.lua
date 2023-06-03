local selection = require("stormcaller.lib.selection")
local visual_collector = require("stormcaller.api.visual_collector")

local M = {}

---@type string[][]
local contents = {}

---@class yank_Opts
---@field sort_selection boolean
---@field keep_selection boolean

local default_yank_Opts = {
    sort_selection = true,
    keep_selection = false,
}

---@param opts yank_Opts | nil
M.call = function(opts)
    opts = vim.tbl_deep_extend("force", default_yank_Opts, opts)

    contents = {}
    local buf = selection.buf()
    local nodes = opts.sort_selection and selection.sorted_nodes() or selection.nodes()

    for _, node in ipairs(nodes) do
        local start_row, _, end_row, _ = node:range()
        local lines = vim.api.nvim_buf_get_lines(buf, start_row, end_row + 1, false)
        table.insert(contents, lines)
    end

    if opts.keep_selection == false then
        visual_collector.stop()
        selection.clear(true)
    end
end

M.contents = function() return contents end

return M

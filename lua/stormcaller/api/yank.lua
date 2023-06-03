local selection = require("stormcaller.lib.selection")
local visual_collector = require("stormcaller.api.visual_collector")

local M = {}

---@type string[][]
local contents = {}

---@class yank_Args
---@field keep_selection boolean

---@param opts yank_Args | nil
M.call = function(opts)
    contents = {}
    for _, item in ipairs(selection.items()) do
        local start_row, _, end_row, _ = item.node:range()
        local lines = vim.api.nvim_buf_get_lines(item.buf, start_row, end_row + 1, false)
        table.insert(contents, lines)
    end

    opts = opts or {}
    opts.keep_selection = opts.keep_selection or false

    if opts.keep_selection == false then
        visual_collector.stop()
        selection.clear(true)
    end
end

M.contents = function() return contents end

return M

local M = {}

local catalyst = require("stormcaller.lib.catalyst")
local navigator = require("stormcaller.lib.navigator")
local lib_ts = require("stormcaller.lib.tree-sitter")
local lib_ts_tsx = require("stormcaller.lib.tree-sitter.tsx")

local find_indents = function(buf, node)
    local start_row = node:range()
    local first_line = vim.api.nvim_buf_get_lines(buf, start_row, start_row + 1, false)[1]
    return string.match(first_line, "^%s+")
end

M.add = function(tag)
    for i = 1, #catalyst.selected_nodes() do
        local node = catalyst.selected_nodes()[i]

        local _, _, end_row = node:range()

        local placeholder = "###"
        local indents = find_indents(catalyst.buf(), catalyst.node())
        local content = string.format("%s<%s>%s</%s>", indents, tag, placeholder, tag)

        vim.api.nvim_buf_set_lines(catalyst.buf(), end_row + 1, end_row + 1, false, { content })

        catalyst.refresh_tree()
    end

    if #catalyst.selected_nodes() == 1 then navigator.move({ destination = "next" }) end
end

return M

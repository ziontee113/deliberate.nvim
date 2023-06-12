local M = {}

local catalyst = require("deliberate.lib.catalyst")
local selection = require("deliberate.lib.selection")
local utils = require("deliberate.lib.utils")
local delete = require("deliberate.api.delete")

---@class wrap_Args
---@field tag string

---@param o wrap_Args
M.call = function(o)
    vim.bo[catalyst.buf()].undolevels = vim.bo[catalyst.buf()].undolevels
    selection.archive_for_undo()

    local fi = selection.sorted_items()[1]
    local fi_start_row, fi_start_col = fi.node:range()

    local indents = utils.find_indents(fi.buf, fi.node)
    local opening_tag_line = string.format("%s<%s>", indents, o.tag)
    local closing_tag_line = string.format("%s</%s>", indents, o.tag)

    local content_lines = {}
    for _, node in ipairs(selection.sorted_nodes()) do
        local start_row, _, end_row, _ = node:range()
        local lines = vim.api.nvim_buf_get_lines(fi.buf, start_row, end_row + 1, false)
        for _, line in ipairs(lines) do
            table.insert(content_lines, line)
        end
    end

    content_lines = utils.reindent(content_lines, fi_start_col, "inside")

    table.insert(content_lines, 1, opening_tag_line)
    table.insert(content_lines, closing_tag_line)

    delete.call({ archive_state = false })

    vim.api.nvim_buf_set_lines(fi.buf, fi_start_row, fi_start_row, false, content_lines)

    selection.refresh_tree()
    selection.update_item(1, fi_start_row, fi_start_col)

    catalyst.set_node(selection.nodes()[#selection.nodes()])
    catalyst.set_node_point("start")
    catalyst.move_to(false, true)
end

return M

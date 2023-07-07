local selection = require("deliberate.lib.selection")
local aggregator = require("deliberate.lib.tree-sitter.language_aggregator")
local catalyst = require("deliberate.lib.catalyst")
local lib_ts = require("deliberate.lib.tree-sitter")

local M = {}

---@param buf number
---@param node TSNode
local function find_or_create_attribute_value_node(buf, node, attribute, content)
    local attribute_value_node = aggregator.get_attribute_value(buf, node, attribute)
    if attribute_value_node then return attribute_value_node end

    local tag_node = aggregator.get_tag_identifier_node(node)
    if not tag_node then error("Given node argument shouldn't have been nil") end
    if not content then return end

    local start_row, _, _, end_col = tag_node:range()
    local formatted_content = string.format(" %s=%s", attribute, content)
    vim.api.nvim_buf_set_text(buf, start_row, end_col, start_row, end_col, { formatted_content })

    selection.refresh_tree()
end

M.jump_to_attribute_value_node = function(attribute, col_offset)
    col_offset = col_offset or 0
    local attribute_value_node =
        aggregator.get_attribute_value(catalyst.buf(), catalyst.node(), attribute)
    if not attribute_value_node then return end
    local _, _, end_row, end_col = attribute_value_node:range()
    vim.api.nvim_win_set_cursor(catalyst.win(), { end_row + 1, end_col - 1 + col_offset })
end

---@class Attribute_Changer_Opts
---@field attribute string
---@field content string

---@param o Attribute_Changer_Opts
M.change = function(o)
    selection.archive_for_undo()
    local attribute_value_node =
        find_or_create_attribute_value_node(catalyst.buf(), catalyst.node(), o.attribute, o.content)
    if not attribute_value_node then return end

    lib_ts.replace_node_text({
        node = attribute_value_node,
        buf = catalyst.buf(),
        replacement = { o.content },
    })

    selection.refresh_tree()
end

M.remove = function(attribute)
    selection.archive_for_undo()
    require("deliberate.api.dot_repeater").register(M.remove, attribute)

    for i = 1, #selection.nodes() do
        local node = selection.nodes()[i]

        local attribute_ident_node = aggregator.get_attribute_value(catalyst.buf(), node, attribute)
        if attribute_ident_node then
            lib_ts.replace_node_text({
                buf = catalyst.buf(),
                node = attribute_ident_node:parent(),
                replacement = "",
                start_col_offset = -1,
            })
        end

        selection.refresh_tree()
    end
end

return M

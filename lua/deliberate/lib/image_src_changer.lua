local selection = require("deliberate.lib.selection")
local aggregator = require("deliberate.lib.tree-sitter.language_aggregator")
local catalyst = require("deliberate.lib.catalyst")
local lib_ts = require("deliberate.lib.tree-sitter")

local M = {}

---@param buf number
---@param node TSNode
local function set_empty_className_property_if_needed(buf, node)
    if aggregator.get_src_property_string_node(buf, node) then return end

    local tag_node = aggregator.get_tag_identifier_node(node)
    if not tag_node then error("Given node argument shouldn't have been nil") end

    local start_row, _, _, end_col = tag_node:range()
    vim.api.nvim_buf_set_text(buf, start_row, end_col, start_row, end_col, { ' src=""' })

    selection.refresh_tree()
end

M.replace = function(src)
    vim.bo[catalyst.buf()].undolevels = vim.bo[catalyst.buf()].undolevels
    selection.archive_for_undo()
    require("deliberate.api.dot_repeater").register(M.replace, src)

    for i = 1, #selection.nodes() do
        set_empty_className_property_if_needed(catalyst.buf(), selection.nodes()[i])

        local src_string_node =
            aggregator.get_src_property_string_node(catalyst.buf(), selection.nodes()[i])

        lib_ts.replace_node_text({
            node = src_string_node,
            buf = catalyst.buf(),
            replacement = { string.format('"%s"', src) },
        })

        selection.refresh_tree()
    end
end

return M

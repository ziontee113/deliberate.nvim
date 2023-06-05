local aggregator = require("deliberate.lib.tree-sitter.language_aggregator")
local selection = require("deliberate.lib.selection")

local M = {}

M.replace = function(content)
    local buf = selection.current_catalyst_info().buf
    for i = 1, #selection.sorted_nodes() do
        local node = selection.sorted_nodes()[i]

        if aggregator.node_is_component(node) then goto continue end

        local target_row, target_col = node:range()

        local opening, closing = aggregator.get_opening_and_closing_tags(node)
        local _, _, start_row, start_col = opening:range()
        local end_row, end_col = closing:range()

        print(vim.inspect({ start_row, start_col, end_row, end_col }))

        vim.api.nvim_buf_set_text(
            buf,
            start_row,
            start_col,
            end_row,
            end_col,
            vim.split(content, "\n")
        )

        selection.refresh_tree()
        selection.update_item(i, target_row, target_col)

        ::continue::
    end
end

return M

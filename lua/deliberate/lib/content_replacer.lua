local aggregator = require("deliberate.lib.tree-sitter.language_aggregator")
local selection = require("deliberate.lib.selection")

local M = {}

M.replace = function(content, disable_auto_sort)
    local buf = selection.current_catalyst_info().buf

    vim.bo[buf].undolevels = vim.bo[buf].undolevels
    selection.archive_for_undo()
    require("deliberate.api.dot_repeater").register(M.replace, content, disable_auto_sort)

    for i = 1, #selection.items() do
        local node, original_index
        if not disable_auto_sort then
            node = selection.sorted_items()[i].node
            original_index = selection.sorted_items()[i].original_index
        else
            node = selection.items()[i].node
            original_index = i
        end

        if aggregator.node_is_component(node) then goto continue end

        local target_row, target_col = node:range()

        local opening, closing = aggregator.get_opening_and_closing_tags(node)
        local _, _, start_row, start_col = opening:range()
        local end_row, end_col = closing:range()

        local html_content = content
        if type(content) == "table" then html_content = content[i] or "" end
        vim.api.nvim_buf_set_text(
            buf,
            start_row,
            start_col,
            end_row,
            end_col,
            vim.split(html_content, "\n")
        )

        selection.refresh_tree()

        selection.update_item(original_index, target_row, target_col)

        ::continue::
    end
end

return M

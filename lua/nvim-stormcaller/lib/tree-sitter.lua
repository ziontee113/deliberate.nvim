local M = {}

M.find_closest_parent_with_types = function(o)
    local node = o.node
    while node do
        if vim.tbl_contains(o.desired_parent_types, node:type()) then
            break
        end
        node = node:parent()
    end
    if node ~= o.node then
        return node
    end
end

M.put_cursor_at_start_of_node = function(o)
    local start_row, start_col = o.node:range()
    vim.api.nvim_win_set_cursor(o.win, { start_row + 1, start_col })
end

return M

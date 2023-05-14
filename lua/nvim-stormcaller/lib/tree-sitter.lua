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
M.put_cursor_at_end_of_node = function(o)
    local _, _, end_row, end_col = o.node:range()
    vim.api.nvim_win_set_cursor(o.win, { end_row + 1, end_col + 1 })
end

M.get_root = function(o)
    local parser_ok, parser = pcall(vim.treesitter.get_parser, 0, o.parser_name)
    if parser_ok then
        local trees = parser:parse()
        local root = trees[1]:root()
        return root
    end
end

M.capture_nodes_with_queries = function(o)
    local all_captures = {}
    local grouped_captures = {}
    for _, key in ipairs(o.capture_groups or {}) do
        grouped_captures[key] = {}
    end

    local root = o.root or M.get_root({ parser_name = o.parser_name, buf = o.buf })

    for _, query in ipairs(o.queries) do
        local parsed_query = vim.treesitter.query.parse(o.parser_name, query)
        for _, matches, _ in parsed_query:iter_matches(root, 0) do
            for i, node in ipairs(matches) do
                table.insert(all_captures, node)

                if o.capture_groups then
                    local capture_group_name = parsed_query.captures[i]
                    if vim.tbl_contains(o.capture_groups, capture_group_name) then
                        table.insert(grouped_captures[capture_group_name], node)
                    end
                end
            end
        end
    end

    return all_captures, grouped_captures
end

return M

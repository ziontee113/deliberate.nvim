local M = {}

---@class TSNode
---@field type function
---@field parent function
---@field range function
---@field next_named_sibling function
---@field prev_named_sibling function

---@class find_closest_parent_with_types_Opts
---@field node TSNode
---@field desired_parent_types string[]

---@param o find_closest_parent_with_types_Opts
---@return TSNode | nil
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

---@class get_node_anchors_Opts
---@field node TSNode
---@field anchors string[]

---@param o get_node_anchors_Opts
---@return number[]
M.get_node_anchors = function(o)
    local start_row, start_col, end_row, end_col = o.node:range()
    local anchors = {
        start_row = start_row,
        start_col = start_col,
        end_row = end_row,
        end_col = end_col,
    }
    local anchors_to_return = {}
    for _, key in ipairs(o.anchors) do
        table.insert(anchors_to_return, anchors[key])
    end
    return unpack(anchors_to_return)
end

---@class put_cursor_at_node_Opts
---@field node TSNode | nil
---@field win number
---@field destination "start" | "end"

---@param o put_cursor_at_node_Opts
M.put_cursor_at_node = function(o)
    if not o.node then
        return
    end

    local start_row, start_col, end_row, end_col = o.node:range()
    if o.destination == "start" then
        vim.api.nvim_win_set_cursor(o.win, { start_row + 1, start_col })
    elseif o.destination == "end" then
        vim.api.nvim_win_set_cursor(o.win, { end_row + 1, end_col + 1 })
    end
end

---@class get_root_Opts
---@field buf number
---@field parser_name string

---@param o get_root_Opts
---@return TSNode | nil
M.get_root = function(o)
    local parser_ok, parser = pcall(vim.treesitter.get_parser, o.buf, o.parser_name)
    if parser_ok then
        local trees = parser:parse()
        local root = trees[1]:root()
        return root
    end
end

---@class capture_nodes_with_queries_Opts
---@field buf number
---@field root TSNode | nil
---@field parser_name string
---@field capture_groups string[]
---@field queries string[]

---@param o capture_nodes_with_queries_Opts
---@return table, table
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

---@class find_sublings_with_types_Opts
---@field node TSNode
---@field direction "next" | "previous"
---@field desired_types string[]

---@param o find_sublings_with_types_Opts
---@return TSNode[], TSNode[]
M.find_named_siblings_in_direction_with_types = function(o)
    local directed_siblings, matched_siblings = {}, {}

    if o.direction == "next" then
        local sibling = o.node:next_named_sibling()
        while sibling do
            table.insert(directed_siblings, sibling)
            if vim.tbl_contains(o.desired_types, sibling:type()) then
                table.insert(matched_siblings, sibling)
            end
            sibling = sibling:next_named_sibling()
        end
    elseif o.direction == "previous" then
        local sibling = o.node:prev_named_sibling()
        while sibling do
            table.insert(directed_siblings, sibling)
            if vim.tbl_contains(o.desired_types, sibling:type()) then
                table.insert(matched_siblings, sibling)
            end
            sibling = sibling:prev_named_sibling()
        end
    end

    return matched_siblings, directed_siblings
end

M.node_start_and_end_on_same_line = function(node)
    local start_row, _, end_row, _ = node:range()
    return start_row == end_row
end

return M

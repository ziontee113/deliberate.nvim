local M = {}

---@class TSNode
---@field type function
---@field parent function
---@field range function
---@field next_named_sibling function
---@field prev_named_sibling function
---@field iter_children function
---@field named_descendant_for_range function
---@field named_child_count function
---@field named_child function

---@class find_closest_parent_with_types_Opts
---@field node TSNode
---@field desired_parent_types string[]

---@param o find_closest_parent_with_types_Opts
---@return TSNode | nil
M.find_closest_parent_with_types = function(o)
    local node = o.node
    while node do
        if vim.tbl_contains(o.desired_parent_types, node:type()) then break end
        node = node:parent()
    end
    return node
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
    if not o.node then return end

    local start_row, start_col, end_row, end_col = o.node:range()
    if o.destination == "start" then
        vim.api.nvim_win_set_cursor(o.win, { start_row + 1, start_col })
    elseif o.destination == "end" then
        vim.api.nvim_win_set_cursor(o.win, { end_row + 1, end_col - 1 })
    end
end

---@class get_root_Opts
---@field buf number
---@field parser_name string
---@field reset boolean

---@param o get_root_Opts
---@return TSNode | nil
M.get_root = function(o)
    local parser_ok, parser = pcall(vim.treesitter.get_parser, o.buf, o.parser_name)
    if parser_ok then
        if o.reset then parser:invalidate(true) end

        local trees = parser:parse()
        local root = trees[1]:root()
        return root
    end
end

---@param buf number
---@param node TSNode
---@param parser_name string
---@param updated_root TSNode | nil
---@return TSNode, TSNode | nil
M.reset_node_tree = function(buf, node, parser_name, updated_root)
    local start_row, start_col, end_row, end_col = node:range()

    updated_root = updated_root
        or M.get_root({ parser_name = parser_name, buf = buf, reset = true })

    node = updated_root:named_descendant_for_range(start_row, start_col, end_row, end_col)
    return node, updated_root
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

    local root
    if o.root then
        if o.root:has_changes() then
            root = M.reset_node_tree(o.buf, o.root, o.parser_name)
        else
            root = o.root
        end
    else
        root = M.get_root({ parser_name = o.parser_name, buf = o.buf })
    end

    for _, query in ipairs(o.queries) do
        local parsed_query = vim.treesitter.query.parse(o.parser_name, query)
        for _, matches, _ in parsed_query:iter_matches(root, o.buf) do
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

---@param node TSNode
---@return boolean
M.node_start_and_end_on_same_line = function(node)
    local start_row, _, end_row, _ = node:range()
    return start_row == end_row
end

---@param win number
---@param node TSNode
---@return boolean
M.cursor_is_at_start_of_node = function(win, node)
    local start_row, start_col = node:range()
    local cursor_line, cursor_col = unpack(vim.api.nvim_win_get_cursor(win))
    return start_row + 1 == cursor_line and start_col == cursor_col
end

---@param win number
---@param node TSNode
---@return boolean
M.cursor_is_at_end_of_node = function(win, node)
    local _, _, end_row, end_col = node:range()
    local cursor_line, cursor_col = unpack(vim.api.nvim_win_get_cursor(win))
    return end_row + 1 == cursor_line and end_col == cursor_col + 1
end

---@class get_children_with_types_Opts
---@field node TSNode
---@field desired_types string[]

---@param o get_children_with_types_Opts
---@return TSNode[]
M.get_children_with_types = function(o)
    local matched_children = {}
    for child in o.node:iter_children() do
        if vim.tbl_contains(o.desired_types, child:type()) then
            table.insert(matched_children, child)
        end
    end
    return matched_children
end

---@class replace_node_text_Opts
---@field node TSNode
---@field replacement string | table
---@field buf number
---@field start_row_offset number | nil
---@field start_col_offset number | nil
---@field end_row_offset number | nil
---@field end_col_offset number | nil

M.replace_node_text = function(o)
    if type(o.replacement) == "string" then o.replacement = { o.replacement } end
    local start_row, start_col, end_row, end_col = o.node:range()
    vim.api.nvim_buf_set_text(
        o.buf,
        start_row + (o.start_row_offset or 0),
        start_col + (o.start_col_offset or 0),
        end_row + (o.end_row_offset or 0),
        end_col + (o.end_col_offset or 0),
        o.replacement
    )
end

-------------------------------------------- Shared Functions between languages

---@param buf number
---@return TSNode
M.get_updated_root = function(buf, parser_name)
    local updated_root = M.get_root({ parser_name = parser_name, buf = buf, reset = true })
    if not updated_root then error("can't get updated root for tsx, something went wrong.") end
    return updated_root
end

---@param buf number
---@param node TSNode
---@return TSNode
M.get_first_closing_bracket = function(buf, node, parser_name)
    local first_bracket = M.capture_nodes_with_queries({
        root = node,
        buf = buf,
        parser_name = parser_name,
        queries = { [[ (">" @closing_bracket) ]] },
        capture_groups = { "closing_bracket" },
    })[1]

    if not first_bracket then error("given node argument is not an html_element") end
    return first_bracket
end

---@param node TSNode
---@return TSNode|nil
M.get_html_node = function(node, desired_parent_types)
    return M.find_closest_parent_with_types({
        node = node,
        desired_parent_types = desired_parent_types,
    })
end

---@param node TSNode
---@return TSNode[]
M.get_html_children = function(node, desired_types)
    return M.get_children_with_types({ node = node, desired_types = desired_types })
end

---@param node TSNode
---@param direction "previous" | "next"
---@return TSNode[], TSNode
M.get_html_siblings = function(node, direction, desired_types)
    return M.find_named_siblings_in_direction_with_types({
        node = node,
        direction = direction,
        desired_types = desired_types,
    })
end

return M

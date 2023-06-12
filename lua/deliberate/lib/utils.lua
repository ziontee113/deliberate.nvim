local M = {}

-------------------------------------------- String Related

---@param class_names string[]
---@return string[]
M.remove_empty_strings = function(class_names)
    for i = #class_names, 1, -1 do
        if class_names[i] == "" then table.remove(class_names, i) end
    end
    return class_names
end

M.pseudo_split = function(single_class)
    local lua_patterns = require("deliberate.lib.lua_patterns")
    local pseudo_prefix, style = string.match(single_class, lua_patterns.pseudo_splitter)
    if not style then
        style = single_class
        pseudo_prefix = ""
    end
    return pseudo_prefix, style
end

-------------------------------------------- String Table Related

---@param buf number
---@param node TSNode
---@return string
M.find_indents = function(buf, node)
    local start_row = node:range()
    local first_line = vim.api.nvim_buf_get_lines(buf, start_row, start_row + 1, false)[1]
    return string.match(first_line, "^%s+") or ""
end

---@param lines string[]
---@param target_start_col integer
---@return string[]
M.reindent = function(lines, target_start_col, destination)
    local shortest_indent_amount = #string.match(lines[1], "^%s+") or 0
    for _, line in ipairs(lines) do
        local this_line_indent = string.match(line, "^%s+")
        if #this_line_indent < shortest_indent_amount then
            shortest_indent_amount = #this_line_indent
        end
    end

    if destination == "inside" then
        shortest_indent_amount = shortest_indent_amount - vim.bo.tabstop
    end

    if shortest_indent_amount ~= target_start_col then
        local deficit = shortest_indent_amount - target_start_col
        if shortest_indent_amount > target_start_col then
            for i, _ in ipairs(lines) do
                lines[i] = string.sub(lines[i], deficit + 1)
            end
        else
            local spaces = string.rep(" ", math.abs(deficit))
            for i, _ in ipairs(lines) do
                lines[i] = spaces .. lines[i]
            end
        end
    end

    return lines
end

-------------------------------------------- Vim Utils

M.get_count = function()
    local count = vim.v.count
    if count < 1 then count = 1 end
    return count
end

M.reset_count = function() vim.cmd("norm! ") end

M.execute_with_count = function(fn, ...)
    local count = M.get_count()
    for _ = 1, count do
        fn(...)
    end
    M.reset_count()
end

M.feed_keys = function(input)
    local feed = vim.api.nvim_replace_termcodes(input, true, true, true)
    vim.api.nvim_feedkeys(feed, "mtix", false)
end

return M

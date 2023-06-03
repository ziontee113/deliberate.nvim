local catalyst = require("stormcaller.lib.catalyst")
local selection = require("stormcaller.lib.selection")
local yank = require("stormcaller.api.yank")

local find_row_offset = function(destination, lines)
    if destination == "previous" then return 0 end
    if #selection.nodes() == 1 then
        return 1
    else
        return #lines - 1
    end
end

local reindent = function(lines, target_start_col)
    local shortest_indent_amount = #string.match(lines[1], "^%s+") or 0
    for _, line in ipairs(lines) do
        local this_line_indent = string.match(line, "^%s+")
        if #this_line_indent < shortest_indent_amount then
            shortest_indent_amount = #this_line_indent
        end
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

---@class paste_Args
---@field destination "previous" | "next"
---@field join boolean | nil
---@field reindent boolean

---@type paste_Args
local default_paste_opts = {
    destination = "next",
    join = true,
    reindent = true,
}

---@param opts paste_Args | nil
local paste = function(opts)
    opts = vim.tbl_deep_extend("force", default_paste_opts, opts or {})

    local joined_contents = {}
    for _, yanked_lines in ipairs(yank.contents()) do
        for _, line in ipairs(yanked_lines) do
            table.insert(joined_contents, line)
        end
    end

    local should_move_to_newly_created_tag
    if #selection.nodes() == 1 and selection.item_matches_catalyst(1) then
        should_move_to_newly_created_tag = true
    end

    for i, item in ipairs(selection.items()) do
        local lines = opts.join and joined_contents or yank.contents()[i]

        local buf = item.buf
        local start_row, start_col, end_row, _ = item.node:range()

        if opts.reindent then lines = reindent(lines, start_col) end

        local target_row = opts.destination == "previous" and start_row or end_row
        local row_offset = find_row_offset(opts.destination, lines)
        target_row = target_row + row_offset

        vim.api.nvim_buf_set_lines(buf, target_row, target_row, false, lines)

        selection.refresh_tree()
        selection.update_item(i, target_row, start_col)
    end

    if should_move_to_newly_created_tag then
        catalyst.set_node(selection.nodes()[1])
        catalyst.set_node_point("start")
        catalyst.move_to()
    end
end

return paste

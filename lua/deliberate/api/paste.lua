local catalyst = require("deliberate.lib.catalyst")
local selection = require("deliberate.lib.selection")
local yank = require("deliberate.api.yank")

---@param lines string[]
---@param target_start_col integer
---@return string[]
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

local M = {}

---@param opts paste_Args | nil
M.call = function(opts)
    opts = vim.tbl_deep_extend("force", default_paste_opts, opts or {})

    vim.bo[catalyst.buf()].undolevels = vim.bo[catalyst.buf()].undolevels
    selection.archive_current_state()
    require("deliberate.api.dot_repeater").register(M.call, opts)

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

    for i = 1, #selection.sorted_nodes() do
        local lines = opts.join and joined_contents or yank.contents()[i]

        local start_row, start_col, end_row, _ = selection.sorted_nodes()[i]:range()

        if opts.reindent then lines = reindent(lines, start_col) end

        local target_row = opts.destination == "previous" and start_row or end_row
        local row_offset = opts.destination == "previous" and 0 or 1
        target_row = target_row + row_offset

        vim.api.nvim_buf_set_lines(selection.buf(), target_row, target_row, false, lines)

        selection.refresh_tree()
        selection.update_item(i, target_row, start_col)
    end

    if should_move_to_newly_created_tag then
        catalyst.set_node(selection.nodes()[1])
        catalyst.set_node_point("start")
        catalyst.move_to()
    end

    require("deliberate.lib.indicator").highlight_selection()
end

return M

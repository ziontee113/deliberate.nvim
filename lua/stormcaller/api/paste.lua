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

---@class paste_Args
---@field destination "previous" | "next"
---@field join boolean | nil

---@param o paste_Args | nil
local paste = function(o)
    o = o or {}
    o.join = o.join or true

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
        local lines = o.join and joined_contents or yank.contents()[i]

        local buf = item.buf
        local start_row, start_col, end_row, _ = item.node:range()

        local target_row = o.destination == "previous" and start_row or end_row
        local row_offset = find_row_offset(o.destination, lines)
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

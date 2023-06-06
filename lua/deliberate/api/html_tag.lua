local M = {}
local api = vim.api

local catalyst = require("deliberate.lib.catalyst")
local selection = require("deliberate.lib.selection")
local aggregator = require("deliberate.lib.tree-sitter.language_aggregator")

---@param buf number
---@param node TSNode
---@return string
local find_indents = function(buf, node)
    local start_row = node:range()
    local first_line = api.nvim_buf_get_lines(buf, start_row, start_row + 1, false)[1]
    return string.match(first_line, "^%s+") or ""
end

---@param destination "next" | "previous" | "inside"
---@param replacement string
---@param node TSNode
---@return number, number
local add_tag_after_node = function(destination, replacement, node)
    local start_row, start_col, end_row = node:range()
    local target_row = destination == "previous" and start_row or end_row
    local row_offset = destination == "previous" and 0 or 1
    target_row = target_row + row_offset

    api.nvim_buf_set_lines(catalyst.buf(), target_row, target_row, false, { replacement })
    return target_row, start_col
end

---@class tag_add_Opts
---@field tag string
---@field destination "next" | "previous" | "inside"
---@field content string | nil

---@param indents string
---@param index number
---@param replacement string
---@return number, number
local function handle_inside_has_no_children(indents, index, replacement)
    local first_closing_bracket =
        aggregator.get_first_closing_bracket(catalyst.buf(), selection.nodes()[index])
    local _, _, b_row, b_col = first_closing_bracket:range()

    api.nvim_buf_set_text(catalyst.buf(), b_row, b_col, b_row, b_col, { "", replacement, indents })

    local row_offset = 1
    local update_row = b_row + row_offset
    local update_col = b_col + vim.bo.tabstop
    return update_row, update_col
end

---@param html_children TSNode[]
---@param replacement string
---@return number, number
local function handle_inside_has_children(html_children, replacement)
    local last_child = html_children[#html_children]

    catalyst.set_node(last_child)
    catalyst.set_node_point("start")
    catalyst.move_to()

    return add_tag_after_node("next", replacement, last_child)
end

---@param index number
---@param replacement string
---@param indents string
---@return number, number
local function handle_destination_inside(index, replacement, indents)
    local update_row, update_col
    replacement = string.rep(" ", vim.bo.tabstop) .. replacement

    local html_children = aggregator.get_html_children(selection.nodes()[index])
    if #html_children == 0 then
        update_row, update_col = handle_inside_has_no_children(indents, index, replacement)
    else
        update_row, update_col = handle_inside_has_children(html_children, replacement)
    end
    return update_row, update_col
end

---@param o tag_add_Opts
M.add = function(o)
    vim.bo[catalyst.buf()].undolevels = vim.bo[catalyst.buf()].undolevels
    selection.archive_for_undo()
    require("deliberate.api.dot_repeater").register(M.add, o)

    for i = 1, #selection.nodes() do
        local update_row, update_col
        local og_node = selection.nodes()[i]
        local content = o.content or "###"
        local indents = find_indents(catalyst.buf(), og_node)

        local replacement = string.format("%s<%s>%s</%s>", indents, o.tag, content, o.tag)

        if o.destination == "inside" then
            if aggregator.node_is_component(og_node) then
                update_row, update_col = add_tag_after_node(o.destination, replacement, og_node)
            else
                update_row, update_col = handle_destination_inside(i, replacement, indents)
            end
        else
            update_row, update_col = add_tag_after_node(o.destination, replacement, og_node)
        end

        selection.refresh_tree()
        selection.update_item(i, update_row, update_col)
    end

    catalyst.set_node(selection.nodes()[#selection.nodes()])
    catalyst.set_node_point("start")
    catalyst.move_to(false, true)

    require("deliberate.lib.indicator").highlight_selection()
end

return M

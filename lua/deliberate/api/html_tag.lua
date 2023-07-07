local M = {}
local api = vim.api

local catalyst = require("deliberate.lib.catalyst")
local selection = require("deliberate.lib.selection")
local aggregator = require("deliberate.lib.tree-sitter.language_aggregator")
local utils = require("deliberate.lib.utils")

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
---@field self_closing boolean | nil

---@param indents string
---@param index number
---@param replacement string
---@return number, number
local function handle_inside_has_no_children(indents, index, replacement)
    local first_closing_bracket =
        aggregator.get_first_closing_bracket(catalyst.buf(), selection.nodes()[index])
    local _, _, b_row, b_col = first_closing_bracket:range()

    api.nvim_buf_set_text(catalyst.buf(), b_row, b_col, b_row, b_col, { "", replacement, indents })

    local tag_node = aggregator.get_tag_identifier_node(selection.nodes()[index])
    local _, tag_identifier_start = tag_node:range()

    local row_offset = 1
    local update_row = b_row + row_offset
    local update_col = tag_identifier_start - 1 + vim.bo.tabstop
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
---@param indents string
---@param content string
---@return string
local process_new_tag_content = function(o, indents, content)
    if o.self_closing then
        return string.format("%s<%s/>", indents, o.tag, content)
    else
        return string.format("%s<%s>%s</%s>", indents, o.tag, content, o.tag)
    end
end

---@param o tag_add_Opts
M.add = function(o)
    for i = 1, #selection.nodes() do
        local update_row, update_col
        local og_node = selection.nodes()[i]
        local content = o.content or "###"
        local indents = utils.find_indents(catalyst.buf(), og_node)

        local new_tag_content = process_new_tag_content(o, indents, content)

        if o.destination == "inside" then
            if aggregator.node_is_self_closing(og_node) then
                update_row, update_col = add_tag_after_node(o.destination, new_tag_content, og_node)
            else
                update_row, update_col = handle_destination_inside(i, new_tag_content, indents)
            end
        else
            update_row, update_col = add_tag_after_node(o.destination, new_tag_content, og_node)
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

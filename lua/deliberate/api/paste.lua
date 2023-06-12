local catalyst = require("deliberate.lib.catalyst")
local selection = require("deliberate.lib.selection")
local yank = require("deliberate.api.yank")
local aggregator = require("deliberate.lib.tree-sitter.language_aggregator")
local utils = require("deliberate.lib.utils")

local join_contents = function()
    local joined_contents = {}
    for _, yanked_lines in ipairs(yank.contents()) do
        for _, line in ipairs(yanked_lines) do
            table.insert(joined_contents, line)
        end
    end
    return joined_contents
end

local spread_the_tag = function(i)
    local first_closing_bracket =
        aggregator.get_first_closing_bracket(catalyst.buf(), selection.nodes()[i])
    local _, _, b_row, b_col = first_closing_bracket:range()

    vim.api.nvim_buf_set_text(
        catalyst.buf(),
        b_row,
        b_col,
        b_row,
        b_col,
        { "", utils.find_indents(catalyst.buf(), selection.nodes()[i]) }
    )

    local tag_node = aggregator.get_tag_identifier_node(selection.nodes()[i])
    local _, tag_identifier_start = tag_node:range()

    local row_offset = 1
    local update_row = b_row + row_offset
    local update_col = tag_identifier_start - 1 + vim.bo.tabstop

    selection.refresh_tree()
    selection.update_item(i, update_row, update_col)
end

local find_target_row = function(opts, start_row, end_row)
    local target_row, row_offset
    if opts.destination == "previous" then
        target_row, row_offset = start_row, 0
    elseif opts.destination == "next" then
        target_row, row_offset = end_row, 1
    elseif
        opts.destination == "inside"
        and opts.paste_inside_destination == "after-all-children"
    then
        target_row, row_offset = start_row, 1
    elseif
        opts.destination == "inside"
        and opts.paste_inside_destination == "before-all-children"
    then
        target_row, row_offset = start_row, 0
    end
    return target_row + row_offset
end

---@class paste_Args
---@field destination "previous" | "next" | "inside"
---@field paste_inside_destination "after-all-children" | "before-all-children"
---@field join boolean | nil
---@field reindent boolean

---@type paste_Args
local default_paste_opts = {
    destination = "next",
    paste_inside_destination = "after-all-children",
    join = true,
    reindent = true,
}

local M = {}

---@param opts paste_Args | nil
M.call = function(opts)
    opts = vim.tbl_deep_extend("force", default_paste_opts, opts or {})

    vim.bo[catalyst.buf()].undolevels = vim.bo[catalyst.buf()].undolevels
    selection.archive_for_undo()
    require("deliberate.api.dot_repeater").register(M.call, opts)

    for i = 1, #selection.nodes() do
        local destination_for_reindent = opts.destination

        if opts.destination == "inside" then
            local html_children = aggregator.get_html_children(selection.nodes()[i])
            if #html_children == 0 then
                spread_the_tag(i)
            else
                if opts.paste_inside_destination == "after-all-children" then
                    local child_start_row, child_start_col = html_children[#html_children]:range()
                    selection.refresh_tree()
                    selection.update_item(i, child_start_row, child_start_col)
                    destination_for_reindent = "next"
                else
                    local child_start_row, child_start_col = html_children[1]:range()
                    selection.refresh_tree()
                    selection.update_item(i, child_start_row, child_start_col)
                    destination_for_reindent = "previous"
                end
            end
        end

        local start_row, start_col, end_row, _ = selection.nodes()[i]:range()

        local lines = opts.join and join_contents() or yank.contents()[i]
        if opts.reindent then lines = utils.reindent(lines, start_col, destination_for_reindent) end

        local target_row = find_target_row(opts, start_row, end_row)
        vim.api.nvim_buf_set_lines(selection.buf(), target_row, target_row, false, lines)

        selection.refresh_tree()
        selection.update_item(i, target_row, start_col)
    end

    catalyst.set_node(selection.nodes()[#selection.nodes()])
    catalyst.set_node_point("start")
    catalyst.move_to(false, true)

    require("deliberate.lib.indicator").highlight_selection()
end

return M

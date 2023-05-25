local M = {}
local api = vim.api

local catalyst = require("stormcaller.lib.catalyst")
local selection = require("stormcaller.lib.selection")
local navigator = require("stormcaller.api.navigator")
local lib_ts = require("stormcaller.lib.tree-sitter")
local lib_ts_tsx = require("stormcaller.lib.tree-sitter.tsx")

---@param buf number
---@param node TSNode
---@return string
local find_indents = function(buf, node)
    local start_row = node:range()
    local first_line = api.nvim_buf_get_lines(buf, start_row, start_row + 1, false)[1]
    return string.match(first_line, "^%s+")
end

---@param index number
---@param end_row number
---@param start_col number
local function update_selected_node(index, end_row, start_col)
    local root = lib_ts.get_root({ parser_name = "tsx", buf = catalyst.buf(), reset = true })
    local updated_node =
        root:named_descendant_for_range(end_row + 1, start_col, end_row + 1, start_col)
    updated_node = lib_ts_tsx.get_jsx_node(updated_node)
    selection.update_specific_selection_index(index, updated_node)
end

---@class tag_add_Opts
---@field tag string
---@field destination "next" | "previous" | "inside"
---@field content string

---@param index number
---@param replacement string
---@param indents string
---@return number, number
local function handle_inside(index, replacement, indents)
    local first_closing_bracket = lib_ts.capture_nodes_with_queries({
        root = selection.nodes()[index],
        buf = catalyst.buf(),
        parser_name = "tsx",
        queries = { [[ (">" @closing_bracket) ]] },
        capture_groups = { "closing_bracket" },
    })[1]

    local _, _, b_row, b_col = first_closing_bracket:range()
    replacement = string.rep(" ", vim.bo.tabstop) .. replacement

    api.nvim_buf_set_text(catalyst.buf(), b_row, b_col, b_row, b_col, { "", replacement, indents })

    -- we do this because `nvim_buf_set_text()` moves the cursor down
    -- if cursor row is equal or below where we start changing buffer text.
    if selection.current_selection_matches_catalyst(index) then catalyst.move_to() end

    local update_row = b_row
    local update_col = b_col + vim.bo.tabstop
    return update_row, update_col
end

---@param destination string
---@param replacement string
---@param og_end_row number
---@param og_start_col number
---@return number, number
local function handle_next_or_previous(destination, replacement, og_end_row, og_start_col)
    local offset = destination == "previous" and 0 or 1
    local target_row = og_end_row + offset

    api.nvim_buf_set_lines(catalyst.buf(), target_row, target_row, false, { replacement })

    local update_row = target_row - 1
    local update_col = og_start_col
    return update_row, update_col
end

---@param o tag_add_Opts
M.add = function(o)
    for i = 1, #selection.nodes() do
        local update_row, update_col

        local og_node = selection.nodes()[i]
        local _, og_start_col, og_end_row = og_node:range()

        local content = o.content or "###"
        local indents = find_indents(catalyst.buf(), og_node)
        local replacement = string.format("%s<%s>%s</%s>", indents, o.tag, content, o.tag)

        if o.destination == "inside" then
            update_row, update_col = handle_inside(i, replacement, indents)
        else
            update_row, update_col =
                handle_next_or_previous(o.destination, replacement, og_end_row, og_start_col)
        end

        selection.refresh_tree()
        update_selected_node(i, update_row, update_col)
    end

    if #selection.nodes() == 1 then
        navigator.move({ destination = o.destination == "previous" and "previous" or "next" })
    end
end

return M

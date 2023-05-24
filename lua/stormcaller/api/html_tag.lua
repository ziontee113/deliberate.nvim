local M = {}

local catalyst = require("stormcaller.lib.catalyst")
local navigator = require("stormcaller.lib.navigator")
local lib_ts = require("stormcaller.lib.tree-sitter")
local lib_ts_tsx = require("stormcaller.lib.tree-sitter.tsx")

local find_indents = function(buf, node)
    local start_row = node:range()
    local first_line = vim.api.nvim_buf_get_lines(buf, start_row, start_row + 1, false)[1]
    return string.match(first_line, "^%s+")
end

local function update_selected_node(index, end_row, start_col)
    local root = lib_ts.get_root({ parser_name = "tsx", buf = catalyst.buf(), reset = true })
    local updated_node =
        root:named_descendant_for_range(end_row + 1, start_col, end_row + 1, start_col)
    updated_node = lib_ts_tsx.get_jsx_node(updated_node)
    catalyst.update_node_in_selection(index, updated_node)
end

---@class tag_add_Opts
---@field tag string
---@field destination "next" | "previous" | "inside"
---@field content string

---@param o tag_add_Opts
M.add = function(o)
    for i = 1, #catalyst.selected_nodes() do
        local update_row, update_col

        local node = catalyst.selected_nodes()[i]

        local _, start_col, end_row = node:range()

        local placeholder = o.content or "###"
        local indents = find_indents(catalyst.buf(), node)
        local content = string.format("%s<%s>%s</%s>", indents, o.tag, placeholder, o.tag)

        if o.destination == "inside" then
            local first_closing_bracket = lib_ts.capture_nodes_with_queries({
                root = node,
                buf = catalyst.buf(),
                parser_name = "tsx",
                queries = { [[ (">" @closing_bracket) ]] },
                capture_groups = { "closing_bracket" },
            })[1]

            local _, _, target_row, target_col = first_closing_bracket:range()

            vim.api.nvim_buf_set_text(
                catalyst.buf(),
                target_row,
                target_col,
                target_row,
                target_col,
                { "", string.rep(" ", vim.bo.tabstop) .. content, indents }
            )

            -- we do this because `nvim_buf_set_text()` moves the cursor down
            -- if cursor row is equal or below where we start changing buffer text.
            if catalyst.selection_index_matches_catalyst(i) then catalyst.move_to() end

            update_row = target_row
            update_col = target_col + vim.bo.tabstop
        else
            local offset = o.destination == "previous" and 0 or 1
            local target_row = end_row + offset
            vim.api.nvim_buf_set_lines(catalyst.buf(), target_row, target_row, false, { content })

            update_row = target_row - 1
            update_col = start_col
        end

        catalyst.refresh_tree()
        update_selected_node(i, update_row, update_col)
    end

    if #catalyst.selected_nodes() == 1 then
        navigator.move({ destination = o.destination == "previous" and "previous" or "next" })
    end
end

return M

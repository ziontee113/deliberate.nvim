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

local find_offset = function(destination)
    if destination == "next" or destination == "inside" then
        return 1
    elseif destination == "previous" then
        return 0
    end
end

---@class tag_add_Opts
---@field tag string
---@field destination "next" | "previous" | "inside"
---@field content string

---@param o tag_add_Opts
M.add = function(o)
    local offset = find_offset(o.destination)

    for i = 1, #catalyst.selected_nodes() do
        local node = catalyst.selected_nodes()[i]

        local _, start_col, end_row = node:range()

        local placeholder = o.content or "###"
        local indents = find_indents(catalyst.buf(), node)
        local content = string.format("%s<%s>%s</%s>", indents, o.tag, placeholder, o.tag)

        local target_row = end_row + offset
        vim.api.nvim_buf_set_lines(catalyst.buf(), target_row, target_row, false, { content })

        catalyst.refresh_tree()

        update_selected_node(i, target_row - 1, start_col)
    end

    if #catalyst.selected_nodes() == 1 then
        navigator.move({ destination = o.destination == "previous" and "previous" or "next" })
    end
end

return M

local M = {}

local navigator = require("nvim-stormcaller.lib.navigator")
local lib_ts = require("nvim-stormcaller.lib.tree-sitter")

---@class modify_padding_Opts
---@field axis "omni" | "x" | "y" | "l" | "r" | "t" | "b"
---@field modify_to string

M.modify_padding = function(o)
    local _catalyst = navigator.get_catalyst()
    if not _catalyst then return end

    local attribute_master_node
    if _catalyst.node:type() == "jsx_element" then
        attribute_master_node = lib_ts.get_children_with_types({
            node = _catalyst.node,
            desired_types = { "jsx_opening_element" },
        })[1]
    elseif _catalyst:type() == "jsx_self_closing_element" then
        -- TODO:
    end

    local tag_node = lib_ts.get_children_with_types({
        node = attribute_master_node,
        desired_types = { "identifier" },
    })[1]

    if not tag_node then return end

    local start_row, _, _, end_col = tag_node:range()

    vim.api.nvim_buf_set_text(
        _catalyst.buf,
        start_row,
        end_col,
        start_row,
        end_col,
        { string.format(' className="%s"', o.modify_to) }
    )
end

return M

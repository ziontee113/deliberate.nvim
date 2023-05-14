local ts_utils = require("nvim-treesitter.ts_utils")
local lib_ts = require("nvim-stormcaller.lib.tree-sitter")

local M = {}

M.initiate = function()
    vim.cmd("norm! ^")

    local current_node = ts_utils.get_node_at_cursor(0)
    local parent = lib_ts.find_closest_parent_with_types({
        node = current_node,
        desired_parent_types = { "jsx_element", "jsx_self_closing_element" },
    })
end

return M

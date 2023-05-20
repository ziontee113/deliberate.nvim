local lib_ts = require("stormcaller.lib.tree-sitter")

local M = {}

---@param buf number
---@return TSNode[], table
M.get_all_jsx_nodes_in_buffer = function(buf)
    local all_jsx_nodes, grouped_captures = lib_ts.capture_nodes_with_queries({
        buf = buf,
        parser_name = "tsx",
        queries = {
            "(jsx_fragment) @jsx_fragment",
            "(jsx_element) @jsx_element",
            "(jsx_self_closing_element) @jsx_self_closing_element",
        },
        capture_groups = { "jsx_element", "jsx_self_closing_element", "jsx_fragment" },
    })
    return all_jsx_nodes, grouped_captures
end

return M

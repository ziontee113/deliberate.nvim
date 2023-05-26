local lib_ts = require("stormcaller.lib.tree-sitter")

local M = {}

M.get_all_html_nodes_in_buffer = function(buf)
    local all_html_nodes, grouped_captures = lib_ts.capture_nodes_with_queries({
        buf = buf,
        parser_name = "svelte",
        queries = {
            "(element) @element",
        },
        capture_groups = { "element" },
    })
    return all_html_nodes, grouped_captures
end

M.get_tag_identifier_node = function(node)
    local first_child = lib_ts.get_children_with_types({
        node = node,
        desired_types = { "start_tag", "self_closing_tag" },
    })[1]
    if not first_child then error("can't find correct child element") end
    return lib_ts.get_children_with_types({
        node = first_child,
        desired_types = { "tag_name" },
    })[1]
end

return M

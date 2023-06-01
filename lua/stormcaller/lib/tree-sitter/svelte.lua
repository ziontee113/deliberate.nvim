local lib_ts = require("stormcaller.lib.tree-sitter")

local M = {}

---@param buf number
---@return TSNode[], TSNode[]
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

---@param node TSNode
---@return TSNode
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

---@param buf number
---@param node TSNode
---@return TSNode
M.get_className_property_string_node = function(buf, node)
    local _, grouped_captures = lib_ts.capture_nodes_with_queries({
        buf = buf,
        root = node,
        parser_name = "svelte",
        queries = {
            [[ ;query
(attribute
  (attribute_name) @attr_name (#eq? @attr_name "class")
  (quoted_attribute_value) @string
)
]],
        },
        capture_groups = { "string" },
    })
    return grouped_captures["string"][1]
end

---@param buf number
---@param node TSNode
---@return string[], TSNode|nil
M.extract_class_names = function(buf, node)
    local className_string_node = M.get_className_property_string_node(buf, node)
    local attribute_string_text = vim.treesitter.get_node_text(className_string_node, buf)
    local string_content = attribute_string_text:match('"([^"]+)"') or ""

    local class_names = vim.split(string_content, " ")
    return class_names, className_string_node
end

--------------------------------------------

M.get_updated_root = function(buf) return lib_ts.get_updated_root(buf, "svelte") end

M.get_html_node = function(node) return lib_ts.get_html_node(node, { "element" }) end

M.get_first_closing_bracket = function(buf, node)
    return lib_ts.get_first_closing_bracket(buf, node, "svelte")
end

M.get_html_children = function(node) return lib_ts.get_html_children(node, { "element" }) end

M.get_html_siblings = function(node, direction)
    return lib_ts.get_html_siblings(node, direction, { "element" })
end

return M

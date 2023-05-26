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
    local attribute_string_text = vim.treesitter.get_node_text(className_string_node, 0)
    local string_content = attribute_string_text:match('"([^"]+)"') or ""

    local class_names = vim.split(string_content, " ")
    return class_names, className_string_node
end

---@param buf number
---@return TSNode
M.get_updated_root = function(buf)
    local updated_root = lib_ts.get_root({ parser_name = "svelte", buf = buf, reset = true })
    if not updated_root then error("can't get updated root for svelte, something went wrong.") end
    return updated_root
end

---@param node TSNode
---@return TSNode|nil
M.get_html_node = function(node)
    return lib_ts.find_closest_parent_with_types({
        node = node,
        desired_parent_types = { "element" },
    })
end

---@param buf number
---@param node TSNode
---@return TSNode
M.get_first_closing_bracket = function(buf, node)
    local first_bracket = lib_ts.capture_nodes_with_queries({
        root = node,
        buf = buf,
        parser_name = "svelte",
        queries = { [[ (">" @closing_bracket) ]] },
        capture_groups = { "closing_bracket" },
    })[1]

    if not first_bracket then error("given node argument is not an html_element") end
    return first_bracket
end

---@param node TSNode
---@return TSNode[]
M.get_html_children = function(node)
    return lib_ts.get_children_with_types({ node = node, desired_types = { "element" } })
end

---@param node TSNode
---@param direction "previous" | "next"
---@return TSNode[], TSNode
M.get_html_siblings = function(node, direction)
    return lib_ts.find_named_siblings_in_direction_with_types({
        node = node,
        direction = direction,
        desired_types = { "element" },
    })
end

return M

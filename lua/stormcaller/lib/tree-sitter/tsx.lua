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

---@param node TSNode
---@return TSNode | nil
M.get_tag_identifier_node = function(node)
    local attribute_master_node
    if node:type() == "jsx_element" then
        attribute_master_node = lib_ts.get_children_with_types({
            node = node,
            desired_types = { "jsx_opening_element" },
        })[1]
    elseif node:type() == "jsx_self_closing_element" then
        attribute_master_node = node
    end

    if not attribute_master_node then return end

    local tag_node = lib_ts.get_children_with_types({
        node = attribute_master_node,
        desired_types = { "identifier" },
    })[1]
    return tag_node
end

---@param buf number
---@param node TSNode
---@return TSNode | nil
M.get_className_property_string_node = function(buf, node)
    local _, grouped_captures = lib_ts.capture_nodes_with_queries({
        buf = buf,
        root = node,
        parser_name = "tsx",
        queries = {
            [[ ;query
(jsx_attribute
  (property_identifier) @prop_ident (#eq? @prop_ident "className")
  (string) @string
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

---@param node TSNode
---@return TSNode|nil
M.get_jsx_node = function(node)
    return lib_ts.find_closest_parent_with_types({
        node = node,
        desired_parent_types = { "jsx_element", "jsx_self_closing_element", "jsx_fragment" },
    })
end

return M

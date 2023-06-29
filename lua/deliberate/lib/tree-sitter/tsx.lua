local lib_ts = require("deliberate.lib.tree-sitter")

local M = {}

-------------------------------------------- Local Functions

---@param buf number
---@param node TSNode
---@param property string
---@return TSNode | nil
local get_property_string_node = function(buf, node, property)
    local _, grouped_captures = lib_ts.capture_nodes_with_queries({
        buf = buf,
        root = node,
        parser_name = "tsx",
        queries = {
            string.format(
                [[ ;query
(jsx_attribute
  (property_identifier) @prop_ident (#eq? @prop_ident "%s")
  (string) @string
)
]],
                property
            ),
        },
        capture_groups = { "string" },
    })

    local target_node = grouped_captures["string"][1]
    if target_node then
        local html_parent = M.get_html_node(target_node)
        if html_parent ~= node then return nil end
    end
    return target_node
end

-------------------------------------------- Public Functions

---@param buf number
---@return TSNode[], table
M.get_all_html_nodes_in_buffer = function(buf)
    local all_html_nodes, grouped_captures = lib_ts.capture_nodes_with_queries({
        buf = buf,
        parser_name = "tsx",
        queries = {
            "(jsx_fragment) @jsx_fragment",
            "(jsx_element) @jsx_element",
            "(jsx_self_closing_element) @jsx_self_closing_element",
        },
        capture_groups = { "jsx_element", "jsx_self_closing_element", "jsx_fragment" },
    })
    return all_html_nodes, grouped_captures
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
---@return string[], TSNode|nil
M.extract_class_names = function(buf, node)
    local className_string_node = M.get_className_property_string_node(buf, node)
    local attribute_string_text = vim.treesitter.get_node_text(className_string_node, buf)
    local string_content = attribute_string_text:match('"([^"]+)"') or ""

    local class_names = vim.split(string_content, " ")
    return class_names, className_string_node
end

---@param buf number
---@return TSNode
M.get_updated_root = function(buf) return lib_ts.get_updated_root(buf, "tsx") end

---@param buf number
---@param node TSNode
---@return TSNode | nil
M.get_first_closing_bracket = function(buf, node)
    return lib_ts.get_first_closing_bracket(buf, node, "tsx")
end

---@param node TSNode
---@return TSNode | nil
M.get_html_node = function(node)
    return lib_ts.get_html_node(node, { "jsx_element", "jsx_self_closing_element", "jsx_fragment" })
end

---@param node TSNode
---@return TSNode[]
M.get_html_children = function(node)
    return lib_ts.get_html_children(node, { "jsx_element", "jsx_self_closing_element" })
end

---@param node TSNode
---@param direction "previous" | "next"
---@return TSNode[], TSNode
M.get_html_siblings = function(node, direction)
    return lib_ts.get_html_siblings(node, direction, { "jsx_element", "jsx_self_closing_element" })
end

---@return TSNode
M.get_text_nodes = function(node) return lib_ts.get_html_children(node, { "jsx_text" }) end

---@param node TSNode
---@return boolean
M.node_is_component = function(node) return node:type() == "jsx_self_closing_element" end

---@param node TSNode
---@return TSNode, TSNode
M.get_opening_and_closing_tags = function(node)
    return unpack(lib_ts.get_html_children(node, { "jsx_opening_element", "jsx_closing_element" }))
end

-------------------------------------------- Get Property String Nodes

---@param buf number
---@param node TSNode
---@return TSNode | nil
M.get_className_property_string_node = function(buf, node)
    return get_property_string_node(buf, node, "className")
end

---@param buf number
---@param node TSNode
---@return TSNode | nil
M.get_src_property_string_node = function(buf, node)
    return get_property_string_node(buf, node, "src")
end

-------------------------------------------- Get Attribute Value Node

M.get_attribute_value = function(buf, node, attribute)
    local root = node
    if node:type() ~= "jsx_self_closing_element" then
        root = lib_ts.get_children_with_types({
            node = node,
            desired_types = { "jsx_opening_element" },
        })[1]
    end

    local _, grouped_captures = lib_ts.capture_nodes_with_queries({
        buf = buf,
        root = root,
        parser_name = "tsx",
        queries = {
            string.format(
                [[ ;query
    (jsx_attribute
      (property_identifier) @prop_ident (#eq? @prop_ident "%s")
    )
]],
                attribute
            ),
        },
        capture_groups = { "prop_ident" },
    })

    local target_node = grouped_captures["prop_ident"][1]
    if not target_node then return end
    return target_node:next_named_sibling()
end

return M

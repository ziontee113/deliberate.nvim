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
        parser_name = "svelte",
        queries = {
            string.format(
                [[ ;query
(attribute
  (attribute_name) @attr_name (#eq? @attr_name "%s")
  (quoted_attribute_value) @string
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
M.get_updated_root = function(buf) return lib_ts.get_updated_root(buf, "svelte") end

---@param node TSNode
---@return TSNode | nil
M.get_html_node = function(node) return lib_ts.get_html_node(node, { "element" }) end

---@param buf number
---@param node TSNode
---@return TSNode | nil
M.get_first_closing_bracket = function(buf, node)
    return lib_ts.get_first_closing_bracket(buf, node, "svelte")
end

---@param node TSNode
---@return TSNode[]
M.get_html_children = function(node) return lib_ts.get_html_children(node, { "element" }) end

---@param node TSNode
---@param direction "previous" | "next"
---@return TSNode[], TSNode
M.get_html_siblings = function(node, direction)
    return lib_ts.get_html_siblings(node, direction, { "element" })
end

---@param node TSNode
---@return TSNode[]
M.get_text_nodes = function(node) return lib_ts.get_html_children(node, { "text" }) end

---@param node TSNode
---@return boolean
M.node_is_component = function(node)
    local children =
        lib_ts.get_children_with_types({ node = node, desired_types = { "self_closing_tag" } })
    if #children > 0 then return true end
    return false
end

---@param node TSNode
---@return TSNode
M.get_opening_and_closing_tags = function(node)
    return unpack(lib_ts.get_html_children(node, { "start_tag", "end_tag" }))
end

-------------------------------------------- Get Property String Nodes

---@param buf number
---@param node TSNode
---@return TSNode | nil
M.get_className_property_string_node = function(buf, node)
    return get_property_string_node(buf, node, "class")
end

---@param buf number
---@param node TSNode
---@return TSNode | nil
M.get_src_property_string_node = function(buf, node)
    return get_property_string_node(buf, node, "src")
end

-------------------------------------------- Get Attribute Value Node

M.get_attribute_value = function(buf, node, attribute)
    local root = lib_ts.get_children_with_types({
        node = node,
        desired_types = { "start_tag", "self_closing_tag" },
    })[1]

    local _, grouped_captures = lib_ts.capture_nodes_with_queries({
        buf = buf,
        root = root,
        parser_name = "svelte",
        queries = {
            string.format(
                [[ ;query
  (attribute
    (attribute_name) @attr_name (#eq? @attr_name "%s")
  )
]],
                attribute
            ),
        },
        capture_groups = { "attr_name" },
    })

    local target_node = grouped_captures["attr_name"][1]
    if not target_node then return end
    return target_node:next_named_sibling()
end

return M

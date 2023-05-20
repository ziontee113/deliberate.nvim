local M = {}

local catalyst = require("nvim-stormcaller.lib.catalyst")
local lib_ts = require("nvim-stormcaller.lib.tree-sitter")

local function get_tag_identifier_node(node)
    local attribute_master_node
    if node:type() == "jsx_element" then
        attribute_master_node = lib_ts.get_children_with_types({
            node = node,
            desired_types = { "jsx_opening_element" },
        })[1]
    elseif node:type() == "jsx_self_closing_element" then
        -- TODO:
    end

    local tag_node = lib_ts.get_children_with_types({
        node = attribute_master_node,
        desired_types = { "identifier" },
    })[1]
    return tag_node
end

local function set_empty_className_property(buf, node)
    local tag_node = get_tag_identifier_node(node)
    local start_row, _, _, end_col = tag_node:range()
    vim.api.nvim_buf_set_text(buf, start_row, end_col, start_row, end_col, { ' className=""' })
end

---@param buf number
---@param node TSNode
---@return TSNode | nil
local get_className_attribute_string_node = function(buf, node)
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
local extract_class_names = function(buf, node)
    local className_string_node = get_className_attribute_string_node(buf, node)
    local attribute_string_text = vim.treesitter.get_node_text(className_string_node, 0)
    local string_content = attribute_string_text:match('"([^"]+)"') or ""

    local class_names = vim.split(string_content, " ")

    return class_names, className_string_node
end

---@param class_names string[]
---@param modify_to string
---@return string
local function modify_class_names(class_names, modify_to)
    for i = #class_names, 1, -1 do
        if class_names[i] == "" then table.remove(class_names, i) end
    end

    table.insert(class_names, modify_to)
    return table.concat(class_names, " ")
end

---@class modify_padding_Opts
---@field axis "omni" | "x" | "y" | "l" | "r" | "t" | "b"
---@field modify_to string

M.change_padding = function(o)
    if not catalyst.is_active() then return end

    if not get_className_attribute_string_node(catalyst.buf(), catalyst.node()) then
        set_empty_className_property(catalyst.buf(), catalyst.node())
    end

    local class_names, className_string_node = extract_class_names(catalyst.buf(), catalyst.node())
    local modified_class_names = modify_class_names(class_names, o.modify_to)

    lib_ts.replace_node_text({
        node = className_string_node,
        buf = catalyst.buf(),
        replacement = string.format('"%s"', modified_class_names),
    })

    catalyst.refresh_node()
end

return M

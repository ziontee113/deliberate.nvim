local M = {}

local catalyst = require("stormcaller.lib.catalyst")
local selection = require("stormcaller.lib.selection")
local lib_ts = require("stormcaller.lib.tree-sitter")
local lib_ts_tsx = require("stormcaller.lib.tree-sitter.tsx")
local lua_patterns = require("stormcaller.lib.lua_patterns")

---@param buf number
---@param node TSNode
local function set_empty_className_property_if_needed(buf, node)
    if lib_ts_tsx.get_className_property_string_node(buf, node) then return end

    local tag_node = lib_ts_tsx.get_tag_identifier_node(node)
    if not tag_node then error("Given node argument shouldn't have been nil") end

    local start_row, _, _, end_col = tag_node:range()
    vim.api.nvim_buf_set_text(buf, start_row, end_col, start_row, end_col, { ' className=""' })

    selection.refresh_tree()
end

---@param class_names string[]
---@return string[]
local function remove_empty_strings(class_names)
    for i = #class_names, 1, -1 do
        if class_names[i] == "" then table.remove(class_names, i) end
    end
    return class_names
end

---@param class_names string[]
---@return string
local function format_class_names(class_names)
    class_names = remove_empty_strings(class_names)
    local str = table.concat(class_names, " ")
    return string.format('"%s"', str)
end

---@param class_names string[]
---@param patterns string[] | string
---@param replacement string
---@return boolean, string[]
local replace_class_names = function(class_names, patterns, replacement)
    if type(patterns) == "string" then patterns = { patterns } end
    for i = #class_names, 1, -1 do
        for _, pattern in ipairs(patterns) do
            if class_names[i] and string.match(class_names[i], pattern) then
                class_names[i] = replacement
                return true, class_names
            end
        end
    end
    return false, class_names
end

---@param class_names string[]
---@param patterns string[] | string
---@param value string
---@return string
local function process_new_class_names(class_names, patterns, value)
    local replaced, new_class_names = replace_class_names(class_names, patterns, value)
    if replaced then
        class_names = new_class_names
    else
        table.insert(class_names, value)
    end

    return format_class_names(class_names)
end

---@class change_tailwind_classes_Args
---@field property  "padding" | "margin" | "spacing" | "text_color" | "background_color"
---@field axis "omni" | "x" | "y" | "l" | "r" | "t" | "b"
---@field value string

---@param o change_tailwind_classes_Args
---@return string[] | string
local find_patterns = function(o)
    if o.property == "padding" or o.property == "margin" or o.property == "spacing" then
        return lua_patterns[o.property][o.axis]
    else
        return lua_patterns[o.property]
    end
end

---@param o change_tailwind_classes_Args
local change_tailwind_classes = function(o)
    if not catalyst.is_active() then return end

    for i = 1, #selection.nodes() do
        -- we need to get `node` this way because if not, we'll get its "old content" (pre-modified)
        -- in this case, the `replace_node_text()` of the previous iteration might've modified the node's content,
        -- so we need to use `selection.nodes()` to get the updated nodes, otherwise everything breaks.
        local node = selection.nodes()[i]

        set_empty_className_property_if_needed(catalyst.buf(), node)

        -- we need to get `node` this way because if not, we'll get its "old content" (pre-modified)
        -- in this case, `set_empty_className_property_if_needed()` might've modified the node's content,
        -- so we need to use `selection.nodes()` to get the updated nodes, otherwise everything breaks.
        node = selection.nodes()[i]

        local class_names, className_string_node =
            lib_ts_tsx.extract_class_names(catalyst.buf(), node)

        local replacement = process_new_class_names(class_names, find_patterns(o), o.value)

        lib_ts.replace_node_text({
            node = className_string_node,
            buf = catalyst.buf(),
            replacement = replacement,
        })

        selection.refresh_tree()
    end
end

M.change_padding = function(o)
    change_tailwind_classes({ property = "padding", axis = o.axis, value = o.value })
end
M.change_margin = function(o)
    change_tailwind_classes({ property = "margin", axis = o.axis, value = o.value })
end
M.change_spacing = function(o)
    change_tailwind_classes({ property = "spacing", axis = o.axis, value = o.value })
end

M.change_text_color = function(o)
    change_tailwind_classes({ property = "text_color", value = o.value })
end
M.change_background_color = function(o)
    change_tailwind_classes({ property = "background_color", value = o.value })
end

return M

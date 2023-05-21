local M = {}

local catalyst = require("stormcaller.lib.catalyst")
local lib_ts = require("stormcaller.lib.tree-sitter")
local lib_ts_tsx = require("stormcaller.lib.tree-sitter.tsx")
local lua_patterns = require("stormcaller.lib.lua_patterns")

---@param buf number
---@param node TSNode
local function set_empty_className_property(buf, node)
    local tag_node = lib_ts_tsx.get_tag_identifier_node(node)
    if not tag_node then error("Given node argument shouldn't have been nil") end

    local start_row, _, _, end_col = tag_node:range()
    vim.api.nvim_buf_set_text(buf, start_row, end_col, start_row, end_col, { ' className=""' })
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

local replace_class_names = function(class_names, property, axis, replacement)
    for i = #class_names, 1, -1 do
        for _, pattern in ipairs(lua_patterns.pms[property][axis]) do
            if class_names[i] and string.match(class_names[i], pattern) then
                class_names[i] = replacement
                return true, class_names
            end
        end
    end
end

---@param class_names string[]
---@param change_to string
---@return string
local function process_new_class_names(class_names, property, axis, change_to)
    local replaced, new_class_names = replace_class_names(class_names, property, axis, change_to)
    if replaced then
        class_names = new_class_names
    else
        table.insert(class_names, change_to)
    end

    return format_class_names(class_names)
end

---@class change_pms_Args
---@field property "padding" | "margin" | "spacing"
---@field axis "omni" | "x" | "y" | "l" | "r" | "t" | "b"
---@field change_to string

---@param o change_pms_Args
local change_pms_classes = function(o)
    if not catalyst.is_active() then return end

    if not lib_ts_tsx.get_className_property_string_node(catalyst.buf(), catalyst.node()) then
        set_empty_className_property(catalyst.buf(), catalyst.node())
    end

    local class_names, className_string_node =
        lib_ts_tsx.extract_class_names(catalyst.buf(), catalyst.node())

    local replacement = process_new_class_names(class_names, o.property, o.axis, o.change_to)

    lib_ts.replace_node_text({
        node = className_string_node,
        buf = catalyst.buf(),
        replacement = replacement,
    })

    catalyst.refresh_node()
end

M.change_padding = function(o)
    change_pms_classes({ property = "padding", axis = o.axis, change_to = o.change_to })
end
M.change_margin = function(o)
    change_pms_classes({ property = "margin", axis = o.axis, change_to = o.change_to })
end
M.change_spacing = function(o)
    change_pms_classes({ property = "spacing", axis = o.axis, change_to = o.change_to })
end

return M
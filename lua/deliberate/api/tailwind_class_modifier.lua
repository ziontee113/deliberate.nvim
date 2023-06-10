local M = {}

local catalyst = require("deliberate.lib.catalyst")
local selection = require("deliberate.lib.selection")
local lib_ts = require("deliberate.lib.tree-sitter")
local aggregator = require("deliberate.lib.tree-sitter.language_aggregator")
local lua_patterns = require("deliberate.lib.lua_patterns")
local utils = require("deliberate.lib.utils")
local pseudo_classes_manager = require("deliberate.lib.pseudo_classes.manager")

---@param buf number
---@param node TSNode
local function set_empty_className_property_if_needed(buf, node)
    if aggregator.get_className_property_string_node(buf, node) then return end

    local tag_node = aggregator.get_tag_identifier_node(node)
    if not tag_node then error("Given node argument shouldn't have been nil") end

    local start_row, _, _, end_col = tag_node:range()
    local template = aggregator.get_className_property_template()
    vim.api.nvim_buf_set_text(buf, start_row, end_col, start_row, end_col, { template })

    selection.refresh_tree()
end

---@param class_names string[]
---@return string
local function format_class_names(class_names)
    class_names = utils.remove_empty_strings(class_names)
    local str = table.concat(class_names, " ")
    return string.format('"%s"', str)
end

---@param class_names string[]
---@param patterns string[]
---@param replacement string
---@return boolean, string[]
local replace_class_names = function(class_names, patterns, replacement)
    if type(patterns) == "string" then patterns = { patterns } end
    local replaced = false
    for i = #class_names, 1, -1 do
        local pseudo_prefix, class = utils.pseudo_split(class_names[i])
        for _, pattern in ipairs(patterns) do
            if
                class
                and string.match(class, pattern)
                and pseudo_prefix == pseudo_classes_manager.get_current()
            then
                class_names[i] = replacement
                replaced = true
                break
            end
        end
    end
    return replaced, class_names
end

---@param class_names string[]
---@param patterns string[]
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
---@field property string
---@field axis "" | "x" | "y" | "l" | "r" | "t" | "b"
---@field classes_groups string[]
---@field negative_patterns string[]
---@field value string

---@param o change_tailwind_classes_Args
---@return string[]
local find_patterns = function(o)
    local patterns
    if lua_patterns[o.property] and lua_patterns[o.property][o.axis] then
        patterns = lua_patterns[o.property][o.axis]
    else
        patterns = lua_patterns[o.property]
    end

    if type(patterns) == "string" then patterns = {} end

    for _, negative_pattern in ipairs(o.negative_patterns or {}) do
        table.insert(patterns, negative_pattern)
    end

    if not patterns then error("failed to `find_patterns` for property: " .. o.property) end
    return patterns
end

---@param o change_tailwind_classes_Args
M._change = function(o)
    if not catalyst.is_active() then return end

    selection.archive_empty_state_for_undo()
    require("deliberate.api.dot_repeater").register(M._change, o)

    o.negative_patterns = vim.tbl_flatten(o.negative_patterns or {})

    for i = 1, #selection.nodes() do
        -- QUESTION: why use `selection.nodes()[i]` instead of using `for i, node in ipairs(selection.nodes())`?
        -- ANSWER: `selection.nodes()[i]` makes sure we get the "latest updated version of the node" (handled by `selection` module).
        -- If we use `ipairs`, after we change buffer content (like using `nvim_buf_set_text()`),
        -- the `node` we get from `ipairs` doesn't get updated, which leads to false computation.

        set_empty_className_property_if_needed(catalyst.buf(), selection.nodes()[i])

        local class_names, className_string_node =
            aggregator.extract_class_names(catalyst.buf(), selection.nodes()[i])

        local replacement
        if o.classes_groups then
            replacement = require("deliberate.lib.classes_group").apply(
                class_names,
                o.classes_groups,
                o.value,
                o.negative_patterns
            )
            replacement = string.format('"%s"', replacement)
        else
            local current_pseudo_classes = pseudo_classes_manager.get_current()
            local pseudoed_value = o.value ~= "" and current_pseudo_classes .. o.value or o.value
            replacement = process_new_class_names(class_names, find_patterns(o), pseudoed_value)
        end

        lib_ts.replace_node_text({
            node = className_string_node,
            buf = catalyst.buf(),
            replacement = replacement,
        })

        selection.refresh_tree()
    end
end

M.change_padding = function(o) M._change({ property = "p", axis = o.axis, value = o.value }) end
M.change_margin = function(o) M._change({ property = "m", axis = o.axis, value = o.value }) end
M.change_spacing = function(o) M._change({ property = "space", axis = o.axis, value = o.value }) end

M.change_classes_groups = function(o)
    M._change({ classes_groups = o.classes_groups, value = o.value })
end

M.change_text_color = function(o) M._change({ property = "text-color", value = o.value }) end
M.change_background_color = function(o)
    M._change({ property = "background-color", value = o.value })
end

return M

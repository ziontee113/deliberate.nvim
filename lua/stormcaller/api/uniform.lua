local selection = require("stormcaller.lib.selection")
local aggregator = require("stormcaller.lib.tree-sitter.language_aggregator")

local M = {}

local update_selection_if_possible = function(targets)
    if #targets == #selection.nodes() then
        for i, node in ipairs(targets) do
            selection.update_item(i, nil, nil, node)
        end
    end
end

local handle_siblings = function(destination)
    local sibling_direction = string.find(destination, "next") and "next" or "previous"
    local targets = {}
    for _, node in ipairs(selection.nodes()) do
        local next_siblings = aggregator.get_html_siblings(node, sibling_direction)
        if next_siblings[1] then table.insert(targets, next_siblings[1]) end
    end

    update_selection_if_possible(targets)
end

local handle_parent = function()
    local targets = {}
    for _, node in ipairs(selection.nodes()) do
        local parent = aggregator.get_html_node(node:parent())
        if parent then table.insert(targets, parent) end
    end

    update_selection_if_possible(targets)
end

local handle_previous_or_next = function(direction)
    -- TODO:
end

---@class uniform_move_Args
---@field destination "next-sibling" | "previous-sibling" | "next" | "previous" | "parent"

---@param o uniform_move_Args
M.move = function(o)
    if string.find(o.destination, "sibling") then handle_siblings(o.destination) end
    if o.destination == "parent" then handle_parent() end
    if o.destination == "previous" or o.destination == "next" then
        handle_previous_or_next(o.destination)
    end
end

return M

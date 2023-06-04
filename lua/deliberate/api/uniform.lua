local selection = require("deliberate.lib.selection")
local aggregator = require("deliberate.lib.tree-sitter.language_aggregator")

local M = {}

---@param targets TSNode[]
---@return boolean
local update_selection_if_possible = function(targets)
    if #targets == #selection.nodes() then
        for i, node in ipairs(targets) do
            selection.update_item(i, nil, nil, node)
        end
        return true
    end
    return false
end

local function find_parents()
    local targets = {}
    for _, node in ipairs(selection.nodes()) do
        local parent = aggregator.get_html_node(node:parent())
        if parent then table.insert(targets, parent) end
    end
    return targets
end

local find_children = function()
    local targets = {}
    for _, node in ipairs(selection.nodes()) do
        local children = aggregator.get_html_children(node)
        if children then table.insert(targets, children[1]) end
    end
    return targets
end

local function find_siblings(destination)
    local sibling_direction = string.find(destination, "next") and "next" or "previous"
    local targets = {}
    for _, node in ipairs(selection.nodes()) do
        local next_siblings = aggregator.get_html_siblings(node, sibling_direction)
        if next_siblings[1] then table.insert(targets, next_siblings[1]) end
    end
    return targets
end

local handle_siblings = function(destination)
    local targets = find_siblings(destination)
    return update_selection_if_possible(targets)
end

local function handle_children()
    local children = find_children()
    update_selection_if_possible(children)
end

local function handle_parent()
    local parents = find_parents()
    local overlap = false
    for i, node in ipairs(parents) do
        for j, parent in ipairs(parents) do
            if i ~= j and node == parent then
                overlap = true
                break
            end
            if overlap then break end
        end
    end
    if not overlap then update_selection_if_possible(parents) end
end

local handle_previous_or_next = function(destination)
    if not handle_siblings(destination) then
        if destination == "previous" then
            handle_parent()
        elseif destination == "next" then
            handle_children()
        end
    end
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

    require("deliberate.lib.indicator").highlight_selection()
end

return M

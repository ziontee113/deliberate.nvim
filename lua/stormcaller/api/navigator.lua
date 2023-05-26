local lib_ts = require("stormcaller.lib.tree-sitter")
local lib_ts_tsx = require("stormcaller.lib.tree-sitter.tsx")
local catalyst = require("stormcaller.lib.catalyst")

local M = {}

---@class navigator_move_Args
---@field destination "next-sibling" | "previous-sibling" | "next" | "previous" | "parent"
---@field select_move boolean

---@param nodes TSNode[]
---@param row number
---@return TSNode
local function find_closest_next_node_to_row(nodes, row)
    local closest_distance, closest_node = math.huge, nil
    for _, node in ipairs(nodes) do
        local start_row = node:range()
        if start_row > row and math.abs(start_row - row) < closest_distance then
            closest_node = node
            closest_distance = math.abs(start_row - row)
        end
    end
    return closest_node
end

---@param nodes TSNode[]
---@param row number
---@return TSNode
local function find_closest_previous_node_to_row(nodes, row)
    local closest_distance, closest_node = math.huge, nil
    for _, node in ipairs(nodes) do
        local _, _, end_row, _ = node:range()
        if end_row < row and math.abs(end_row - row) < closest_distance then
            closest_node = node
            closest_distance = math.abs(end_row - row)
        end
    end
    return closest_node
end

---@param o navigator_move_Args
---@return "start" | "end"
local function find_cursor_node_point_for_sibling(o)
    local destination_on_node = "start"
    if
        string.find(o.destination, "previous")
        and not lib_ts.node_start_and_end_on_same_line(catalyst.node())
    then
        destination_on_node = "end"
    end
    return destination_on_node
end

---@param o navigator_move_Args
---@return "start" | "end"
local function find_node_point_for_parent(o)
    local destination_on_node = "end"
    if
        string.find(o.destination, "previous")
        and not lib_ts.node_start_and_end_on_same_line(catalyst.node())
    then
        destination_on_node = "start"
    end
    return destination_on_node
end

---@param o navigator_move_Args
local function change_catalyst_node_to_its_sibling(o)
    local sibling_direction = string.find(o.destination, "next") and "next" or "previous"
    local next_siblings = lib_ts_tsx.get_html_siblings(catalyst.node(), sibling_direction)

    if next_siblings[1] then
        catalyst.set_node(next_siblings[1])
        catalyst.set_node_point(find_cursor_node_point_for_sibling(o))
        return next_siblings[1]
    end
end

---@param o navigator_move_Args
local function change_catalyst_node_to_its_parent(o)
    local parent_node = lib_ts_tsx.get_html_node(catalyst.node():parent())
    if parent_node then
        catalyst.set_node(parent_node)
        catalyst.set_node_point(find_node_point_for_parent(o))
    end

    return parent_node
end

local function change_catalyst_node_to_next_closest_html_element()
    local html_nodes = lib_ts_tsx.get_all_html_nodes_in_buffer(catalyst.buf())
    local _, _, end_row, _ = catalyst.node():range()
    local closest_next_node = find_closest_next_node_to_row(html_nodes, end_row)

    if closest_next_node then
        catalyst.set_node(closest_next_node)
        catalyst.set_node_point("start")
    end
end

local function change_catalyst_node_to_previous_closest_html_element()
    local html_nodes = lib_ts_tsx.get_all_html_nodes_in_buffer(catalyst.buf())
    local start_row = catalyst.node():range()
    local closest_previous_node = find_closest_previous_node_to_row(html_nodes, start_row)

    if closest_previous_node then
        catalyst.set_node(closest_previous_node)
        catalyst.set_node_point("end")
    end
end

---@param o navigator_move_Args
M.move = function(o)
    if not catalyst.is_active() then return end

    if o.destination == "next" then
        local html_children = lib_ts_tsx.get_html_children(catalyst.node())
        if #html_children > 0 then
            if
                lib_ts.cursor_is_at_start_of_node({
                    node = catalyst.node(),
                    win = catalyst.win(),
                })
            then
                catalyst.set_node(html_children[1])
                catalyst.set_node_point("start")
            elseif not change_catalyst_node_to_its_parent(o) then
                change_catalyst_node_to_next_closest_html_element()
            end
        else
            if not change_catalyst_node_to_its_sibling(o) then
                change_catalyst_node_to_its_parent(o)
            end
        end
    elseif o.destination == "previous" then
        if not change_catalyst_node_to_its_sibling(o) then
            if not change_catalyst_node_to_its_parent(o) then
                change_catalyst_node_to_previous_closest_html_element()
            end
        end
    end

    if o.destination == "next-sibling" or o.destination == "previous-sibling" then
        change_catalyst_node_to_its_sibling(o)
    elseif o.destination == "parent" then
        change_catalyst_node_to_its_parent(o)
        catalyst.set_node_point("start")
    end

    catalyst.move_to(o.select_move)
end

return M

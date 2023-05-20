local lib_ts = require("nvim-stormcaller.lib.tree-sitter")
local lib_ts_tsx = require("nvim-stormcaller.lib.tree-sitter.tsx")
local catalyst = require("nvim-stormcaller.lib.catalyst")

local M = {}

---@class navigator_move_Opts
---@field destination "next-sibling" | "previous-sibling" | "next" | "previous" | "parent"

---@class find_closest_previous_or_next_node_to_cursor_Opts
---@field row number
---@field nodes TSNode[]

---@param o find_closest_previous_or_next_node_to_cursor_Opts
---@return TSNode
local function find_closest_next_node_to_row(o)
    local closest_distance, closest_node = math.huge, nil
    for _, node in ipairs(o.nodes) do
        local start_row = node:range()
        if start_row > o.row and math.abs(start_row - o.row) < closest_distance then
            closest_node = node
            closest_distance = math.abs(start_row - o.row)
        end
    end
    return closest_node
end

---@param o find_closest_previous_or_next_node_to_cursor_Opts
---@return TSNode
local function find_closest_previous_node_to_row(o)
    local closest_distance, closest_node = math.huge, nil
    for _, node in ipairs(o.nodes) do
        local _, _, end_row, _ = node:range()
        if end_row < o.row and math.abs(end_row - o.row) < closest_distance then
            closest_node = node
            closest_distance = math.abs(end_row - o.row)
        end
    end
    return closest_node
end

---@param o navigator_move_Opts
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

---@param o navigator_move_Opts
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

---@param o navigator_move_Opts
local function change_cursor_node_to_its_sibling(o)
    local sibling_destination = string.find(o.destination, "next") and "next" or "previous"
    local next_siblings = lib_ts.find_named_siblings_in_direction_with_types({
        node = catalyst.node(),
        direction = sibling_destination,
        desired_types = { "jsx_element", "jsx_self_closing_element" },
    })

    if next_siblings[1] then
        catalyst.set_node(next_siblings[1])
        catalyst.set_node_point(find_cursor_node_point_for_sibling(o))
        return next_siblings[1]
    end
end

---@param o navigator_move_Opts
local change_cursor_node_to_its_parent = function(o)
    local parent_node = lib_ts.find_closest_parent_with_types({
        node = catalyst.node():parent(),
        desired_parent_types = { "jsx_element", "jsx_fragment" },
    })

    if parent_node then
        catalyst.set_node(parent_node)
        catalyst.set_node_point(find_node_point_for_parent(o))
    end

    return parent_node
end

local function change_cursor_node_to_next_closest_jsx_element()
    local jsx_nodes = lib_ts_tsx.get_all_jsx_nodes_in_buffer(catalyst.buf())
    local _, _, end_row, _ = catalyst.node():range()
    local closest_next_node = find_closest_next_node_to_row({ row = end_row, nodes = jsx_nodes })

    if closest_next_node then
        catalyst.set_node(closest_next_node)
        catalyst.set_node_point("start")
    end
end

local function change_cursor_node_to_previous_closest_jsx_element()
    local jsx_nodes = lib_ts_tsx.get_all_jsx_nodes_in_buffer(catalyst.buf())
    local start_row = catalyst.node():range()
    local closest_previous_node = find_closest_previous_node_to_row({
        row = start_row,
        nodes = jsx_nodes,
    })

    if closest_previous_node then
        catalyst.set_node(closest_previous_node)
        catalyst.set_node_point("end")
    end
end

---@param o navigator_move_Opts
M.move = function(o)
    if not catalyst.is_active() then return end

    if o.destination == "next" then
        local jsx_children = lib_ts.get_children_with_types({
            node = catalyst.node(),
            desired_types = { "jsx_element", "jsx_self_closing_element" },
        })

        if #jsx_children > 0 then
            if
                lib_ts.cursor_is_at_start_of_node({
                    node = catalyst.node(),
                    win = catalyst.win(),
                })
            then
                catalyst.set_node(jsx_children[1])
                catalyst.set_node_point("start")
            elseif not change_cursor_node_to_its_parent(o) then
                change_cursor_node_to_next_closest_jsx_element()
            end
        else
            if not change_cursor_node_to_its_sibling(o) then change_cursor_node_to_its_parent(o) end
        end
    elseif o.destination == "previous" then
        if not change_cursor_node_to_its_sibling(o) then
            if not change_cursor_node_to_its_parent(o) then
                change_cursor_node_to_previous_closest_jsx_element()
            end
        end
    end

    if o.destination == "next-sibling" or o.destination == "previous-sibling" then
        change_cursor_node_to_its_sibling(o)
    elseif o.destination == "parent" then
        change_cursor_node_to_its_parent(o)
        catalyst.set_node_point("start")
    end

    catalyst.move_to()
end

return M

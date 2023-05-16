local ts_utils = require("nvim-treesitter.ts_utils")
local lib_ts = require("nvim-stormcaller.lib.tree-sitter")

local M = {}

---@class _catalyst
---@field node TSNode
---@field win number
---@field buf number
---@field node_point "start" | "end"

local _catalyst

M.get_catalyst = function() return _catalyst end

---@param o _catalyst
M.update_catalyst = function(o) _catalyst = o end

M.move_cursor_to_catalyst = function()
    lib_ts.put_cursor_at_node({
        node = _catalyst.node,
        destination = _catalyst.node_point,
        win = _catalyst.win,
    })
end

---@class find_closest_node_to_cursor_Opts
---@field win number
---@field row_offset number
---@field nodes TSNode[]

local function find_closest_node_to_cursor(o)
    local row_offset = o.row_offset or 0

    local cur_line = unpack(vim.api.nvim_win_get_cursor(o.win)) + row_offset
    local closest_distance, closest_node, jump_destination = math.huge, nil, nil

    for _, node in ipairs(o.nodes) do
        local start_row, _, end_row, _ = node:range()
        if math.abs(start_row - cur_line) < closest_distance then
            closest_node = node
            jump_destination = "start"
            closest_distance = math.abs(start_row - cur_line)
        end
        if math.abs(end_row - cur_line) < closest_distance then
            closest_node = node
            jump_destination = "end"
            closest_distance = math.abs(end_row - cur_line)
        end
    end

    return closest_node, jump_destination
end

---@class find_closest_jsx_node_to_cursor_Opts
---@field buf number
---@field win number

---@param o find_closest_jsx_node_to_cursor_Opts
---@return TSNode[]
local function get_all_jsx_nodes_in_buffer(o)
    local all_jsx_nodes = lib_ts.capture_nodes_with_queries({
        buf = o.buf,
        parser_name = "tsx",
        queries = {
            "(jsx_fragment) @jsx_fragment",
            "(jsx_element) @jsx_element",
            "(jsx_self_closing_element) @jsx_self_closing_element",
        },
        capture_groups = { "jsx_element", "jsx_self_closing_element", "jsx_fragment" },
    })
    return all_jsx_nodes
end

---@param o find_closest_jsx_node_to_cursor_Opts
---@return table, string
local find_closest_jsx_node_to_cursor = function(o)
    local jsx_nodes = get_all_jsx_nodes_in_buffer(o)
    return find_closest_node_to_cursor({ nodes = jsx_nodes, win = o.win })
end

---@class navigator_initiate_Opts
---@field win number
---@field buf number

---@param o navigator_initiate_Opts
M.initiate = function(o)
    vim.cmd("norm! ^")

    local current_node = ts_utils.get_node_at_cursor(0)
    local parent = lib_ts.find_closest_parent_with_types({
        node = current_node,
        desired_parent_types = { "jsx_element", "jsx_self_closing_element" },
    })

    if parent then
        M.update_catalyst({ node = parent, win = o.win, buf = o.buf, node_point = "start" })
        M.move_cursor_to_catalyst()
    else
        local closest_node, destination =
            find_closest_jsx_node_to_cursor({ win = o.win, buf = o.buf })
        M.update_catalyst({
            node = closest_node,
            win = o.win,
            buf = o.buf,
            node_point = destination,
        })
        M.move_cursor_to_catalyst()
    end
end

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
        and not lib_ts.node_start_and_end_on_same_line(_catalyst.node)
    then
        destination_on_node = "end"
    end
    return destination_on_node
end

---@param o navigator_move_Opts
---@return "start" | "end"
local function find_cursor_node_point_for_parent(o)
    local destination_on_node = "end"
    if
        string.find(o.destination, "previous")
        and not lib_ts.node_start_and_end_on_same_line(_catalyst.node)
    then
        destination_on_node = "start"
    end
    return destination_on_node
end

---@param o navigator_move_Opts
local function change_cursor_node_to_its_sibling(o)
    local sibling_destination = string.find(o.destination, "next") and "next" or "previous"
    local next_siblings = lib_ts.find_named_siblings_in_direction_with_types({
        node = _catalyst.node,
        direction = sibling_destination,
        desired_types = { "jsx_element", "jsx_self_closing_element" },
    })

    if next_siblings[1] then
        _catalyst.node = next_siblings[1]
        _catalyst.node_point = find_cursor_node_point_for_sibling(o)
        return next_siblings[1]
    end
end

---@param o navigator_move_Opts
local change_cursor_node_to_its_parent = function(o)
    local parent_node = lib_ts.find_closest_parent_with_types({
        node = _catalyst.node:parent(),
        desired_parent_types = { "jsx_element", "jsx_fragment" },
    })

    if parent_node then
        _catalyst.node = parent_node
        _catalyst.node_point = find_cursor_node_point_for_parent(o)
    end

    return parent_node
end

local function change_cursor_node_to_next_closest_jsx_element()
    local jsx_nodes = get_all_jsx_nodes_in_buffer({ buf = _catalyst.buf, win = _catalyst.win })
    local _, _, end_row, _ = _catalyst.node:range()
    local closest_next_node = find_closest_next_node_to_row({ row = end_row, nodes = jsx_nodes })

    if closest_next_node then
        _catalyst.node = closest_next_node
        _catalyst.node_point = "start"
    end
end

local function change_cursor_node_to_previous_closest_jsx_element()
    local jsx_nodes = get_all_jsx_nodes_in_buffer({ buf = _catalyst.buf, win = _catalyst.win })
    local start_row = _catalyst.node:range()
    local closest_previous_node = find_closest_previous_node_to_row({
        row = start_row,
        nodes = jsx_nodes,
    })

    if closest_previous_node then
        _catalyst.node = closest_previous_node
        _catalyst.node_point = "end"
    end
end

---@param o navigator_move_Opts
M.move = function(o)
    if o.destination == "next" then
        local jsx_children = lib_ts.get_children_with_types({
            node = _catalyst.node,
            desired_types = { "jsx_element", "jsx_self_closing_element" },
        })

        if #jsx_children > 0 then
            if
                lib_ts.cursor_is_at_start_of_node({
                    node = _catalyst.node,
                    win = _catalyst.win,
                })
            then
                _catalyst.node = jsx_children[1]
                _catalyst.node_point = "start"
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
        _catalyst.node_point = "start"
    end

    M.move_cursor_to_catalyst()
end

return M

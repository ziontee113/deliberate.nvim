local ts_utils = require("nvim-treesitter.ts_utils")
local lib_ts = require("nvim-stormcaller.lib.tree-sitter")

local M = {}

local _cursor_node

M.get_cursor_node = function() return _cursor_node end

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
        lib_ts.put_cursor_at_node({ node = parent, win = o.win, destination = "start" })
        _cursor_node = parent
    else
        local closest_node, destination = find_closest_jsx_node_to_cursor({
            win = o.win,
            buf = o.buf,
        })
        lib_ts.put_cursor_at_node({
            destination = destination,
            win = o.win,
            node = closest_node,
        })
        _cursor_node = closest_node
    end
end

---@class navigator_move_Opts
---@field win number
---@field buf number
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
local function find_destination_on_node_for_sibling(o)
    local destination_on_node = "start"
    if
        string.find(o.destination, "previous")
        and not lib_ts.node_start_and_end_on_same_line(_cursor_node)
    then
        destination_on_node = "end"
    end
    return destination_on_node
end

---@param o navigator_move_Opts
---@return "start" | "end"
local function find_destination_on_node_for_parent(o)
    local destination_on_node = "end"
    if
        string.find(o.destination, "previous")
        and not lib_ts.node_start_and_end_on_same_line(_cursor_node)
    then
        destination_on_node = "start"
    end
    return destination_on_node
end

local _destination_on_node

---@param o navigator_move_Opts
local function iterate_cursor_node_to_its_sibling(o)
    local sibling_destination = string.find(o.destination, "next") and "next" or "previous"
    local next_siblings = lib_ts.find_named_siblings_in_direction_with_types({
        node = _cursor_node,
        direction = sibling_destination,
        desired_types = { "jsx_element", "jsx_self_closing_element" },
    })

    if next_siblings[1] then
        _cursor_node = next_siblings[1]
        _destination_on_node = find_destination_on_node_for_sibling(o)
        return next_siblings[1]
    end
end

---@param o navigator_move_Opts
local iter_cursor_node_to_its_parent = function(o)
    local parent_node = lib_ts.find_closest_parent_with_types({
        node = _cursor_node:parent(),
        desired_parent_types = { "jsx_element", "jsx_fragment" },
    })

    if parent_node then
        _cursor_node = parent_node
        _destination_on_node = find_destination_on_node_for_parent(o)
    end

    return parent_node
end

---@param o navigator_move_Opts
local function iter_curor_node_to_next_closest_jsx_element(o)
    local jsx_nodes = get_all_jsx_nodes_in_buffer({ buf = o.buf, win = o.win })
    local _, _, end_row, _ = _cursor_node:range()
    local closest_next_node = find_closest_next_node_to_row({
        row = end_row,
        nodes = jsx_nodes,
    })

    if closest_next_node then
        _cursor_node = closest_next_node
        _destination_on_node = "start"
    end
end

---@param o navigator_move_Opts
local function iter_curor_node_to_previous_closest_jsx_element(o)
    local jsx_nodes = get_all_jsx_nodes_in_buffer({ buf = o.buf, win = o.win })
    local start_row = _cursor_node:range()
    local closest_previous_node = find_closest_previous_node_to_row({
        row = start_row,
        nodes = jsx_nodes,
    })

    if closest_previous_node then
        _cursor_node = closest_previous_node
        _destination_on_node = "end"
    end
end

---@param o navigator_move_Opts
M.move = function(o)
    if o.destination == "next" then
        local jsx_children = lib_ts.get_children_with_types({
            node = _cursor_node,
            desired_types = { "jsx_element", "jsx_self_closing_element" },
        })

        if #jsx_children > 0 then
            if lib_ts.cursor_at_start_of_node({ node = _cursor_node, win = o.win }) then
                _cursor_node = jsx_children[1]
            elseif not iter_cursor_node_to_its_parent(o) then
                iter_curor_node_to_next_closest_jsx_element(o)
            end
        else
            if not iterate_cursor_node_to_its_sibling(o) then iter_cursor_node_to_its_parent(o) end
        end
    elseif o.destination == "previous" then
        if not iterate_cursor_node_to_its_sibling(o) then
            if not iter_cursor_node_to_its_parent(o) then
                iter_curor_node_to_previous_closest_jsx_element(o)
            end
        end
    end

    if o.destination == "next-sibling" or o.destination == "previous-sibling" then
        iterate_cursor_node_to_its_sibling(o)
    elseif o.destination == "parent" then
        iter_cursor_node_to_its_parent(o)
        _destination_on_node = "start"
    end

    if _destination_on_node then
        lib_ts.put_cursor_at_node({
            node = _cursor_node,
            destination = _destination_on_node,
            win = o.win,
        })
    end
end

return M

local M = {}

local ts_utils = require("nvim-treesitter.ts_utils")
local lib_ts = require("stormcaller.lib.tree-sitter")
local lib_ts_tsx = require("stormcaller.lib.tree-sitter.tsx")

---@class _catalyst
---@field node TSNode
---@field win number
---@field buf number
---@field node_point "start" | "end"
---@field is_active boolean

local _catalyst
local _selected_nodes = {}

-------------------------------------------- Getters

---@return number
M.buf = function() return _catalyst.buf end

---@return number
M.win = function() return _catalyst.win end

---@return TSNode
M.node = function() return _catalyst.node end

---@return boolean
M.is_active = function() return _catalyst.is_active end

---@return TSNode[]
M.selected_nodes = function() return _selected_nodes end

-------------------------------------------- Setters

M.set_node = function(node) _catalyst.node = node end
M.set_node_point = function(node_point) _catalyst.node_point = node_point end
M.set_buf = function(buf) _catalyst.buf = buf end
M.set_win = function(win) _catalyst.win = win end

M.clear_selection = function() _selected_nodes = {} end

---@param track_selection boolean
local function update_selected_nodes(track_selection)
    if #_selected_nodes == 0 then
        table.insert(_selected_nodes, _catalyst.node)
    elseif #_selected_nodes == 1 and not track_selection then
        _selected_nodes = { _catalyst.node }
    elseif track_selection then
        table.insert(_selected_nodes, _catalyst.node)
    end
end

-------------------------------------------- Actions

---@param track_selection boolean
M.move_to = function(track_selection)
    if not _catalyst then return end

    update_selected_nodes(track_selection)

    lib_ts.put_cursor_at_node({
        node = _catalyst.node,
        destination = _catalyst.node_point,
        win = _catalyst.win,
    })
end

-------------------------------------------- Internals

local get_jsx_node = function(node)
    return lib_ts.find_closest_parent_with_types({
        node = node,
        desired_parent_types = { "jsx_element", "jsx_self_closing_element", "jsx_fragment" },
    })
end

---This function should be called whenever we programatically change buffer content (e.g by using `nvim_buf_set_text()`).
M.refresh_tree = function()
    if #_selected_nodes == 0 then return end

    local updated_root = lib_ts.get_root({ parser_name = "tsx", buf = _catalyst.buf, reset = true })
    for i, node in ipairs(_selected_nodes) do
        local updated_node = lib_ts.reset_node_tree(_catalyst.buf, node, "tsx", updated_root)
        _selected_nodes[i] = get_jsx_node(updated_node)
    end

    local row, col = _catalyst.node:range()
    local updated_node = updated_root:named_descendant_for_range(row, col, row, col)
    _catalyst.node = get_jsx_node(updated_node)
end

-------------------------------------------- Initiate

---@param win number
---@param nodes TSNode[]
---@return TSNode, "start" | "end"
local function find_closest_node_to_cursor(win, nodes)
    local cur_line = unpack(vim.api.nvim_win_get_cursor(win))
    local closest_distance, closest_node, jump_destination = math.huge, nil, nil

    for _, node in ipairs(nodes) do
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

---@param win number
---@param buf number
---@return TSNode[], string
local find_closest_jsx_node_to_cursor = function(win, buf)
    local jsx_nodes = lib_ts_tsx.get_all_jsx_nodes_in_buffer(buf)
    return find_closest_node_to_cursor(win, jsx_nodes)
end

---@class navigator_initiate_Args
---@field win number
---@field buf number

---@param o navigator_initiate_Args
M.initiate = function(o)
    vim.cmd("norm! ^")

    local node_at_cursor = ts_utils.get_node_at_cursor(0)
    local parent = lib_ts.find_closest_parent_with_types({
        node = node_at_cursor,
        desired_parent_types = { "jsx_element", "jsx_self_closing_element" },
    })

    local node, node_point
    if parent then
        node, node_point = parent, "start"
    else
        node, node_point = find_closest_jsx_node_to_cursor(o.win, o.buf)
    end

    _catalyst = {
        win = o.win,
        buf = o.buf,
        node = node,
        node_point = node_point,
        is_active = true,
    }
    M.move_to() -- move cursor to _catalyst's node
end

return M

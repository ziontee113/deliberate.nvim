local M = {}

local selection = require("stormcaller.lib.selection")
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

-------------------------------------------- Getters

---@return number
M.buf = function() return _catalyst.buf end

---@return number
M.win = function() return _catalyst.win end

---@return TSNode
M.node = function() return _catalyst.node end

---@return boolean
M.is_active = function() return _catalyst.is_active end

-------------------------------------------- Setters

M.set_node = function(node)
    _catalyst.node = node
    selection.update_current_catalyst_info(_catalyst.win, _catalyst.buf, node)
end
M.set_node_point = function(node_point) _catalyst.node_point = node_point end
M.set_buf = function(buf) _catalyst.buf = buf end
M.set_win = function(win) _catalyst.win = win end

-------------------------------------------- Actions

---@param select_move boolean | nil
M.move_to = function(select_move)
    if not _catalyst then return end

    selection.update(select_move)

    lib_ts.put_cursor_at_node({
        node = _catalyst.node,
        destination = _catalyst.node_point,
        win = _catalyst.win,
    })
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
local find_closest_html_node_to_cursor = function(win, buf)
    local html_nodes = lib_ts_tsx.get_all_html_nodes_in_buffer(buf)
    return find_closest_node_to_cursor(win, html_nodes)
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
        node, node_point = find_closest_html_node_to_cursor(o.win, o.buf)
    end

    _catalyst = {
        win = o.win,
        buf = o.buf,
        node = node,
        node_point = node_point,
        is_active = true,
    }
    M.move_to() -- move cursor to _catalyst's node

    selection.update_current_catalyst_info(_catalyst.win, _catalyst.buf, node)
    selection.update()
end

return M

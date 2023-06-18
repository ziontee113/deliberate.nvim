local M = {}

local selection = require("deliberate.lib.selection")
local ts_utils = require("nvim-treesitter.ts_utils")
local lib_ts = require("deliberate.lib.tree-sitter")
local aggregator = require("deliberate.lib.tree-sitter.language_aggregator")

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
M.move_to = function(select_move, keep_selection)
    if not _catalyst then return end

    selection.update(select_move, keep_selection)

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
        if closest_distance == 0 then break end
    end

    return closest_node, jump_destination
end

---@param win number
---@param buf number
---@return TSNode[], string
local find_closest_html_node_to_cursor = function(win, buf)
    local html_nodes = aggregator.get_all_html_nodes_in_buffer(buf)
    return find_closest_node_to_cursor(win, html_nodes)
end

local find_node_point = function(win, node)
    local cursor_line = unpack(vim.api.nvim_win_get_cursor(win))
    cursor_line = cursor_line - 1
    local start_row, _, end_row, _ = node:range()

    if start_row == end_row then return "start" end
    if math.abs(cursor_line - start_row) < math.abs(cursor_line - end_row) then
        return "start"
    else
        return "end"
    end
end

local augroup = vim.api.nvim_create_augroup("Deliberate Catalyst", { clear = true })

---@class navigator_initiate_Args
---@field win number
---@field buf number

---@param o navigator_initiate_Args
M.initiate = function(o)
    _catalyst = { buf = o.buf } -- temporary solution so aggregator can work correctly

    vim.cmd("norm! ^")

    aggregator.get_updated_root() -- refresh Language Tree
    local node_at_cursor = ts_utils.get_node_at_cursor(o.win)
    local parent = aggregator.get_html_node(node_at_cursor)

    local node, node_point
    if parent then
        node = parent
        node_point = find_node_point(o.win, parent)
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

    vim.api.nvim_create_autocmd({ "BufLeave" }, {
        buffer = o.buf,
        group = augroup,
        callback = function()
            require("deliberate.hydra").exit_hydra()
        end,
    })
end

return M

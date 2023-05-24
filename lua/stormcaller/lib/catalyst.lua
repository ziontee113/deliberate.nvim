local M = {}

local ts_utils = require("nvim-treesitter.ts_utils")
local lib_ts = require("stormcaller.lib.tree-sitter")
local lib_ts_tsx = require("stormcaller.lib.tree-sitter.tsx")

local ns_hidden = vim.api.nvim_create_namespace("Stormcaller's invisible extmarks")

---@class _catalyst
---@field node TSNode
---@field win number
---@field buf number
---@field node_point "start" | "end"
---@field is_active boolean
---@field extmark_id number

local _catalyst

-- Multi Selection Management --> Need to refactor this after implementing extmark tracking
local _selected_nodes = {}
local _selected_nodes_extmark_ids = {}

local _selection_tracking_state = false

local _latest_catalyst_node
local _latest_catalyst_node_extmark_id

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

M.selection_index_matches_catalyst = function(index)
    return _selected_nodes_extmark_ids[index] == _catalyst.extmark_id
end

-------------------------------------------- Setters

local function set_extmark_for_node(node, buf)
    local start_row, start_col = node:range()
    return vim.api.nvim_buf_set_extmark(buf, ns_hidden, start_row, start_col, {})
end

M.set_node = function(node)
    _catalyst.node = node
    _catalyst.extmark_id = set_extmark_for_node(node, _catalyst.buf)
end
M.set_node_point = function(node_point) _catalyst.node_point = node_point end
M.set_buf = function(buf) _catalyst.buf = buf end
M.set_win = function(win) _catalyst.win = win end

M.clear_everything_for_the_next_test = function()
    _selected_nodes, _selected_nodes_extmark_ids = {}, {}
    _latest_catalyst_node, _latest_catalyst_node_extmark_id = nil, nil
    _selection_tracking_state = false
    vim.api.nvim_buf_clear_namespace(0, ns_hidden, 0, -1)
end

M.update_node_in_selection = function(index, node)
    _selected_nodes[index] = node

    vim.api.nvim_buf_del_extmark(_catalyst.buf, ns_hidden, _selected_nodes_extmark_ids[index])
    _selected_nodes_extmark_ids[index] = set_extmark_for_node(node, _catalyst.buf)
end

M.clear_multi_selection = function()
    _selected_nodes = { _catalyst.node }
    _selected_nodes_extmark_ids = { _catalyst.extmark_id }
    _selection_tracking_state = false
end

---@param track_selection boolean | nil
local function update_selected_nodes(track_selection)
    if #_selected_nodes == 0 then
        table.insert(_selected_nodes, _catalyst.node)
        table.insert(_selected_nodes_extmark_ids, _catalyst.extmark_id)
    else
        if track_selection then
            if not _selection_tracking_state then
                _selection_tracking_state = true
            else
                table.insert(_selected_nodes, _latest_catalyst_node)
                table.insert(_selected_nodes_extmark_ids, _latest_catalyst_node_extmark_id)
            end
        elseif not _selection_tracking_state then
            _selected_nodes = { _catalyst.node }
            _selected_nodes_extmark_ids = { _catalyst.extmark_id }
        end
    end

    _latest_catalyst_node = _catalyst.node
    _latest_catalyst_node_extmark_id = _catalyst.extmark_id
end

-------------------------------------------- Actions

---@param track_selection boolean | nil
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

---This function should be called whenever we programatically change buffer content (e.g by using `nvim_buf_set_text()`).
M.refresh_tree = function()
    if #_selected_nodes == 0 then return end

    local updated_root = lib_ts.get_root({ parser_name = "tsx", buf = _catalyst.buf, reset = true })

    for i, id in ipairs(_selected_nodes_extmark_ids) do
        local row, col =
            unpack(vim.api.nvim_buf_get_extmark_by_id(_catalyst.buf, ns_hidden, id, {}))

        local updated_node = updated_root:named_descendant_for_range(row, col, row, col)
        _selected_nodes[i] = lib_ts_tsx.get_jsx_node(updated_node)
    end

    local row, col = unpack(
        vim.api.nvim_buf_get_extmark_by_id(_catalyst.buf, ns_hidden, _catalyst.extmark_id, {})
    )
    local updated_node = updated_root:named_descendant_for_range(row, col, row, col)
    _catalyst.node = lib_ts_tsx.get_jsx_node(updated_node)
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

    local extmark_id = set_extmark_for_node(node, o.buf)

    _catalyst = {
        win = o.win,
        buf = o.buf,
        node = node,
        node_point = node_point,
        is_active = true,
        extmark_id = extmark_id,
    }
    M.move_to() -- move cursor to _catalyst's node
end

return M

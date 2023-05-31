local aggregator = require("stormcaller.lib.tree-sitter.language_aggregator")
local visual_collector = require("stormcaller.api.visual_collector")
local indicator = require("stormcaller.lib.indicator")

local M = {}

local ns = vim.api.nvim_create_namespace("Stormcaller Selection Namespace")

local select_move_active = false

---@class CatalystInfo
---@field node TSNode
---@field win number
---@field buf number
---@field extmark_id number

---@type CatalystInfo[]
local selection = {}

---@type CatalystInfo
local previous_catalyst_info

---@type CatalystInfo
local current_catalyst_info

---@param buf number
---@param node TSNode
---@return number
local function set_extmark_for_node(buf, node)
    local start_row, start_col = node:range()
    return vim.api.nvim_buf_set_extmark(buf, ns, start_row, start_col, {})
end

---@param win number
---@param buf number
---@param node TSNode
M.update_current_catalyst_info = function(win, buf, node)
    local extmark_id = set_extmark_for_node(buf, node)

    current_catalyst_info = {
        win = win,
        buf = buf,
        node = node,
        extmark_id = extmark_id,
    }
end

---@param a CatalystInfo
---@param b CatalystInfo
---@return boolean
local items_are_identical = function(a, b)
    local row_a, col_a = unpack(vim.api.nvim_buf_get_extmark_by_id(a.buf, ns, a.extmark_id, {}))
    local row_b, col_b = unpack(vim.api.nvim_buf_get_extmark_by_id(b.buf, ns, b.extmark_id, {}))
    return row_a == row_b and col_a == col_b
end

---@param index number
M.item_matches_catalyst = function(index)
    return items_are_identical(selection[index], current_catalyst_info)
end

local remove_unused_extmarks = function()
    if #selection ~= 1 then return end

    local items_to_check = {}
    for _, item in ipairs(selection) do
        table.insert(items_to_check, item)
    end
    table.insert(items_to_check, current_catalyst_info)
    table.insert(items_to_check, previous_catalyst_info)

    local all_extmarks = vim.api.nvim_buf_get_extmarks(current_catalyst_info.buf, ns, 0, -1, {})

    for _, extmark in ipairs(all_extmarks) do
        local match = false
        local id = extmark[1]
        for _, item in ipairs(items_to_check) do
            if item.extmark_id == id then
                match = true
                break
            end
        end
        if not match then vim.api.nvim_buf_del_extmark(current_catalyst_info.buf, ns, id) end
    end
end

---@param item CatalystInfo
local insert_or_remove_item = function(item)
    local match, match_index = false, nil
    for i, selection_item in ipairs(selection) do
        if items_are_identical(selection_item, item) then
            match = true
            match_index = i
            break
        end
    end

    if not match then table.insert(selection, item) end
    if match then table.remove(selection, match_index) end
end

---@param select_move boolean | nil
M.update = function(select_move)
    if visual_collector.is_active() then
        insert_or_remove_item(current_catalyst_info)
        select_move_active = true
    else
        if select_move and select_move_active then insert_or_remove_item(previous_catalyst_info) end

        if select_move and not select_move_active then
            select_move_active = true
            selection = { previous_catalyst_info }
        end

        if not select_move and not select_move_active then selection = { current_catalyst_info } end
    end

    previous_catalyst_info = current_catalyst_info

    remove_unused_extmarks()

    -- indicator.highlight_catalyst(current_catalyst_info)
    indicator.highlight_selection(selection)
end

--------------------------------------------

---@return TSNode[]
M.nodes = function()
    local nodes = {}
    for _, item in ipairs(selection) do
        table.insert(nodes, item.node)
    end
    return nodes
end

---@param root TSNode
---@param row number
---@param col number
---@return TSNode
local get_updated_node_from_position = function(root, row, col)
    local updated_node = root:named_descendant_for_range(row, col, row, col)
    if not updated_node then error("can't return updated_node from given row & col") end
    return aggregator.get_html_node(updated_node)
end

---@param root TSNode
---@param item CatalystInfo
---@return TSNode
local get_updated_node_from_item = function(root, item)
    local row, col = unpack(vim.api.nvim_buf_get_extmark_by_id(item.buf, ns, item.extmark_id, {}))
    return get_updated_node_from_position(root, row, col)
end

---@param index number
---@param row number | nil
---@param col number | nil
---@param updated_node TSNode | nil
M.update_item = function(index, row, col, updated_node)
    if not updated_node then
        local root = aggregator.get_updated_root(current_catalyst_info.buf)
        if not row or not col then error("invalid row & col arguments") end
        updated_node = get_updated_node_from_position(root, row, col)
    end
    selection[index].node = updated_node

    vim.api.nvim_buf_del_extmark(selection[index].buf, ns, selection[index].extmark_id)
    local new_extmark_id = set_extmark_for_node(selection[index].buf, updated_node)
    selection[index].extmark_id = new_extmark_id
end

---This function must be called whenever we programatically change buffer content (e.g by using `nvim_buf_set_text()`).
M.refresh_tree = function()
    if #selection == 0 then return end
    local root = aggregator.get_updated_root(current_catalyst_info.buf)

    for i, item in ipairs(selection) do
        selection[i].node = get_updated_node_from_item(root, item)
    end

    require("stormcaller.lib.catalyst").set_node(
        get_updated_node_from_item(root, current_catalyst_info)
    )
end

M.clear = function(keep_indicators)
    select_move_active = false
    M.update()

    if not keep_indicators and current_catalyst_info then
        indicator.clear(current_catalyst_info.buf)
    end
end

M.select_move_is_active = function() return select_move_active end

return M

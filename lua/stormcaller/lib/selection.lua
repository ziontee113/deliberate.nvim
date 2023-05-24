local lib_ts = require("stormcaller.lib.tree-sitter")
local lib_ts_tsx = require("stormcaller.lib.tree-sitter.tsx")

local M = {}

local ns = vim.api.nvim_create_namespace("Stormcaller Selection Namespace")

local actively_tracking = false

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

local items_are_identical = function(a, b)
    local row_a, col_a = unpack(vim.api.nvim_buf_get_extmark_by_id(a.buf, ns, a.extmark_id, {}))
    local row_b, col_b = unpack(vim.api.nvim_buf_get_extmark_by_id(b.buf, ns, b.extmark_id, {}))
    return row_a == row_b and col_a == col_b
end

M.current_selection_matches_catalyst = function(index)
    return items_are_identical(selection[index], current_catalyst_info)
end

M.update = function(track_selection)
    if track_selection and actively_tracking then
        local match = false

        for _, item in ipairs(selection) do
            if items_are_identical(item, previous_catalyst_info) then
                match = true
                break
            end
        end

        if not match then table.insert(selection, previous_catalyst_info) end
    end

    if track_selection and not actively_tracking then
        actively_tracking = true
        selection = { previous_catalyst_info }
    end

    if not track_selection and not actively_tracking then selection = { current_catalyst_info } end

    previous_catalyst_info = current_catalyst_info
end

--------------------------------------------

M.nodes = function()
    local nodes = {}
    for _, item in ipairs(selection) do
        table.insert(nodes, item.node)
    end
    return nodes
end

M.update_specific_selection_index = function(index, node)
    selection[index].node = node

    vim.api.nvim_buf_del_extmark(selection[index].buf, ns, selection[index].extmark_id)

    local new_extmark_id = set_extmark_for_node(selection[index].buf, node)

    selection[index].extmark_id = new_extmark_id
end

---This function should be called whenever we programatically change buffer content (e.g by using `nvim_buf_set_text()`).
M.refresh_tree = function()
    if #selection == 0 then return end

    local updated_root =
        lib_ts.get_root({ parser_name = "tsx", buf = current_catalyst_info.buf, reset = true })

    if not updated_root then error("we're screwed for not getting updated_root") end

    for i, item in ipairs(selection) do
        local row, col =
            unpack(vim.api.nvim_buf_get_extmark_by_id(item.buf, ns, item.extmark_id, {}))

        local updated_node = updated_root:named_descendant_for_range(row, col, row, col)
        updated_node = lib_ts_tsx.get_jsx_node(updated_node)

        if not updated_node then error("we're screwed for not able to find updated_node") end

        selection[i].node = updated_node
    end

    local row, col = unpack(
        vim.api.nvim_buf_get_extmark_by_id(
            current_catalyst_info.buf,
            ns,
            current_catalyst_info.extmark_id,
            {}
        )
    )
    local updated_node = updated_root:named_descendant_for_range(row, col, row, col)
    if not updated_node then error("can't find updated_node for catalyst") end
    updated_node = lib_ts_tsx.get_jsx_node(updated_node)
    require("stormcaller.lib.catalyst").set_node(updated_node)
end

M.clear = function()
    actively_tracking = false
    M.update()
end

return M

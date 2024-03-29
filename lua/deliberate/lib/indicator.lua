local M = {}

local catalyst_ns = vim.api.nvim_create_namespace("Deliberate Catalyst Namespace")
local pseudo_ns = vim.api.nvim_create_namespace("Deliberate Pseudo Classes Namespace")
local selection_ns = vim.api.nvim_create_namespace("Deliberate Selection Namespace")

local clear_catalyst_namespace = function(buf)
    vim.api.nvim_buf_clear_namespace(buf, catalyst_ns, 0, -1)
end
local clear_selection_namespace = function(buf)
    vim.api.nvim_buf_clear_namespace(buf, selection_ns, 0, -1)
end
local clear_pasudo_namespace = function(buf) vim.api.nvim_buf_clear_namespace(buf, pseudo_ns, 0, -1) end

-------------------------------------------- Pseudo Classes

M.highlight_pseudo_classes = function()
    local catalyst = require("deliberate.lib.catalyst")
    local start_row = catalyst.node():range()
    clear_pasudo_namespace(catalyst.buf())

    local pseudo_classes = require("deliberate.lib.pseudo_classes.manager").get_current()

    if pseudo_classes ~= "" then
        pcall(vim.api.nvim_buf_set_extmark, catalyst.buf(), pseudo_ns, start_row, 0, {
            virt_text = { { "  " .. pseudo_classes, "Normal" } },
            virt_text_pos = "eol",
        })
    end
end

-------------------------------------------- Catalyst

M.highlight_catalyst = function(hl_group)
    local catalyst = require("deliberate.lib.catalyst")
    hl_group = hl_group or "DiffText"

    local start_row, start_col, end_row, end_col = catalyst.node():range()
    clear_catalyst_namespace(catalyst.buf())

    vim.highlight.range(
        catalyst.buf(),
        catalyst_ns,
        hl_group,
        { start_row, start_col },
        { start_row, start_col + 1 }
    )

    vim.highlight.range(
        catalyst.buf(),
        catalyst_ns,
        hl_group,
        { end_row, end_col - 1 },
        { end_row, end_col }
    )
end

-------------------------------------------- Selection

local pick_selection_icon = function()
    if require("deliberate.api.visual_collector").is_active() then return "" end
    if require("deliberate.lib.selection").select_move_is_active() then return "" end
    return "☾"
end

local pick_selection_hl_group = function()
    if require("deliberate.api.visual_collector").is_active() then return "@function" end
    if require("deliberate.lib.selection").select_move_is_active() then return "@float" end
    return "Normal"
end

M.highlight_selection = function()
    local selection = require("deliberate.lib.selection").items()
    if #selection == 0 then return end
    if not require("deliberate.lib.catalyst").node() then return end

    local buf = selection[1].buf
    clear_selection_namespace(buf)

    for _, item in ipairs(selection) do
        local start_row = item.node:range()
        pcall(vim.api.nvim_buf_set_extmark, buf, selection_ns, start_row, 0, {
            virt_text = { { pick_selection_icon(), pick_selection_hl_group() } },
            virt_text_pos = "eol",
        })
    end

    M.highlight_catalyst()
    M.highlight_pseudo_classes()
end

M.clear = function(buf)
    clear_catalyst_namespace(buf)
    clear_selection_namespace(buf)
    clear_pasudo_namespace(buf)
end

return M

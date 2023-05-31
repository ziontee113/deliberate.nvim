local M = {}

local catalyst_ns = vim.api.nvim_create_namespace("Deliberate Catalyst Namespace")

local clear_catalyst_namespace = function(buf)
    vim.api.nvim_buf_clear_namespace(buf, catalyst_ns, 0, -1)
end

---@param catalyst_info CatalystInfo
M.highlight_catalyst = function(catalyst_info, hl_group)
    if not catalyst_info then return end
    hl_group = hl_group or "DiffText"

    local start_row, start_col, end_row, end_col = catalyst_info.node:range()
    clear_catalyst_namespace(catalyst_info.buf)

    vim.highlight.range(
        catalyst_info.buf,
        catalyst_ns,
        hl_group,
        { start_row, start_col },
        { start_row, start_col + 1 }
    )

    vim.highlight.range(
        catalyst_info.buf,
        catalyst_ns,
        hl_group,
        { end_row, end_col - 1 },
        { end_row, end_col }
    )
end

M.clear = function(buf)
    clear_catalyst_namespace(buf)
    -- TODO: clear selection namespace
end

return M

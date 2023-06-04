local M = {}

---@class ExtmarkPosition
---@field row number
---@field col number

---@type ExtmarkPosition[][]
local archive = {}

---@param selection CatalystInfo[]
M.push = function(selection, ns)
    local state = {}

    if #selection > 0 then
        local buf = selection[1].buf
        for _, item in ipairs(selection) do
            local pos = vim.api.nvim_buf_get_extmark_by_id(buf, ns, item.extmark_id, {})
            table.insert(state, pos)
        end
    end

    table.insert(archive, state)
end

M.pop = function()
    local latest = archive[#archive]
    table.remove(archive, #archive)
    return latest
end
M.clear = function() archive = {} end

return M

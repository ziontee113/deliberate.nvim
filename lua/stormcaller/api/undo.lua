local selection = require("stormcaller.lib.selection")

local M = {}

M.call = function()
    vim.cmd("undo")

    -- TODO:

    selection.restore_previous_state()
end

return M

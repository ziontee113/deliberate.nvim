local selection = require("deliberate.lib.selection")

local M = {}

M.call = function(testing)
    vim.cmd("undo")
    local ok = selection.restore_previous_state()
    if not testing and not ok then require("deliberate.hydra").exit_hydra() end
end

return M

local selection = require("deliberate.lib.selection")

local M = {}

M.undo = function(testing)
    vim.cmd("undo")
    local should_exit = selection.restore_previous_state()
    if not testing then
        if should_exit then require("deliberate.hydra").exit_hydra() end
    end
end

return M

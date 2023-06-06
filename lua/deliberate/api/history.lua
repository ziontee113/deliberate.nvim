local selection = require("deliberate.lib.selection")

local M = {}

local exit_hyra = function(testing, should_exit)
    if not testing then
        if should_exit then require("deliberate.hydra").exit_hydra() end
    end
end

M.undo = function(testing)
    selection.archive_for_redo()

    vim.cmd("undo")
    local should_exit = selection.undo()

    exit_hyra(testing, should_exit)
end

M.redo = function(testing)
    selection.archive_for_undo()

    vim.cmd("redo")
    local should_exit = selection.redo()

    exit_hyra(testing, should_exit)
end

return M

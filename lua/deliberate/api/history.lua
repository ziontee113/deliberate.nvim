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

M.redo = function()
    if #require("deliberate.lib.selection.extmark_archive").redo_stack() == 0 then return end

    selection.archive_for_undo()

    vim.cmd("redo")
    selection.redo()
end

return M

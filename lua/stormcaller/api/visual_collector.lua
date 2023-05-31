local M = {}

local visual_collector_active = false
local selection = require("stormcaller.lib.selection")

M.start = function()
    visual_collector_active = true
    if selection.select_move_is_active() then selection.update() end
end
M.stop = function()
    visual_collector_active = false
    selection.update()
end
M.toggle = function()
    if visual_collector_active then
        M.stop()
    else
        M.start()
    end
end

M.is_active = function() return visual_collector_active end

return M

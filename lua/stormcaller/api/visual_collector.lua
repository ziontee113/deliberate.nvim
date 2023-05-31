local M = {}

local visual_collector_active = false

M.start = function()
    visual_collector_active = true
    if require("stormcaller.lib.selection").select_move_is_active() then
        require("stormcaller.lib.selection").update()
    end
end
M.stop = function()
    visual_collector_active = false
    require("stormcaller.lib.selection").update()
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

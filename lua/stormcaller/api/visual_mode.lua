local M = {}

local visual_mode_active = false

M.on = function()
    visual_mode_active = true
    if require("stormcaller.lib.selection").select_move_is_active() then
        require("stormcaller.lib.selection").update()
    end
end
M.off = function()
    visual_mode_active = false
    require("stormcaller.lib.selection").update()
end
M.toogle = function()
    if visual_mode_active then
        M.off()
    else
        M.on()
    end
end

M.is_active = function() return visual_mode_active end

return M

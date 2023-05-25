local M = {}

local visual_mode_active = false

M.toogle = function() visual_mode_active = not visual_mode_active end
M.on = function() visual_mode_active = true end
M.off = function()
    visual_mode_active = false
    require("stormcaller.lib.selection").update()
end

M.is_active = function() return visual_mode_active end

return M

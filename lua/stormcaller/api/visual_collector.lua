local M = {}

local visual_collector_active = false
local selection = require("stormcaller.lib.selection")

local collected_items = {}

---@param item CatalystInfo
M.collect = function(item) table.insert(collected_items, item) end

---@param index integer
M.remove = function(index)
    if index then table.remove(collected_items, index) end
end

---@return CatalystInfo[]
M.collection = function() return collected_items end

M.start = function()
    visual_collector_active = true
    table.insert(collected_items, selection.current_catalyst_info())

    if not selection.select_move_is_active() then
        require("stormcaller.lib.indicator").highlight_selection(selection.items())
    else
        selection.update()
    end
end
M.stop = function()
    visual_collector_active = false
    selection.update()
    collected_items = {}
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

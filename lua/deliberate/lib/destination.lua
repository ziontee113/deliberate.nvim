local M = {}

---@type "next" | "previous" | "inside"
local current_destination = "next"

---@param destination "next" | "previous" | "inside"
M.set = function(destination)
    current_destination = destination
    require("deliberate.lib.indicator").highlight_destination()
end

---@return "next" | "previous" | "inside"
M.get = function() return current_destination end

M.cycle_next_prev = function()
    if current_destination ~= "next" then
        M.set("next")
    else
        M.set("previous")
    end
end

M.cycle_next_inside = function()
    if current_destination ~= "next" then
        M.set("next")
    else
        M.set("inside")
    end
end

return M

local M = {}

---@type "next-sibling" | "previous-sibling" | "next" | "previous" | "parent"
local current_destination = "next"

---@param destination "next-sibling" | "previous-sibling" | "next" | "previous" | "parent"
M.set = function(destination)
    current_destination = destination
    require("deliberate.lib.indicator").highlight_destination()
end

---@return "next-sibling" | "previous-sibling" | "next" | "previous" | "parent"
M.get = function() return current_destination end

M.cycle_next_prev = function()
    if current_destination ~= "next" then
        M.set("next")
    else
        M.set("previous")
    end
end

M.cycle_next_parent = function()
    if current_destination ~= "next" then
        M.set("next")
    else
        M.set("parent")
    end
end

return M

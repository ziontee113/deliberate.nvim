local utils = require("stormcaller.lib.utils")

local M = {}

local find_classes_to_remove = function(tbl)
    local to_remove, map = {}, {}

    for _, str in ipairs(tbl) do
        local splits = vim.split(str, " ")
        for _, split in ipairs(splits) do
            if split ~= "" and not map[split] then
                map[split] = true
                table.insert(to_remove, split)
            end
        end
    end

    table.sort(to_remove)
    return to_remove
end

---@param input string | string[]
---@param tbl string[]
---@param choice string
---@return string
M.apply = function(input, tbl, choice)
    local classes_to_remove = find_classes_to_remove(tbl)

    local classes
    if type(input) == "string" then
        classes = vim.split(input, " ")
    else
        classes = input
    end

    for i = #classes, 1, -1 do
        for _, class in ipairs(classes_to_remove) do
            if classes[i] == class then
                table.remove(classes, i)
                break
            end
        end
    end

    local choice_split = vim.split(choice, " ")
    choice = table.concat(utils.remove_empty_strings(choice_split), " ")

    table.insert(classes, choice)

    classes = utils.remove_empty_strings(classes)

    local output = table.concat(classes, " ")
    return output
end

return M

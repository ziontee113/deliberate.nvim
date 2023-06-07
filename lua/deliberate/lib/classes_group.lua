local utils = require("deliberate.lib.utils")

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

local get_classes_from_input = function(input)
    local classes
    if type(input) == "string" then
        classes = vim.split(input, " ")
    else
        classes = input
    end
    return classes
end

local remove_classes = function(
    classes,
    classes_to_remove,
    current_pseudo_classes,
    negative_patterns
)
    for i = #classes, 1, -1 do
        local pseudo_prefix, class = utils.pseudo_split(classes[i])
        for _, class_to_remove in ipairs(classes_to_remove) do
            if class == class_to_remove and pseudo_prefix == current_pseudo_classes then
                table.remove(classes, i)
                goto continue
            end
            for _, pattern in ipairs(negative_patterns or {}) do
                if string.match(class, pattern) and pseudo_prefix == current_pseudo_classes then
                    table.remove(classes, i)
                    goto continue
                end
            end
            ::continue::
        end
    end

    return classes
end

local function get_choice(choice, current_pseudo_classes)
    local choice_split = vim.split(choice, " ")
    for i, _ in ipairs(choice_split) do
        if choice_split[i] ~= "" then
            choice_split[i] = current_pseudo_classes .. choice_split[i]
        end
    end
    choice = table.concat(utils.remove_empty_strings(choice_split), " ")
    return choice
end

---@param input string | string[]
---@param tbl string[]
---@param choice string
---@param negative_patterns string[] | nil
---@return string
M.apply = function(input, tbl, choice, negative_patterns)
    local current_pseudo_classes = require("deliberate.lib.pseudo_classes.manager").get_current()
    local classes_to_remove = find_classes_to_remove(tbl)
    local classes = get_classes_from_input(input)
    choice = get_choice(choice, current_pseudo_classes)

    classes = remove_classes(classes, classes_to_remove, current_pseudo_classes, negative_patterns)
    table.insert(classes, choice)
    classes = utils.remove_empty_strings(classes)

    return table.concat(classes, " ")
end

return M

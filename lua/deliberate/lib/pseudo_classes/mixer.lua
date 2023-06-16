local M = {}

local dictionary = {
    ["g"] = "group-",
    ["A"] = "after",
    ["B"] = "before",
    ["h"] = "hover",
    ["fo"] = "focus",
    ["ac"] = "active",
    ["v"] = "visited",
    ["t"] = "target",
    ["fw"] = "focus-within",
    ["fv"] = "focus-within",
    ["em"] = "empty",
    ["ds"] = "disabled",
    ["en"] = "enabled",
    ["ch"] = "checked",
    ["in"] = "intermediate",
    ["df"] = "default",
    ["re"] = "required",
    ["vl"] = "valid",
    ["iv"] = "invalid",
    ["ir"] = "in-range",
    ["or"] = "out-of-range",
    ["ps"] = "placeholder-shown",
    ["af"] = "autofill",
    ["ro"] = "read-only",
    ["F"] = "first",
    ["L"] = "last",
    ["on"] = "only",
    ["od"] = "odd",
    ["ev"] = "even",
    ["ft"] = "first-of-type",
    ["lo"] = "last-of-type",
    ["oo"] = "only-of-type",
    ["fl"] = "first-letter",
    ["fL"] = "first-line",
    ["mr"] = "marker",
    ["sl"] = "selection",
    ["fi"] = "file",
    ["bd"] = "backdrop",
    ["ph"] = "placeholder",
    ["s"] = "sm",
    ["m"] = "md",
    ["l"] = "lg",
    ["x"] = "xl",
    ["2"] = "2xl",
    ["D"] = "dark",
    ["P"] = "portrait",
    ["ns"] = "landscape",
}

M.translate_alias_string = function(input)
    local result = ""
    local i, pending_index = 1, 1
    while true do
        if i > #input then break end

        local alias = string.sub(input, pending_index, i)
        local pseudo_class = dictionary[alias]

        if pseudo_class then
            if string.find(pseudo_class, "group%-") then
                result = result .. pseudo_class
            else
                result = result .. pseudo_class .. ":"
            end
            pending_index = i + 1
        end

        i = i + 1
    end
    return result
end

return M

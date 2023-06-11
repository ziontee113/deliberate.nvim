local lua_patterns = require("deliberate.lib.lua_patterns")
local utils = require("deliberate.lib.utils")
local M = {}

local input_matches_css_color = function(input)
    return vim.tbl_contains(lua_patterns.css_colors, input)
end

-------------------------------------------- Input to Color

M.input_to_color = function(input)
    if input_matches_css_color(input) then return input end

    if input == "" then input = "000" end

    local _, commas = string.gsub(input, ",", "")
    if commas > 0 then
        if commas == 3 then
            return string.format("rgba(%s%%)", input)
        else
            local split = vim.split(input, ",")
            split = utils.remove_empty_strings(split)
            if #split < 2 then table.insert(split, split[1]) end
            if #split < 3 then table.insert(split, split[1]) end

            return string.format("rgb(%s)", table.concat(split, ","))
        end
    end

    local _, dots = string.gsub(input, "%.", "")
    if dots > 0 then
        local split = vim.split(input, "%.")
        split = utils.remove_empty_strings(split)
        if #split < 2 then table.insert(split, split[1]) end
        if #split < 3 then table.insert(split, split[1]) end

        if #split == 3 then
            return string.format("hsl(%s,%s%%,%s%%)", unpack(split))
        elseif #split == 4 then
            return string.format("hsla(%s,%s%%,%s%%,%s%%)", unpack(split))
        end
    end

    return string.format("#%s", input)
end

-------------------------------------------- Input to PMS

local handle_flex = function(input)
    local split = vim.split(input, " ")
    split = utils.remove_empty_strings(split)

    if not split[2] then split[2] = split[1] end
    if not split[3] then split[3] = "0" end

    return string.format("%s_%s_%s%%", unpack(split))
end

local raw_input_group = {
    "grow",
    "shrink",
    "order",
    "aspect-ratio",
    "z",
    "grid-cols",
    "col-span",
    "col-start",
    "col-end",
    "grid-rows",
    "row-span",
    "row-start",
    "row-end",
    "auto-rows",
    "auto-cols",
    "bg",
    "box-shadow",
    "brightness",
    "backdrop-brightness",
    "contrast",
    "backdrop-contrast",
    "grayscale",
    "backdrop-grayscale",
    "hue-rotate",
    "invert",
    "saturate",
    "sepia",
}

local input_to_pms_value = function(input, property)
    if not property then property = "" end

    if property == "content" then
        if input == "" then input = "'single_quotes_matters'" end
        input = string.gsub(input, "%s", "_")
        return input
    end
    if vim.tbl_contains(raw_input_group, property) then
        if input == "" then input = "0" end
        return input
    end
    if string.find(property, "flex") then return handle_flex(input) end
    if property == "font" then return string.format("'%s'", input) end
    if string.find(property, "opacity") then
        local value = tonumber(input) or 0
        return value .. "%"
    end
    if string.find(property, "image") then return string.format("url(%s)", input) end
    if property == "line-clamp" then return tostring(tonumber(input) or 0) end
    if tonumber(input) then return input .. "px" end

    local num, chars = 0, "px"
    local _, idx = string.find(input, "[^%d%.]+")
    if idx then
        num = tonumber(string.sub(input, 1, idx - 1)) or 0.5
        chars = string.sub(input, idx)
    else
        if input == "." then
            return "0.5rem"
        else
            local match = string.match(input, "[^%.]")
            print(vim.inspect(match))
        end
    end

    print(chars)

    --stylua: ignore
    local unit_tbl = {
        w = "vw",  vw = "vw",
        h = "vh",  vh = "vh",
        e = "em",  em = "em",
        r = "rem", re = "rem", rem = "rem",
        x = "px",  px = "px",  z = "px",
        p = "pt",  pt = "pt",  t = "pt",
        P = "%", ["%"] = "%"
    }
    local unit = unit_tbl[chars] or "px"

    return num .. unit
end

M.input_to_pms_value = function(input, property)
    local negative_prefix = ""
    if string.sub(input, 1, 1) == "-" then
        negative_prefix = "-"
        input = string.sub(input, 2) or ""
    end

    return negative_prefix .. input_to_pms_value(input, property)
end

M.wrap_value_in_property = function(color, property)
    return string.format("%s-[%s]", property, color)
end

return M

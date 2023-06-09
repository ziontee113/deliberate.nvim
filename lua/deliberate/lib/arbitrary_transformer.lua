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

M.input_to_pms_value = function(input, property)
    if input == "" then input = "0" end
    if not property then property = "" end

    if string.find(property, "flex") then return handle_flex(input) end
    if string.find(property, "opacity") then return input .. "%" end
    if tonumber(input) then return input .. "px" end

    local _, idx = string.find(input, "%D")
    local num = tonumber(string.sub(input, 1, idx - 1))
    local chars = string.sub(input, idx)

    --stylua: ignore
    local unit_tbl = {
        w = "vw",  vw = "vw",
        h = "vh",  vh = "vh",
        e = "em",  em = "em",
        r = "rem", re = "rem", rem = "rem",
        x = "px",  px = "px",  z = "px",
        p = "pt",  pt = "pt",  t = "pt",
    }
    return num .. unit_tbl[chars]
end

M.wrap_value_in_property = function(color, property)
    return string.format("%s-[%s]", property, color)
end

return M

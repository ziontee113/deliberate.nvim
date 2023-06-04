local M = {}

local input_matches_css_color = function(input)
    local lua_patterns = require("deliberate.lib.lua_patterns")
    return vim.tbl_contains(lua_patterns.css_colors, input)
end

M.input_to_color = function(input)
    if input_matches_css_color(input) then return input end

    local _, commas = string.gsub(input, ",", "")
    if commas > 0 then
        if commas == 3 then
            return string.format("rgba(%s%%)", input)
        else
            return string.format("rgb(%s)", input)
        end
    end

    local _, dots = string.gsub(input, ".", "")
    if dots > 0 then
        local split = vim.split(input, "%.")
        if #split == 3 then
            return string.format("hsl(%s,%s%%,%s%%)", unpack(split))
        elseif #split == 4 then
            return string.format("hsla(%s,%s%%,%s%%,%s%%)", unpack(split))
        end
    end

    return string.format("#%s", input)
end

M.input_to_pms_value = function(input)
    if input == "" then input = "0" end

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

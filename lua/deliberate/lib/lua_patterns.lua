local M = {
    font_weight = {
        "font-thin",
        "font-extralight",
        "font-light",
        "font-normal",
        "font-medium",
        "font-semibold",
        "font-bold",
        "font-extrabold",
        "font-black",
    },
    text_decoration = {
        "underline",
        "overline",
        "line-through",
        "no-underline",
    },
    font_style = {
        "italic",
        "not-italic",
    },

    ----------------------------------

    --stylua: ignore
    css_colors = {
        "black", "silver", "gray", "white", "maroon", "red", "purple", "fuchsia",
        "green", "lime", "olive", "yellow", "navy",
        "blue", "teal", "aqua", "aliceblue", "antiquewhite",
        "aqua", "aquamarine", "azure", "beige", "bisque",
        "black", "blanchedalmond", "blue", "blueviolet", "brown", "burlywood",
        "cadetblue", "chartreuse", "chocolate", "coral", "cornflowerblue",
        "cornsilk", "crimson", "cyan", "darkblue", "darkcyan", "darkgoldenrod",
        "darkgray", "darkgreen", "darkgrey", "darkkhaki", "darkmagenta",
        "darkolivegreen", "darkorange", "darkorchid", "darkred", "darksalmon",
        "darkseagreen", "darkslateblue", "darkslategray", "darkslategrey",
        "darkturquoise", "darkviolet", "deeppink", "deepskyblue", "dimgray",
        "dimgrey", "dodgerblue", "firebrick", "floralwhite", "forestgreen",
        "fuchsia", "gainsboro", "ghostwhite", "gold", "goldenrod", "gray",
        "green", "greenyellow", "grey", "honeydew", "hotpink", "indianred",
        "indigo", "ivory", "khaki", "lavender", "lavenderblush", "lawngreen",
        "lemonchiffon", "lightblue", "lightcoral", "lightcyan", "lightgoldenrodyellow",
        "lightgray", "lightgreen", "lightgrey", "lightpink", "lightsalmon",
        "lightseagreen", "lightskyblue", "lightslategray", "lightslategrey",
        "lightsteelblue", "lightyellow", "lime", "limegreen", "linen",
        "magenta", "maroon", "mediumaquamarine", "mediumblue", "mediumorchid",
        "mediumpurple", "mediumseagreen", "mediumslateblue", "mediumspringgreen",
        "mediumturquoise", "mediumvioletred", "midnightblue", "mintcream",
        "mistyrose", "moccasin", "navajowhite", "navy", "oldlace", "olive",
        "olivedrab", "orange", "orangered", "orchid", "palegoldenrod",
        "palegreen", "paleturquoise", "palevioletred", "papayawhip", "peachpuff",
        "peru", "pink", "plum", "powderblue", "purple", "red", "rosybrown",
        "royalblue", "saddlebrown", "salmon", "sandybrown", "seagreen", "seashell",
        "sienna", "silver", "skyblue", "slateblue", "slategray", "slategrey",
        "snow", "springgreen", "steelblue", "tan", "teal",
        "thistle", "tomato", "turquoise", "violet", "wheat", "white",
        "whitesmoke", "yellow", "yellowgreen",
    },

    ----------------------------------

    pseudo_splitter = "^(.-:)([^:]+)$",
    pseudo_element_content = "^content%-%['.*']$",
}

-------------------------------------------- PMS

local no_dash_axies = {
    ["p"] = { "", "x", "y", "t", "b", "l", "r", "e", "s" },
    ["m"] = { "", "x", "y", "t", "b", "l", "r", "e", "s" },
}
local dash_axies = {
    ["space"] = { "x", "y" },
    ["divide"] = { "x", "y" },
    ["border"] = { "", "t", "b", "l", "r" },
    ["rounded"] = { "", "t", "b", "l", "r", "tl", "tr", "bl", "br" },
    ["inset"] = { "", "x", "y" },
    ["gap"] = { "", "x", "y" },
}
--stylua: ignore
local singles = {
    "opacity", "border-opacity", "divide-opacity", "ring-opacity",
    "text", "font", "tracking", "leading", "line-clamp",
    "decoration", "underline-offset", "indent", "align", "content",
    "list-image",
    "ring", "ring-offset",
    "w", "h", "min-w", "min-h", "max-w", "max-h",
    "flex", "basis", "grow", "shrink", "order",
    "aspect-ratio", "columns",
    "top", "bottom", "left", "right",
    "start", "end", "z",
    "grid-cols", "col-span", "col-start", "col-end",
    "grid-rows", "row-span", "row-start", "row-end",
    "auto-rows", "auto-cols",
    "shadow",
}

local general_pms_postfixes = { "%-[%d%.%a/]+$", "%-%[[%-%d%.]+[%a%%]+]$" }
local property_specific_patterns = {
    ["divide"] = {
        ["x"] = { "^divide%-x$" },
        ["y"] = { "^divide%-y$" },
    },
    ["rounded"] = {
        [""] = { "^rounded$" },
        ["t"] = { "^rounded%-t$" },
        ["b"] = { "^rounded%-b$" },
        ["l"] = { "^rounded%-l$" },
        ["r"] = { "^rounded%-r$" },
        ["tl"] = { "^rounded%-tl$" },
        ["tr"] = { "^rounded%-tr$" },
        ["bl"] = { "^rounded%-bl$" },
        ["br"] = { "^rounded%-br$" },
    },
    ["flex"] = { "%-%[[%_%d%%]+]$" },
    ["grow"] = { "^grow$", "^grow%-%[[%d%.]+]$" },
    ["shrink"] = { "^shrink$", "^shrink%-%[[%d%.]+]$" },
    ["order"] = { "^order$", "^order%-%[[%d%.]+]$" },
    ["aspect-ratio"] = { "^aspect%-ratio%-%[[%d%/]+]$" },
    ["z"] = { "^z%-%[[%d%-]+]$" },
    ["grid-cols"] = { "^grid%-cols%-%[.+]$" },
    ["col-span"] = { "^col%-span%-%[.+]$" },
    ["col-start"] = { "^col%-start%-%[.+]$" },
    ["col-end"] = { "^col%-end%-%[.+]$" },
    ["grid-rows"] = { "^grid%-rows%-%[.+]$" },
    ["auto-rows"] = { "^auto%-rows%-%[.+]$" },
    ["auto-cols"] = { "^auto%-cols%-%[.+]$" },
    ["font"] = { "^font%-%[.+]$" },
    ["line-clamp"] = { "^line%-clamp%-%[%d+]$" },
    ["list-image"] = { "^list%-image%-%[.+]$" },
    ["content"] = { "^content%-%[.+]$" },
    ["shadow"] = { "^shadow%-%[.+]$" },
}

-- Add properties with axies
local add_axis_patterns = function(collection, prefix_format_fn)
    for property, axies in pairs(collection) do
        local tbl = {}
        for _, axis in ipairs(axies) do
            tbl[axis] = {}
            local prefix = prefix_format_fn(property, axis)
            for _, postfix in ipairs(general_pms_postfixes) do
                local pattern = "^" .. prefix .. postfix
                table.insert(tbl[axis], pattern)
                local negative_pattern = "^%-" .. prefix .. postfix
                table.insert(tbl[axis], negative_pattern)
            end
            if property_specific_patterns[property] then
                for _, pattern in ipairs(property_specific_patterns[property][axis] or {}) do
                    table.insert(tbl[axis], pattern)
                end
            end
        end
        M[property] = tbl
    end
end
add_axis_patterns(no_dash_axies, function(property, axis) return property .. axis end)
add_axis_patterns(dash_axies, function(property, axis)
    if axis == "" then return property end
    return property .. "%-" .. axis
end)
M["rounded"][""][1] = "^rounded%-[%d?%a?][^tblr]+$"

-- Add properties with no Axies
for _, property in ipairs(singles) do
    local tbl = {}
    for _, postfix in ipairs(general_pms_postfixes) do
        local pattern = "^" .. string.gsub(property, vim.pesc("-"), vim.pesc("%-")) .. postfix
        table.insert(tbl, pattern)
        local negative_pattern = "^%-"
            .. string.gsub(property, vim.pesc("-"), vim.pesc("%-"))
            .. postfix
        table.insert(tbl, negative_pattern)
    end
    for _, pattern in ipairs(property_specific_patterns[property] or {}) do
        table.insert(tbl, pattern)
    end
    M[property] = tbl
end

-------------------------------------------- Colors

local color_postfixes = {
    "%-%a+%-%d+",
    "%-black",
    "%-white",
    "%-transparent",
    "%-current",
    "%-%[rgb%([%d%s,]+%)]",
    "%-%[rgba%([%d%s,%.%%]+%)]",
    "%-%[hsl%([%d%s%%,]+%)]",
    "%-%[hsla%([%d%s,%.%%]+%)]",
    "%-%[#[%da-fA-F]+]",
}

local color_key_properties_map = {
    ["text-color"] = "text",
    ["background-color"] = "bg",
    ["border-color"] = "border",
    ["divide-color"] = "divide",
    ["ring-color"] = "ring",
    ["ring-offset-color"] = "ring-offset",
    ["from-color"] = "from",
    ["via-color"] = "via",
    ["to-color"] = "to",
    ["text-decoration-color"] = "decoration",
    ["shadow-color"] = "shadow",
}

for key, property in pairs(color_key_properties_map) do
    local patterns_tbl = {}
    for _, postfix in ipairs(color_postfixes) do
        local pattern = "^" .. string.gsub(property, "%-", "%%%-") .. postfix
        table.insert(patterns_tbl, pattern)
    end
    M[key] = patterns_tbl
end

return M

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

local general_pms_postfixes = { "%-[%d%.%a]+$", "%-%[[%d%.]+[%a%%]+]$" }
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
}

local pms_property_map = {
    ["padding"] = {
        [""] = "p",
        ["x"] = "px",
        ["y"] = "py",
        ["t"] = "pt",
        ["b"] = "pb",
        ["l"] = "pl",
        ["r"] = "pr",
    },
    ["margin"] = {
        [""] = "m",
        ["x"] = "mx",
        ["y"] = "my",
        ["t"] = "mt",
        ["b"] = "mb",
        ["l"] = "ml",
        ["r"] = "mr",
    },
    ["spacing"] = {
        ["x"] = "space%-x",
        ["y"] = "space%-y",
    },
    ["divide"] = {
        ["x"] = "divide%-x",
        ["y"] = "divide%-y",
    },
    ["border"] = {
        [""] = "border",
        ["t"] = "border%-t",
        ["b"] = "border%-b",
        ["l"] = "border%-l",
        ["r"] = "border%-r",
    },
    ["rounded"] = {
        [""] = "rounded",
        ["t"] = "rounded%-t",
        ["b"] = "rounded%-b",
        ["l"] = "rounded%-l",
        ["r"] = "rounded%-r",
        ["tl"] = "rounded%-tl",
        ["tr"] = "rounded%-tr",
        ["bl"] = "rounded%-bl",
        ["br"] = "rounded%-br",
    },
    ["opacity"] = "opacity",
    ["border-opacity"] = "border%-opacity",
    ["divide-opacity"] = "divide%-opacity",
    ["ring-opacity"] = "ring%-opacity",
    ["text"] = "text",
    ["ring"] = "ring",
    ["ring-offset"] = "ring%-offset",
    ["w"] = "w",
    ["h"] = "h",
    ["min-w"] = "min%-w",
    ["min-h"] = "min%-h",
    ["max-w"] = "max%-w",
    ["max-h"] = "max%-h",
}

for property, map in pairs(pms_property_map) do
    local tbl = {}
    if type(map) == "table" then
        for axis, prefix in pairs(map) do
            tbl[axis] = {}
            for _, postfix in ipairs(general_pms_postfixes) do
                local pattern = "^" .. prefix .. postfix
                table.insert(tbl[axis], pattern)
            end
            if property_specific_patterns[property] then
                for _, pattern in ipairs(property_specific_patterns[property][axis] or {}) do
                    table.insert(tbl[axis], pattern)
                end
            end
        end
    elseif type(map) == "string" then
        local prefix = map
        for _, postfix in ipairs(general_pms_postfixes) do
            local pattern = "^" .. prefix .. postfix
            table.insert(tbl, pattern)
        end
    end
    M[property] = tbl
end

M["rounded"][""][1] = "^rounded%-[%d?%a?][^tblr]+$"

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

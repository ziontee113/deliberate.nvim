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

    text = {
        "text%-xs",
        "text%-sm",
        "text%-base",
        "text%-lg",
        "text%-xl",
        "text%-2xl",
        "text%-3xl",
        "text%-4xl",
        "text%-5xl",
        "text%-6xl",
        "text%-7xl",
        "text%-8xl",
        "text%-9xl",
        "^text%-%[[%d%a%.]+%a+]$",
    },

    ring = {
        "ring",
        "ring%-inset",
        "^ring%-%[[%d%a%.]+%a+]$",
    },

    ["ring-offset"] = {
        "^ring%-offset%-[%d%a%.]+$",
        "^ring%-offset%-%[[%d%a%.]+%a+]$",
    },

    ["w"] = {
        "^w%-[%d%a%.?/?]+$",
        "^w%-%[[%d%a%.?]+%a+]$",
        "^w%-auto",
        "^w%-full",
        "^w%-screen",
        "^w%-min",
        "^w%-max",
    },
    ["h"] = {
        "^h%-[%d%a%.?/?]+$",
        "^h%-%[[%d%a%.?]+%a+]$",
        "^h%-auto",
        "^h%-full",
        "^h%-screen",
        "^h%-min",
        "^h%-max",
    },

    ["min-w"] = {
        "^min%-w%-[%d%a%.?/?]+$",
        "^min%-w%-%[[%d%a%.?]+%a+]$",
        "^min-%-w%-full",
        "^min-%-w%-min",
        "^min-%-w%-max",
    },
    ["min-h"] = {
        "^min%-h%-[%d%a%.?/?]+$",
        "^min%-h%-%[[%d%a%.?]+%a+]$",
        "^min-%-h%-full",
        "^min-%-h%-screen",
    },

    ["max-w"] = {
        "^max%-w%-[%d%%a?]+$",
        "^max%-w%-%[[%d%a%.?]+%a+]$",
        "^max%-w%-none",
        "^max%-w%-xs",
        "^max%-w%-sm",
        "^max%-w%-lg",
        "^max%-w%-full",
        "^max%-w%-min",
        "^max%-w%-max",
        "^max%-w%-prose",
        "^max%-w%-screen%-sm",
        "^max%-w%-screen%-md",
        "^max%-w%-screen%-lg",
        "^max%-w%-screen%-xl",
        "^max%-w%-screen%-2xl",
    },
    ["max-h"] = {
        "^max%-h%-[%d%.%a]+$",
        "^max%-h%-%[[%d%.]+%a+]$",
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
}

for property, map in pairs(pms_property_map) do
    local tbl = {}
    if type(map) == "table" then
        for axis, prefix in pairs(map) do
            tbl[axis] = {}
            for i, postfix in ipairs(general_pms_postfixes) do
                local pattern = "^" .. prefix .. postfix
                if property == "rounded" and axis == "" and i == 1 then
                    pattern = "^rounded%-[%d?%a?][^tblr]+$"
                end
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

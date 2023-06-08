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

    padding = {
        [""] = { "^p%-[%d%.%a]+$", "^p%-%[[%d%.]+%a+]$" },
        ["x"] = { "^px%-[%d%.%a]+$", "^px%-%[[%d%.]+%a+]$" },
        ["y"] = { "^py%-[%d%.%a]+$", "^py%-%[[%d%.]+%a+]$" },
        ["t"] = { "^pt%-[%d%.%a]+$", "^pt%-%[[%d%.]+%a+]$" },
        ["b"] = { "^pb%-[%d%.%a]+$", "^pb%-%[[%d%.]+%a+]$" },
        ["l"] = { "^pl%-[%d%.%a]+$", "^pl%-%[[%d%.]+%a+]$" },
        ["r"] = { "^pr%-[%d%.%a]+$", "^pr%-%[[%d%.]+%a+]$" },
        ["all"] = { "^p[xytblr]?%-[%d%.%a]+$", "^p[xytblr]?%-%[[%d%.]+%a+]$" },
    },
    margin = {
        [""] = { "^m%-[%d%.%a]+$", "^m%-%[[%d%.]+%a+]$" },
        ["x"] = { "^mx%-[%d%.%a]+$", "^mx%-%[[%d%.]+%a+]$" },
        ["y"] = { "^my%-[%d%.%a]+$", "^my%-%[[%d%.]+%a+]$" },
        ["t"] = { "^mt%-[%d%.%a]+$", "^mt%-%[[%d%.]+%a+]$" },
        ["b"] = { "^mb%-[%d%.%a]+$", "^mb%-%[[%d%.]+%a+]$" },
        ["l"] = { "^ml%-[%d%.%a]+$", "^ml%-%[[%d%.]+%a+]$" },
        ["r"] = { "^mr%-[%d%.%a]+$", "^mr%-%[[%d%.]+%a+]$" },
        ["all"] = { "^m[xytblr]?%-[%d%.%a]+$", "^m[xytblr]?%-%[[%d%.]+%a+]$" },
    },
    rounded = {
        [""] = { "^rounded$", "^rounded%-[%d?%a?][^tblr]+$", "^rounded%-%[[%d%.]+%a+]$" },
        ["x"] = { "^rounded%-x$", "^rounded%-x%-[%d?%a?]+$", "^rounded%-x%-%[[%d%.]+%a+]$" },
        ["y"] = { "^rounded%-y$", "^rounded%-y%-[%d?%a?]+$", "^rounded%-y%-%[[%d%.]+%a+]$" },
        ["t"] = { "^rounded%-t$", "^rounded%-t%-[%d?%a?]+$", "^rounded%-t%-%[[%d%.]+%a+]$" },
        ["b"] = { "^rounded%-b$", "^rounded%-b%-[%d?%a?]+$", "^rounded%-b%-%[[%d%.]+%a+]$" },
        ["l"] = { "^rounded%-l$", "^rounded%-l%-[%d?%a?]+$", "^rounded%-l%-%[[%d%.]+%a+]$" },
        ["r"] = { "^rounded%-r$", "^rounded%-r%-[%d?%a?]+$", "^rounded%-r%-%[[%d%.]+%a+]$" },
        ["tl"] = { "^rounded%-tl$", "^rounded%-tl%-[%d?%a?]+$", "^rounded%-tl%-%[[%d%.]+%a+]$" },
        ["tr"] = { "^rounded%-tr$", "^rounded%-tr%-[%d?%a?]+$", "^rounded%-tr%-%[[%d%.]+%a+]$" },
        ["bl"] = { "^rounded%-bl$", "^rounded%-bl%-[%d?%a?]+$", "^rounded%-bl%-%[[%d%.]+%a+]$" },
        ["br"] = { "^rounded%-br$", "^rounded%-br%-[%d?%a?]+$", "^rounded%-br%-%[[%d%.]+%a+]$" },
    },
    spacing = {
        ["x"] = { "^space%-x%-[%d%.%a]+$", "^space%-x%-%[[%d%.]+%a+]$" },
        ["y"] = { "^space%-y%-[%d%.%a]+$", "^space%-y%-%[[%d%.]+%a+]$" },
    },
    divide = {
        ["x"] = { "divide%-x", "^divide%-x%-[%d%.%a]+$", "^divide%-x%-%[[%d%.]+%a+]$" },
        ["y"] = { "divide%-y", "^divide%-y%-[%d%.%a]+$", "^divide%-y%-%[[%d%.]+%a+]$" },
    },
    border = {
        [""] = { "^border%-[%d%.%a]+$", "^border%-%[[%d%.]+%a+]$" },
        ["t"] = { "^border%-t%-[%d%.%a]+$", "^border%-t%-%[[%d%.]+%a+]$" },
        ["b"] = { "^border%-b%-[%d%.%a]+$", "^border%-b%-%[[%d%.]+%a+]$" },
        ["l"] = { "^border%-l%-[%d%.%a]+$", "^border%-l%-%[[%d%.]+%a+]$" },
        ["r"] = { "^border%-r%-[%d%.%a]+$", "^border%-r%-%[[%d%.]+%a+]$" },
    },
    opacity = { "^opacity%-[%d%a%.]+$", "^opacity%-%[[%d%.]+%%]$" },
    ["border-opacity"] = { "^border%-opacity%-[%d%a%.]+$", "^border%-opacity%-%[[%d%.]+%%]$" },
    ["divide-opacity"] = { "^divide%-opacity%-[%d%a%.]+$", "^divide%-opacity%-%[[%d%.]+%%]$" },
    ["ring-opacity"] = { "^ring%-opacity%-[%d%a%.]+$", "^ring%-opacity%-%[[%d%.]+%%]$" },

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

local color_properties = {
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

for key, property in pairs(color_properties) do
    local patterns_tbl = {}
    for _, postfix in ipairs(color_postfixes) do
        local pattern = "^" .. string.gsub(property, "%-", "%%%-") .. postfix
        table.insert(patterns_tbl, pattern)
    end
    M[key] = patterns_tbl
end

return M

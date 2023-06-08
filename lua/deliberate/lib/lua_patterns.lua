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

    --------------------------------------------

    text_color = {
        "^text%-%a+%-%d+",
        "^text%-black",
        "^text%-white",
        "^text%-transparent",
        "^text%-current",
        "text%-%[rgb%([%d%s,]+%)]",
        "text%-%[rgba%([%d%s,%.%%]+%)]",
        "text%-%[hsl%([%d%s%%,]+%)]",
        "text%-%[hsla%([%d%s,%.%%]+%)]",
        "text%-%[#[%da-fA-F]+]",
    },
    background_color = {
        "^bg%-%a+%-%d+",
        "^bg%-black",
        "^bg%-white",
        "^bg%-transparent",
        "^bg%-current",
        "bg%-%[rgb%([%d%s,]+%)]",
        "bg%-%[rgba%([%d%s,%.%%]+%)]",
        "bg%-%[hsl%([%d%s%%,]+%)]",
        "bg%-%[hsla%([%d%s,%.%%]+%)]",
        "bg%-%[#[%da-fA-F]+]",
    },
    border_color = {
        "^border%-%a+%-%d+",
        "^border%-black",
        "^border%-white",
        "^border%-transparent",
        "^border%-current",
        "border%-%[rgb%([%d%s,]+%)]",
        "border%-%[rgba%([%d%s,%.%%]+%)]",
        "border%-%[hsl%([%d%s%%,]+%)]",
        "border%-%[hsla%([%d%s,%.%%]+%)]",
        "border%-%[#[%da-fA-F]+]",
    },
    divide_color = {
        "^divide%-%a+%-%d+",
        "^divide%-black",
        "^divide%-white",
        "^divide%-transparent",
        "^divide%-current",
        "divide%-%[rgb%([%d%s,]+%)]",
        "divide%-%[rgba%([%d%s,%.%%]+%)]",
        "divide%-%[hsl%([%d%s%%,]+%)]",
        "divide%-%[hsla%([%d%s,%.%%]+%)]",
        "divide%-%[#[%da-fA-F]+]",
    },
    ring_color = {
        "^ring%-%a+%-%d+",
        "^ring%-black",
        "^ring%-white",
        "^ring%-transparent",
        "^ring%-current",
        "ring%-%[rgb%([%d%s,]+%)]",
        "ring%-%[rgba%([%d%s,%.%%]+%)]",
        "ring%-%[hsl%([%d%s%%,]+%)]",
        "ring%-%[hsla%([%d%s,%.%%]+%)]",
        "ring%-%[#[%da-fA-F]+]",
    },
    ring_offset_color = {
        "^ring-offset%-%a+%-%d+",
        "^ring-offset%-black",
        "^ring-offset%-white",
        "^ring-offset%-transparent",
        "^ring-offset%-current",
        "ring-offset%-%[rgb%([%d%s,]+%)]",
        "ring-offset%-%[rgba%([%d%s,%.%%]+%)]",
        "ring-offset%-%[hsl%([%d%s%%,]+%)]",
        "ring-offset%-%[hsla%([%d%s,%.%%]+%)]",
        "ring-offset%-%[#[%da-fA-F]+]",
    },

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
        [""] = { "^p%-[%d%.]+$", "^p%-%[[%d%.]+%a+]$" },
        ["x"] = { "^px%-[%d%.]+$", "^px%-%[[%d%.]+%a+]$" },
        ["y"] = { "^py%-[%d%.]+$", "^py%-%[[%d%.]+%a+]$" },
        ["t"] = { "^pt%-[%d%.]+$", "^pt%-%[[%d%.]+%a+]$" },
        ["b"] = { "^pb%-[%d%.]+$", "^pb%-%[[%d%.]+%a+]$" },
        ["l"] = { "^pl%-[%d%.]+$", "^pl%-%[[%d%.]+%a+]$" },
        ["r"] = { "^pr%-[%d%.]+$", "^pr%-%[[%d%.]+%a+]$" },
        ["all"] = { "^p[xytblr]?%-[%d%.]+$", "^p[xytblr]?%-%[[%d%.]+%a+]$" },
    },
    margin = {
        [""] = { "^m%-[%d%.]+$", "^m%-%[[%d%.]+%a+]$" },
        ["x"] = { "^mx%-[%d%.]+$", "^mx%-%[[%d%.]+%a+]$" },
        ["y"] = { "^my%-[%d%.]+$", "^my%-%[[%d%.]+%a+]$" },
        ["t"] = { "^mt%-[%d%.]+$", "^mt%-%[[%d%.]+%a+]$" },
        ["b"] = { "^mb%-[%d%.]+$", "^mb%-%[[%d%.]+%a+]$" },
        ["l"] = { "^ml%-[%d%.]+$", "^ml%-%[[%d%.]+%a+]$" },
        ["r"] = { "^mr%-[%d%.]+$", "^mr%-%[[%d%.]+%a+]$" },
        ["all"] = { "^m[xytblr]?%-[%d%.]+$", "^m[xytblr]?%-%[[%d%.]+%a+]$" },
    },
    spacing = {
        ["x"] = { "^space%-x%-[%d%.]+$", "^space%-x%-%[[%d%.]+%a+]$" },
        ["y"] = { "^space%-y%-[%d%.]+$", "^space%-y%-%[[%d%.]+%a+]$" },
    },
    divide = {
        ["x"] = { "divide%-x", "^divide%-x%-[%d%.]+$", "^divide%-x%-%[[%d%.]+%a+]$" },
        ["y"] = { "divide%-y", "^divide%-y%-[%d%.]+$", "^divide%-y%-%[[%d%.]+%a+]$" },
    },
    border = {
        [""] = { "^border%-[%d%.]+$", "^border%-%[[%d%.]+%a+]$" },
        ["t"] = { "^border%-t%-[%d%.]+$", "^border%-t%-%[[%d%.]+%a+]$" },
        ["b"] = { "^border%-b%-[%d%.]+$", "^border%-b%-%[[%d%.]+%a+]$" },
        ["l"] = { "^border%-l%-[%d%.]+$", "^border%-l%-%[[%d%.]+%a+]$" },
        ["r"] = { "^border%-r%-[%d%.]+$", "^border%-r%-%[[%d%.]+%a+]$" },
    },
    opacity = { "^opacity%-[%d%.]+$", "^opacity%-%[[%d%.]+%%]$" },
    ["border-opacity"] = { "^border%-opacity%-[%d%.]+$", "^border%-opacity%-%[[%d%.]+%%]$" },
    ["divide-opacity"] = { "^divide%-opacity%-[%d%.]+$", "^divide%-opacity%-%[[%d%.]+%%]$" },
    ["ring-opacity"] = { "^ring%-opacity%-[%d%.]+$", "^ring%-opacity%-%[[%d%.]+%%]$" },

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
        "^text%-%[[%d%.]+%a+]$",
    },

    ring = {
        "ring",
        "ring%-inset",
        "^ring%-%[[%d%.]+%a+]$",
    },

    ["ring-offset"] = {
        "^ring%-offset%-[%d%.]+$",
        "^ring%-offset%-%[[%d%.]+%a+]$",
    },

    ["w"] = {
        "^w%-[%d%.?/?]+$",
        "^w%-%[[%d%.?]+%a+]$",
        "^w%-auto",
        "^w%-full",
        "^w%-screen",
        "^w%-min",
        "^w%-max",
    },
    ["h"] = {
        "^h%-[%d%.?/?]+$",
        "^h%-%[[%d%.?]+%a+]$",
        "^h%-auto",
        "^h%-full",
        "^h%-screen",
        "^h%-min",
        "^h%-max",
    },
    ----------------------------------

    pseudo_splitter = "^(.-:)([^:]+)$",
    pseudo_element_content = "^content%-%['.*']$",
}

return M

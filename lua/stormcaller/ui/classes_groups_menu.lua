local PopUp = require("stormcaller.lib.ui.PopUp")
local tcm = require("stormcaller.api.tailwind_class_modifier")

local M = {}

local prepare_ingredients = function(group)
    local items, classes_groups = {}, {}
    for _, group_item in ipairs(group) do
        local text = table.concat(group_item.classes, " ")
        table.insert(items, {
            text = text,
            keymaps = group_item.keymaps,
            hidden = group_item.hidden,
        })
        table.insert(classes_groups, text)
    end
    return items, classes_groups
end

local classes_group_changer_menu = function(group)
    local items, classes_groups = prepare_ingredients(group)

    local popup = PopUp:new({
        steps = {
            {
                items = items,
                callback = function(_, current_item)
                    tcm.change_classes_groups({
                        classes_groups = classes_groups,
                        value = current_item.text,
                    })
                end,
            },
        },
    })

    popup:show()
end

local flex_group = {
    { keymaps = { "0" }, classes = {}, hidden = true },
    { keymaps = { "f", "l" }, classes = { "flex" } },
    { keymaps = { "r" }, classes = { "flex", "flex-row" } },
}
M.change_flex_properties = function() classes_group_changer_menu(flex_group) end

local flex_align_group = {
    { keymaps = { "0" }, classes = {}, hidden = true },
    { keymaps = { "i" }, classes = { "items-center" } },
    { keymaps = { "j" }, classes = { "justify-center" } },
    { keymaps = { "b" }, classes = { "justify-between" } },
    { keymaps = { "c" }, classes = { "items-center", "justify-center" } },
    { keymaps = { "cb" }, classes = { "content-between" } },
}
M.change_flex_align_properties = function() classes_group_changer_menu(flex_align_group) end

local font_weight_group = {
    { keymaps = { "0" }, classes = {}, hidden = true },
    { keymaps = { "t", "1" }, classes = { "font-thin" } },
    { keymaps = { "e", "2" }, classes = { "font-extralight" } },
    { keymaps = { "l", "3" }, classes = { "font-light" } },
    { keymaps = { "n", "4" }, classes = { "font-normal" } },
    { keymaps = { "m", "5" }, classes = { "font-medium" } },
    { keymaps = { "s", "6" }, classes = { "font-semibold" } },
    { keymaps = { "b", "7" }, classes = { "font-bold" } },
    { keymaps = { "E", "8" }, classes = { "font-extrabold" } },
    { keymaps = { "B", "9" }, classes = { "font-black" } },
}
M.change_font_weight = function() classes_group_changer_menu(font_weight_group) end

local text_decoration_group = {
    { keymaps = { "0" }, classes = {}, hidden = true },
    { keymaps = { "u", "U" }, classes = { "underline" } },
    { keymaps = { "o", "O" }, classes = { "overline" } },
    { keymaps = { "l", "L" }, classes = { "line-through" } },
    { keymaps = { "n", "N" }, classes = { "no-underline" } },
}
M.change_text_decoration = function() classes_group_changer_menu(text_decoration_group) end

local font_style_group = {
    { keymaps = { "0" }, classes = {}, hidden = true },
    { keymaps = { "i" }, classes = { "italic" } },
    { keymaps = { "n" }, classes = { "not-italic" } },
}
M.change_font_style = function() classes_group_changer_menu(font_style_group) end

local font_size_group = {
    { keymaps = { "0" }, classes = {}, hidden = true },
    { keymaps = { "x" }, classes = { "text-xs" } },
    { keymaps = { "m" }, classes = { "text-sm" } },
    { keymaps = { "b" }, classes = { "text-base" } },
    { keymaps = { "l" }, classes = { "text-lg" } },
    { keymaps = { "q", "1" }, classes = { "text-xl" } },
    { keymaps = { "w", "2" }, classes = { "text-2xl" } },
    { keymaps = { "e", "3" }, classes = { "text-3xl" } },
    { keymaps = { "r", "4" }, classes = { "text-4xl" } },
    { keymaps = { "t", "5" }, classes = { "text-5xl" } },
    { keymaps = { "a", "6" }, classes = { "text-6xl" } },
    { keymaps = { "s", "7" }, classes = { "text-7xl" } },
    { keymaps = { "d", "8" }, classes = { "text-8xl" } },
    { keymaps = { "f", "9" }, classes = { "text-9xl" } },
}
M.change_font_size = function() classes_group_changer_menu(font_size_group) end

local text_align_group = {
    { keymaps = { "0" }, classes = {}, hidden = true },
    { keymaps = { "h" }, classes = { "text-left" } },
    { keymaps = { "l" }, classes = { "text-right" } },
    { keymaps = { "k" }, classes = { "text-center" } },
    { keymaps = { "j" }, classes = { "text-justify" } },
}
M.change_text_align = function() classes_group_changer_menu(text_align_group) end

local opacity_group = {
    { keymaps = { "0" }, classes = {}, hidden = true },
    { keymaps = { "n" }, classes = { "opacity-0" } },
    { keymaps = { "q" }, classes = { "opacity-5" } },
    { keymaps = { "w" }, classes = { "opacity-10" } },
    { keymaps = { "e" }, classes = { "opacity-20" } },
    { keymaps = { "r" }, classes = { "opacity-25" } },
    { keymaps = { "t" }, classes = { "opacity-30" } },
    { keymaps = { "a" }, classes = { "opacity-40" } },
    { keymaps = { "s" }, classes = { "opacity-50" } },
    { keymaps = { "d" }, classes = { "opacity-60" } },
    { keymaps = { "f" }, classes = { "opacity-70" } },
    { keymaps = { "g" }, classes = { "opacity-75" } },
    { keymaps = { "u" }, classes = { "opacity-80" } },
    { keymaps = { "i" }, classes = { "opacity-90" } },
    { keymaps = { "o" }, classes = { "opacity-100" } },
}
M.change_opacity = function() classes_group_changer_menu(opacity_group) end

return M

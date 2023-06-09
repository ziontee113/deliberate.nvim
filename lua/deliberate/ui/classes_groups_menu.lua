local PopUp = require("deliberate.lib.ui.PopUp")
local tcm = require("deliberate.api.tailwind_class_modifier")
local menu_repeater = require("deliberate.api.menu_repeater")

local M = {}

local prepare_ingredients = function(group)
    table.insert(group, { keymaps = { "0" }, classes = {}, hidden = true })

    local items, classes_groups = {}, {}
    for _, group_item in ipairs(group) do
        if type(group_item) == "table" then
            local text = table.concat(group_item.classes, " ")
            table.insert(items, {
                text = text,
                keymaps = group_item.keymaps,
                hidden = group_item.hidden,
            })
            table.insert(classes_groups, text)
        else
            table.insert(items, "")
        end
    end
    return items, classes_groups
end

M._classes_group_changer_menu = function(group)
    menu_repeater.register(M._classes_group_changer_menu, group)

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
    { keymaps = { "f", "l" }, classes = { "flex" } },
    "",
    { keymaps = { "r" }, classes = { "flex", "flex-row" } },
    { keymaps = { "R" }, classes = { "flex", "flex-row-reverse" } },
    { keymaps = { "c" }, classes = { "flex", "flex-col" } },
    { keymaps = { "C" }, classes = { "flex", "flex-col-reverse" } },
    "",
    { keymaps = { "i" }, classes = { "inline-flex" } },
}
M.change_flex_properties = function() M._classes_group_changer_menu(flex_group) end

local flex_wrap_group = {
    { keymaps = { "w" }, classes = { "flex-wrap" } },
    { keymaps = { "r" }, classes = { "flex-wrap-reverse" } },
    { keymaps = { "n" }, classes = { "flex-nowrap" } },
}
M.change_flex_wrap_properties = function() M._classes_group_changer_menu(flex_wrap_group) end

local flex_align_group = {
    { keymaps = { "i" }, classes = { "items-center" } },
    { keymaps = { "j" }, classes = { "justify-center" } },
    { keymaps = { "b" }, classes = { "justify-between" } },
    { keymaps = { "c" }, classes = { "items-center", "justify-center" } },
    { keymaps = { "cb" }, classes = { "content-between" } },
}
M.change_flex_align_properties = function() M._classes_group_changer_menu(flex_align_group) end

-- Typography

local font_weight_group = {
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
M.change_font_weight = function() M._classes_group_changer_menu(font_weight_group) end

local text_decoration_group = {
    { keymaps = { "u", "U" }, classes = { "underline" } },
    { keymaps = { "o", "O" }, classes = { "overline" } },
    { keymaps = { "l", "L" }, classes = { "line-through" } },
    { keymaps = { "n", "N" }, classes = { "no-underline" } },
}
M.change_text_decoration = function() M._classes_group_changer_menu(text_decoration_group) end

local font_style_group = {
    { keymaps = { "i" }, classes = { "italic" } },
    { keymaps = { "n" }, classes = { "not-italic" } },
}
M.change_font_style = function() M._classes_group_changer_menu(font_style_group) end

local text_align_group = {
    { keymaps = { "h" }, classes = { "text-left" } },
    { keymaps = { "l" }, classes = { "text-right" } },
    { keymaps = { "k" }, classes = { "text-center" } },
    { keymaps = { "j" }, classes = { "text-justify" } },
}
M.change_text_align = function() M._classes_group_changer_menu(text_align_group) end

-- Divide

local divide_style_group = {
    { keymaps = { "s" }, classes = { "divide-solid" } },
    { keymaps = { "d" }, classes = { "divide-dashed" } },
    { keymaps = { "." }, classes = { "divide-dotted" } },
    { keymaps = { "2" }, classes = { "divide-double" } },
    { keymaps = { "n" }, classes = { "divide-none" } },
}
M.change_divide_style = function() M._classes_group_changer_menu(divide_style_group) end

-- Border

local border_style_group = {
    { keymaps = { "s" }, classes = { "border-solid" } },
    { keymaps = { "d" }, classes = { "border-dashed" } },
    { keymaps = { "." }, classes = { "border-dotted" } },
    { keymaps = { "2" }, classes = { "border-double" } },
    { keymaps = { "n" }, classes = { "border-none" } },
}
M.change_border_style = function() M._classes_group_changer_menu(border_style_group) end

return M

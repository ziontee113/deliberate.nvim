local PopUp = require("deliberate.lib.ui.PopUp")
local tcm = require("deliberate.api.tailwind_class_modifier")
local menu_repeater = require("deliberate.api.menu_repeater")

local M = {}

local prepare_ingredients = function(group)
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
    { keymaps = { "0" }, classes = {}, hidden = true },
    { keymaps = { "f", "l" }, classes = { "flex" } },
    { keymaps = { "r" }, classes = { "flex", "flex-row" } },
}
M.change_flex_properties = function() M._classes_group_changer_menu(flex_group) end

local flex_align_group = {
    { keymaps = { "0" }, classes = {}, hidden = true },
    { keymaps = { "i" }, classes = { "items-center" } },
    { keymaps = { "j" }, classes = { "justify-center" } },
    { keymaps = { "b" }, classes = { "justify-between" } },
    { keymaps = { "c" }, classes = { "items-center", "justify-center" } },
    { keymaps = { "cb" }, classes = { "content-between" } },
}
M.change_flex_align_properties = function() M._classes_group_changer_menu(flex_align_group) end

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
M.change_font_weight = function() M._classes_group_changer_menu(font_weight_group) end

local text_decoration_group = {
    { keymaps = { "0" }, classes = {}, hidden = true },
    { keymaps = { "u", "U" }, classes = { "underline" } },
    { keymaps = { "o", "O" }, classes = { "overline" } },
    { keymaps = { "l", "L" }, classes = { "line-through" } },
    { keymaps = { "n", "N" }, classes = { "no-underline" } },
}
M.change_text_decoration = function() M._classes_group_changer_menu(text_decoration_group) end

local font_style_group = {
    { keymaps = { "0" }, classes = {}, hidden = true },
    { keymaps = { "i" }, classes = { "italic" } },
    { keymaps = { "n" }, classes = { "not-italic" } },
}
M.change_font_style = function() M._classes_group_changer_menu(font_style_group) end

local text_align_group = {
    { keymaps = { "0" }, classes = {}, hidden = true },
    { keymaps = { "h" }, classes = { "text-left" } },
    { keymaps = { "l" }, classes = { "text-right" } },
    { keymaps = { "k" }, classes = { "text-center" } },
    { keymaps = { "j" }, classes = { "text-justify" } },
}
M.change_text_align = function() M._classes_group_changer_menu(text_align_group) end

-- Divide

local divide_x_group = {
    { keymaps = { "0" }, classes = {}, hidden = true },
    { keymaps = { "x" }, classes = { "divide-x" } },
    { keymaps = { "m" }, classes = { "divide-x-0" } },
    { keymaps = { "2" }, classes = { "divide-x-2" } },
    { keymaps = { "4" }, classes = { "divide-x-4" } },
    { keymaps = { "8" }, classes = { "divide-x-8" } },
    { keymaps = { "r" }, classes = { "divide-x-reverse" } },
}
M.change_divide_x = function() M._classes_group_changer_menu(divide_x_group) end

local divide_y_group = {
    { keymaps = { "0" }, classes = {}, hidden = true },
    { keymaps = { "y" }, classes = { "divide-y" } },
    { keymaps = { "m" }, classes = { "divide-y-0" } },
    { keymaps = { "2" }, classes = { "divide-y-2" } },
    { keymaps = { "4" }, classes = { "divide-y-4" } },
    { keymaps = { "8" }, classes = { "divide-y-8" } },
    { keymaps = { "r" }, classes = { "divide-y-reverse" } },
}
M.change_divide_y = function() M._classes_group_changer_menu(divide_y_group) end

local divide_style_group = {
    { keymaps = { "0" }, classes = {}, hidden = true },
    { keymaps = { "s" }, classes = { "divide-solid" } },
    { keymaps = { "d" }, classes = { "divide-dashed" } },
    { keymaps = { "." }, classes = { "divide-dotted" } },
    { keymaps = { "2" }, classes = { "divide-double" } },
    { keymaps = { "n" }, classes = { "divide-none" } },
}
M.change_divide_style = function() M._classes_group_changer_menu(divide_style_group) end

-- Ring

local ring_width_group = {
    { keymaps = { "0" }, classes = {}, hidden = true },
    { keymaps = { "m" }, classes = { "ring-0" } },
    { keymaps = { "1" }, classes = { "ring-1" } },
    { keymaps = { "2" }, classes = { "ring-2" } },
    { keymaps = { "4" }, classes = { "ring-4" } },
    { keymaps = { "8" }, classes = { "ring-8" } },
    { keymaps = { "r" }, classes = { "ring" } },
    { keymaps = { "i" }, classes = { "ring-inset" } },
}
M.change_ring_width = function() M._classes_group_changer_menu(ring_width_group) end

local ring_offset_width_group = {
    { keymaps = { "0" }, classes = {}, hidden = true },
    { keymaps = { "m" }, classes = { "ring-offset-0" } },
    { keymaps = { "1" }, classes = { "ring-offset-1" } },
    { keymaps = { "2" }, classes = { "ring-offset-2" } },
    { keymaps = { "4" }, classes = { "ring-offset-4" } },
    { keymaps = { "8" }, classes = { "ring-offset-8" } },
}
M.change_ring_offset_width = function() M._classes_group_changer_menu(ring_offset_width_group) end

local border_style_group = {
    { keymaps = { "0" }, classes = {}, hidden = true },
    { keymaps = { "s" }, classes = { "border-solid" } },
    { keymaps = { "d" }, classes = { "border-dashed" } },
    { keymaps = { "." }, classes = { "border-dotted" } },
    { keymaps = { "2" }, classes = { "border-double" } },
    { keymaps = { "n" }, classes = { "border-none" } },
}
M.change_border_style = function() M._classes_group_changer_menu(border_style_group) end

-------------------------------------------- Border Radius

local prefix = "rounded"
local axies = { "", "t", "b", "l", "r", "tl", "tr", "bl", "br" }
local keymap_to_size_tbl = {
    { "0", false },

    { "s", "sm" },
    { "r", "" },
    { "m", "md" },
    { "l", "lg" },
    "",
    { "1", "xl" },
    { "2", "2xl" },
    { "3", "3xl" },
    "",
    { "f", "full" },
    { "n", "none" },
}

-- TODO: refactor
local border_radius_groups = {}
for _, axis in ipairs(axies) do
    local group = {}
    for _, item_ingredients in ipairs(keymap_to_size_tbl) do
        if type(item_ingredients) == "table" then
            local keymap, size = unpack(item_ingredients)
            local classes = {}

            local class = ""
            if axis == "" then
                class = string.format("%s-%s", prefix, size)
            else
                if size == "" then
                    class = string.format("%s-%s", prefix, axis)
                else
                    class = string.format("%s-%s-%s", prefix, axis, size)
                end
            end

            if axis == "" and size == "" then class = prefix end

            if size then table.insert(classes, class) end

            local item = {
                keymaps = { keymap },
                classes = classes,
                hidden = size == false and true or nil,
            }
            table.insert(group, item)
        else
            table.insert(group, "")
        end
    end
    border_radius_groups[axis] = group
end

M.change_border_radius = function(axis) M._classes_group_changer_menu(border_radius_groups[axis]) end

return M

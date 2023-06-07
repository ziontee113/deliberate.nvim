local PopUp = require("deliberate.lib.ui.PopUp")
local tcm = require("deliberate.api.tailwind_class_modifier")

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

-- Opacity

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
    { keymaps = { "o" }, classes = { "opacity-95" } },
    { keymaps = { "p" }, classes = { "opacity-100" } },
}
M.change_opacity = function() classes_group_changer_menu(opacity_group) end

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
M.change_divide_x = function() classes_group_changer_menu(divide_x_group) end

local divide_y_group = {
    { keymaps = { "0" }, classes = {}, hidden = true },
    { keymaps = { "y" }, classes = { "divide-y" } },
    { keymaps = { "m" }, classes = { "divide-y-0" } },
    { keymaps = { "2" }, classes = { "divide-y-2" } },
    { keymaps = { "4" }, classes = { "divide-y-4" } },
    { keymaps = { "8" }, classes = { "divide-y-8" } },
    { keymaps = { "r" }, classes = { "divide-y-reverse" } },
}
M.change_divide_y = function() classes_group_changer_menu(divide_y_group) end

local divide_style_group = {
    { keymaps = { "0" }, classes = {}, hidden = true },
    { keymaps = { "s" }, classes = { "divide-solid" } },
    { keymaps = { "d" }, classes = { "divide-dashed" } },
    { keymaps = { "." }, classes = { "divide-dotted" } },
    { keymaps = { "2" }, classes = { "divide-double" } },
    { keymaps = { "n" }, classes = { "divide-none" } },
}
M.change_divide_style = function() classes_group_changer_menu(divide_style_group) end

local divide_opacity_group = {
    { keymaps = { "0" }, classes = {}, hidden = true },
    { keymaps = { "n" }, classes = { "divide-opacity-0" } },
    { keymaps = { "q" }, classes = { "divide-opacity-5" } },
    { keymaps = { "w" }, classes = { "divide-opacity-10" } },
    { keymaps = { "e" }, classes = { "divide-opacity-20" } },
    { keymaps = { "r" }, classes = { "divide-opacity-25" } },
    { keymaps = { "t" }, classes = { "divide-opacity-30" } },
    { keymaps = { "a" }, classes = { "divide-opacity-40" } },
    { keymaps = { "s" }, classes = { "divide-opacity-50" } },
    { keymaps = { "d" }, classes = { "divide-opacity-60" } },
    { keymaps = { "f" }, classes = { "divide-opacity-70" } },
    { keymaps = { "g" }, classes = { "divide-opacity-75" } },
    { keymaps = { "u" }, classes = { "divide-opacity-80" } },
    { keymaps = { "i" }, classes = { "divide-opacity-90" } },
    { keymaps = { "o" }, classes = { "divide-opacity-95" } },
    { keymaps = { "p" }, classes = { "divide-opacity-100" } },
}
M.change_divide_opacity = function() classes_group_changer_menu(divide_opacity_group) end

-- Ring

local ring_width_group = {
    { keymaps = { "0" }, classes = {}, hidden = true },
    { keymaps = { "m" }, classes = { "ring-0" } },
    { keymaps = { "1" }, classes = { "ring-1" } },
    { keymaps = { "2" }, classes = { "ring-2" } },
    { keymaps = { "4" }, classes = { "ring-4" } },
    { keymaps = { "8" }, classes = { "ring-8" } },
    { keymaps = { "r" }, classes = { "ring" } },
    { keymaps = { "r" }, classes = { "ring-inset" } },
}
M.change_ring_width = function() classes_group_changer_menu(ring_width_group) end

local ring_offset_width_group = {
    { keymaps = { "0" }, classes = {}, hidden = true },
    { keymaps = { "m" }, classes = { "ring-offset-0" } },
    { keymaps = { "1" }, classes = { "ring-offset-1" } },
    { keymaps = { "2" }, classes = { "ring-offset-2" } },
    { keymaps = { "4" }, classes = { "ring-offset-4" } },
    { keymaps = { "8" }, classes = { "ring-offset-8" } },
}
M.change_ring_offset_width = function() classes_group_changer_menu(ring_offset_width_group) end

local ring_opacity_group = {
    { keymaps = { "0" }, classes = {}, hidden = true },
    { keymaps = { "n" }, classes = { "ring-opacity-0" } },
    { keymaps = { "q" }, classes = { "ring-opacity-5" } },
    { keymaps = { "w" }, classes = { "ring-opacity-10" } },
    { keymaps = { "e" }, classes = { "ring-opacity-20" } },
    { keymaps = { "r" }, classes = { "ring-opacity-25" } },
    { keymaps = { "t" }, classes = { "ring-opacity-30" } },
    { keymaps = { "a" }, classes = { "ring-opacity-40" } },
    { keymaps = { "s" }, classes = { "ring-opacity-50" } },
    { keymaps = { "d" }, classes = { "ring-opacity-60" } },
    { keymaps = { "f" }, classes = { "ring-opacity-70" } },
    { keymaps = { "g" }, classes = { "ring-opacity-75" } },
    { keymaps = { "u" }, classes = { "ring-opacity-80" } },
    { keymaps = { "i" }, classes = { "ring-opacity-90" } },
    { keymaps = { "o" }, classes = { "ring-opacity-95" } },
    { keymaps = { "p" }, classes = { "ring-opacity-100" } },
}
M.change_ring_opacity = function() classes_group_changer_menu(ring_opacity_group) end

-- Border Related

local border_opacity_group = {
    { keymaps = { "0" }, classes = {}, hidden = true },
    { keymaps = { "n" }, classes = { "border-opacity-0" } },
    { keymaps = { "q" }, classes = { "border-opacity-5" } },
    { keymaps = { "w" }, classes = { "border-opacity-10" } },
    { keymaps = { "e" }, classes = { "border-opacity-20" } },
    { keymaps = { "r" }, classes = { "border-opacity-25" } },
    { keymaps = { "t" }, classes = { "border-opacity-30" } },
    { keymaps = { "a" }, classes = { "border-opacity-40" } },
    { keymaps = { "s" }, classes = { "border-opacity-50" } },
    { keymaps = { "d" }, classes = { "border-opacity-60" } },
    { keymaps = { "f" }, classes = { "border-opacity-70" } },
    { keymaps = { "g" }, classes = { "border-opacity-75" } },
    { keymaps = { "u" }, classes = { "border-opacity-80" } },
    { keymaps = { "i" }, classes = { "border-opacity-90" } },
    { keymaps = { "o" }, classes = { "border-opacity-95" } },
    { keymaps = { "p" }, classes = { "border-opacity-100" } },
}
M.change_border_opacity = function() classes_group_changer_menu(border_opacity_group) end

local border_style_group = {
    { keymaps = { "0" }, classes = {}, hidden = true },
    { keymaps = { "s" }, classes = { "border-solid" } },
    { keymaps = { "d" }, classes = { "border-dashed" } },
    { keymaps = { "." }, classes = { "border-dotted" } },
    { keymaps = { "2" }, classes = { "border-double" } },
    { keymaps = { "n" }, classes = { "border-none" } },
}
M.change_border_style = function() classes_group_changer_menu(border_style_group) end

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

M.change_border_radius = function(axis) classes_group_changer_menu(border_radius_groups[axis]) end

return M

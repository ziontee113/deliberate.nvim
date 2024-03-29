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
            table.insert(items, group_item)
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

-- Flex

local flex_group = {
    { keymaps = { "f", "l" }, classes = { "flex" } },
    "------------------------",
    { keymaps = { "r" }, classes = { "flex", "flex-row" } },
    { keymaps = { "R" }, classes = { "flex", "flex-row-reverse" } },
    "------------------------",
    { keymaps = { "c" }, classes = { "flex", "flex-col" } },
    { keymaps = { "C" }, classes = { "flex", "flex-col-reverse" } },
    "------------------------",
    { keymaps = { "i" }, classes = { "inline-flex" } },
}
M.change_flex_properties = function() M._classes_group_changer_menu(flex_group) end

local flex_wrap_group = {
    { keymaps = { "w" }, classes = { "flex-wrap" } },
    { keymaps = { "r" }, classes = { "flex-wrap-reverse" } },
    { keymaps = { "n" }, classes = { "flex-nowrap" } },
}
M.change_flex_wrap_properties = function() M._classes_group_changer_menu(flex_wrap_group) end

-- Justify

local justify_content_group = {
    { keymaps = { "n" }, classes = { "justify-normal" } },
    { keymaps = { "s" }, classes = { "justify-start" } },
    { keymaps = { "c" }, classes = { "justify-center" } },
    { keymaps = { "e" }, classes = { "justify-end" } },
    { keymaps = { "b" }, classes = { "justify-between" } },
    { keymaps = { "a" }, classes = { "justify-around" } },
    { keymaps = { "e" }, classes = { "justify-evenly" } },
    { keymaps = { "S" }, classes = { "justify-stretch" } },
}
M.change_justifity_content = function() M._classes_group_changer_menu(justify_content_group) end

local justify_items_group = {
    { keymaps = { "s" }, classes = { "justify-items-start" } },
    { keymaps = { "c" }, classes = { "justify-items-center" } },
    { keymaps = { "e" }, classes = { "justify-items-end" } },
    { keymaps = { "S" }, classes = { "justify-stretch" } },
}
M.change_justifity_items = function() M._classes_group_changer_menu(justify_items_group) end

local justify_self_group = {
    { keymaps = { "a" }, classes = { "justify-self-auto" } },
    { keymaps = { "s" }, classes = { "justify-self-start" } },
    { keymaps = { "c" }, classes = { "justify-self-center" } },
    { keymaps = { "e" }, classes = { "justify-self-end" } },
    { keymaps = { "S" }, classes = { "justify-self-stretch" } },
}
M.change_justifity_self = function() M._classes_group_changer_menu(justify_self_group) end

-- Align

local align_content_group = {
    { keymaps = { "n" }, classes = { "content-normal" } },
    { keymaps = { "s" }, classes = { "content-start" } },
    { keymaps = { "c" }, classes = { "content-center" } },
    { keymaps = { "e" }, classes = { "content-end" } },
    { keymaps = { "b" }, classes = { "content-between" } },
    { keymaps = { "a" }, classes = { "content-around" } },
    { keymaps = { "e" }, classes = { "content-evenly" } },
    { keymaps = { "B" }, classes = { "content-baseline" } },
    { keymaps = { "S" }, classes = { "content-stretch" } },
}
M.change_align_content = function() M._classes_group_changer_menu(align_content_group) end

local align_items_group = {
    { keymaps = { "s" }, classes = { "items-start" } },
    { keymaps = { "c" }, classes = { "items-center" } },
    { keymaps = { "e" }, classes = { "items-end" } },
    { keymaps = { "S" }, classes = { "items-stretch" } },
}
M.change_align_items = function() M._classes_group_changer_menu(align_items_group) end

local align_self_group = {
    { keymaps = { "a" }, classes = { "self-auto" } },
    { keymaps = { "s" }, classes = { "self-start" } },
    { keymaps = { "c" }, classes = { "self-center" } },
    { keymaps = { "e" }, classes = { "self-end" } },
    { keymaps = { "B" }, classes = { "self-baseline" } },
    { keymaps = { "S" }, classes = { "self-stretch" } },
}
M.change_align_self = function() M._classes_group_changer_menu(align_self_group) end

-- Place Content

local place_content_group = {
    { keymaps = { "s" }, classes = { "place-content-start" } },
    { keymaps = { "c" }, classes = { "place-content-center" } },
    { keymaps = { "e" }, classes = { "place-content-end" } },
    { keymaps = { "b" }, classes = { "place-content-between" } },
    { keymaps = { "a" }, classes = { "place-content-around" } },
    { keymaps = { "e" }, classes = { "place-content-evenly" } },
    { keymaps = { "B" }, classes = { "place-content-baseline" } },
    { keymaps = { "S" }, classes = { "place-content-stretch" } },
}
M.change_place_content = function() M._classes_group_changer_menu(place_content_group) end

local place_items_group = {
    { keymaps = { "a" }, classes = { "place-items-auto" } },
    { keymaps = { "s" }, classes = { "place-items-start" } },
    { keymaps = { "c" }, classes = { "place-items-center" } },
    { keymaps = { "e" }, classes = { "place-items-end" } },
    { keymaps = { "B" }, classes = { "place-items-baseline" } },
    { keymaps = { "S" }, classes = { "place-items-stretch" } },
}
M.change_place_items = function() M._classes_group_changer_menu(place_items_group) end

local place_self_group = {
    { keymaps = { "a" }, classes = { "place-self-auto" } },
    { keymaps = { "s" }, classes = { "place-self-start" } },
    { keymaps = { "c" }, classes = { "place-self-center" } },
    { keymaps = { "e" }, classes = { "place-self-end" } },
    { keymaps = { "B" }, classes = { "place-self-baseline" } },
    { keymaps = { "S" }, classes = { "place-self-stretch" } },
}
M.change_place_self = function() M._classes_group_changer_menu(place_self_group) end

-- Typography

local font_smoothing_group = {
    { keymaps = { "a" }, classes = { "antialiased" } },
    { keymaps = { "s" }, classes = { "subpixel-antialiased" } },
}
M.change_font_smoothing = function() M._classes_group_changer_menu(font_smoothing_group) end

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

local decoration_style_group = {
    { keymaps = { "s" }, classes = { "decoration-solid" } },
    { keymaps = { "2" }, classes = { "decoration-double" } },
    { keymaps = { "." }, classes = { "decoration-dotted" } },
    { keymaps = { "d" }, classes = { "decoration-dashed" } },
    { keymaps = { "w" }, classes = { "decoration-wavy" } },
}
M.change_decoration_style = function() M._classes_group_changer_menu(decoration_style_group) end

local font_style_group = {
    { keymaps = { "i" }, classes = { "italic" } },
    { keymaps = { "n" }, classes = { "not-italic" } },
}
M.change_font_style = function() M._classes_group_changer_menu(font_style_group) end

local text_transform_group = {
    { keymaps = { "u", "U" }, classes = { "uppercase" } },
    { keymaps = { "l", "L" }, classes = { "lowercase" } },
    { keymaps = { "c", "C" }, classes = { "capitalize" } },
    { keymaps = { "n", "N" }, classes = { "normal-case" } },
}
M.change_text_transform = function() M._classes_group_changer_menu(text_transform_group) end

local text_overflow_group = {
    { keymaps = { "t" }, classes = { "truncate" } },
    { keymaps = { "e" }, classes = { "text-ellipsis" } },
    { keymaps = { "c" }, classes = { "text-clip" } },
}
M.change_text_overflow = function() M._classes_group_changer_menu(text_overflow_group) end

local whitespace_group = {
    { keymaps = { "n" }, classes = { "whitespace-normal" } },
    { keymaps = { "/" }, classes = { "whitespace-nowrap" } },
    { keymaps = { "p" }, classes = { "whitespace-pre" } },
    { keymaps = { "L" }, classes = { "whitespace-pre-line" } },
    { keymaps = { "W" }, classes = { "whitespace-pre-wrap" } },
    { keymaps = { "b" }, classes = { "whitespace-break-spaces" } },
}
M.change_whitespace = function() M._classes_group_changer_menu(whitespace_group) end

local word_break_group = {
    { keymaps = { "n" }, classes = { "break-normal" } },
    { keymaps = { "w" }, classes = { "break-words" } },
    { keymaps = { "a" }, classes = { "break-all" } },
    { keymaps = { "k" }, classes = { "break-keep" } },
}
M.change_word_break = function() M._classes_group_changer_menu(word_break_group) end

local hyphens_group = {
    { keymaps = { "n", "/" }, classes = { "hyphens-none" } },
    { keymaps = { "m" }, classes = { "hyphens-manual" } },
    { keymaps = { "a" }, classes = { "hyphens-auto" } },
}
M.change_hyphens = function() M._classes_group_changer_menu(hyphens_group) end

local font_variant_numeric_group = {
    { keymaps = { "i" }, classes = { "normal-nums" } },
    { keymaps = { "n" }, classes = { "ordinal" } },
    { keymaps = { "n" }, classes = { "slashed-zero" } },
    { keymaps = { "n" }, classes = { "lining-nums" } },
    { keymaps = { "n" }, classes = { "oldstyle-nums" } },
    { keymaps = { "n" }, classes = { "porpotional-nums" } },
    { keymaps = { "n" }, classes = { "tabular-nums" } },
    { keymaps = { "n" }, classes = { "diagonal-fragtions" } },
    { keymaps = { "n" }, classes = { "stacked-fractions" } },
}
M.change_font_variant_numeric = function() M._classes_group_changer_menu(font_variant_numeric_group) end

local text_align_group = {
    { keymaps = { "h" }, classes = { "text-left" } },
    { keymaps = { "l", "r" }, classes = { "text-right" } },
    { keymaps = { "k" }, classes = { "text-center" } },
    { keymaps = { "j" }, classes = { "text-justify" } },
    { keymaps = { "s" }, classes = { "text-start" } },
    { keymaps = { "e" }, classes = { "text-end" } },
}
M.change_text_align = function() M._classes_group_changer_menu(text_align_group) end

local list_style_position_group = {
    { keymaps = { "o" }, classes = { "list-inside" } },
    { keymaps = { "i" }, classes = { "list-outisde" } },
}
M.change_list_style_position = function() M._classes_group_changer_menu(list_style_position_group) end

local list_style_type_group = {
    { keymaps = { "/" }, classes = { "list-none" } },
    { keymaps = { "d" }, classes = { "list-disc" } },
    { keymaps = { "n" }, classes = { "list-normal" } },
}
M.change_list_style_type = function() M._classes_group_changer_menu(list_style_type_group) end

-- Divide

local divide_style_group = {
    { keymaps = { "s" }, classes = { "divide-solid" } },
    { keymaps = { "d" }, classes = { "divide-dashed" } },
    { keymaps = { "." }, classes = { "divide-dotted" } },
    { keymaps = { "2" }, classes = { "divide-double" } },
    { keymaps = { "n" }, classes = { "divide-none" } },
}
M.change_divide_style = function() M._classes_group_changer_menu(divide_style_group) end

-- Outline
local outline_style_group = {
    { keymaps = { "o" }, classes = { "outline" } },
    { keymaps = { "d" }, classes = { "outline-dashed" } },
    { keymaps = { "." }, classes = { "outline-dotted" } },
    { keymaps = { "2", "D" }, classes = { "outline-double" } },
    { keymaps = { "n", "/" }, classes = { "outline-none" } },
}
M.change_outline_style = function() M._classes_group_changer_menu(outline_style_group) end

-- Border

local border_style_group = {
    { keymaps = { "s" }, classes = { "border-solid" } },
    { keymaps = { "d" }, classes = { "border-dashed" } },
    { keymaps = { "." }, classes = { "border-dotted" } },
    { keymaps = { "2" }, classes = { "border-double" } },
    { keymaps = { "n" }, classes = { "border-none" } },
}
M.change_border_style = function() M._classes_group_changer_menu(border_style_group) end

-- Container
local container_group = {
    { keymaps = { "C", "c" }, classes = { "container" } },
}
M.change_container = function() M._classes_group_changer_menu(container_group) end

-- Break Before / After / Inside

local break_after_group = {
    { keymaps = { "A" }, classes = { "break-after-auto" } },
    { keymaps = { "a" }, classes = { "break-after-avoid" } },
    { keymaps = { "*" }, classes = { "break-after-all" } },
    "",
    { keymaps = { "p" }, classes = { "break-after-page" } },
    { keymaps = { "P" }, classes = { "break-after-avoid-page" } },
    "",
    { keymaps = { "l" }, classes = { "break-after-left" } },
    { keymaps = { "r" }, classes = { "break-after-right" } },
    { keymaps = { "c" }, classes = { "break-after-column" } },
}
M.change_break_after = function() M._classes_group_changer_menu(break_after_group) end

local break_before_group = {
    { keymaps = { "A" }, classes = { "break-before-auto" } },
    { keymaps = { "a" }, classes = { "break-before-avoid" } },
    { keymaps = { "*" }, classes = { "break-before-all" } },
    "",
    { keymaps = { "p" }, classes = { "break-before-page" } },
    { keymaps = { "P" }, classes = { "break-before-avoid-page" } },
    "",
    { keymaps = { "l" }, classes = { "break-before-left" } },
    { keymaps = { "r" }, classes = { "break-before-right" } },
    { keymaps = { "c" }, classes = { "break-before-column" } },
}
M.change_break_before = function() M._classes_group_changer_menu(break_before_group) end

local break_inside_group = {
    { keymaps = { "A" }, classes = { "break-inside-auto" } },
    { keymaps = { "a" }, classes = { "break-inside-avoid" } },
    "",
    { keymaps = { "P" }, classes = { "break-inside-avoid-page" } },
    { keymaps = { "c" }, classes = { "break-inside-column" } },
}
M.change_break_inside = function() M._classes_group_changer_menu(break_inside_group) end

-- Box Decoration
local box_decoration_group = {
    { keymaps = { "c" }, classes = { "box-decoration-clone" } },
    { keymaps = { "s" }, classes = { "box-decoration-slice" } },
}
M.change_box_decoration = function() M._classes_group_changer_menu(box_decoration_group) end

-- Box Sizing
local box_sizing_group = {
    { keymaps = { "b" }, classes = { "box-border" } },
    { keymaps = { "c" }, classes = { "box-content" } },
}
M.change_box_sizing = function() M._classes_group_changer_menu(box_sizing_group) end

-- Display
local display_group = {
    { keymaps = { "b" }, classes = { "block" } },
    { keymaps = { "ib" }, classes = { "inline-block" } },
    "",
    { keymaps = { "I" }, classes = { "inline" } },
    "",
    { keymaps = { "f" }, classes = { "flex" } },
    { keymaps = { "if" }, classes = { "inline-flex" } },
    "",
    { keymaps = { "r" }, classes = { "flow-root" } },
    "",
    { keymaps = { "g" }, classes = { "grid" } },
    { keymaps = { "ig" }, classes = { "inline-grid" } },
    "",
    { keymaps = { "C" }, classes = { "contents" } },
    "",
    { keymaps = { "l" }, classes = { "list-items" } },
    "",
    { keymaps = { "h", "n", "/" }, classes = { "hidden" } },
    "----------------------",
    { keymaps = { "T" }, classes = { "table" } },
    { keymaps = { "it", "iT" }, classes = { "inline-table" } },
    "",
    { keymaps = { "ca" }, classes = { "table-caption" } },
    { keymaps = { "ce" }, classes = { "table-cell" } },
    "",
    { keymaps = { "tr" }, classes = { "table-row" } },
    { keymaps = { "tR" }, classes = { "table-row-group" } },
    { keymaps = { "tc" }, classes = { "table-column" } },
    { keymaps = { "tC" }, classes = { "table-column-group" } },
    "",
    { keymaps = { "th" }, classes = { "table-header-group" } },
    { keymaps = { "tf" }, classes = { "table-footer-group" } },
}
M.change_display = function() M._classes_group_changer_menu(display_group) end

-- Float
local float_group = {
    { keymaps = { "r" }, classes = { "float-right" } },
    { keymaps = { "l" }, classes = { "float-left" } },
    { keymaps = { "n" }, classes = { "float-none" } },
}
M.change_float = function() M._classes_group_changer_menu(float_group) end

-- Clear
local clear_group = {
    { keymaps = { "r" }, classes = { "clear-right" } },
    { keymaps = { "l" }, classes = { "clear-left" } },
    { keymaps = { "b", "2" }, classes = { "clear-both" } },
    { keymaps = { "n" }, classes = { "clear-none" } },
}
M.change_clear = function() M._classes_group_changer_menu(clear_group) end

-- Isolate
local isolate_group = {
    { keymaps = { "i" }, classes = { "isolate" } },
    { keymaps = { "a", "A" }, classes = { "isolation-auto" } },
}
M.change_isolate = function() M._classes_group_changer_menu(isolate_group) end

-- Object Fit
local object_fit_group = {
    { keymaps = { "C" }, classes = { "object-contain" } },
    { keymaps = { "c" }, classes = { "object-cover" } },
    { keymaps = { "f", "F" }, classes = { "object-fill" } },
    { keymaps = { "n", "/" }, classes = { "object-none" } },
    { keymaps = { "s", "S" }, classes = { "object-scale-down" } },
}
M.change_object_fit = function() M._classes_group_changer_menu(object_fit_group) end

-- Object Position
local object_positon_group = {
    { keymaps = { "T" }, classes = { "object-top" } },
    { keymaps = { "B" }, classes = { "object-bottom" } },
    { keymaps = { "c", "C" }, classes = { "object-center" } },
    { keymaps = { "L", "h", "H" }, classes = { "object-left" } },
    { keymaps = { "R" }, classes = { "object-right" } },
    "",
    { keymaps = { "lb" }, classes = { "object-left-bottom" } },
    { keymaps = { "lt" }, classes = { "object-left-top" } },
    { keymaps = { "rb" }, classes = { "object-right-bottom" } },
    { keymaps = { "rt" }, classes = { "object-right-top" } },
}
M.change_object_positon = function() M._classes_group_changer_menu(object_positon_group) end

-- Overflow

local overflow_group = {
    { keymaps = { "a", "A" }, classes = { "overflow-auto" } },
    { keymaps = { "h", "H" }, classes = { "overflow-hidden" } },
    { keymaps = { "c", "C" }, classes = { "overflow-clip" } },
    { keymaps = { "v", "V" }, classes = { "overflow-visible" } },
    { keymaps = { "s", "S" }, classes = { "overflow-scroll" } },
}
M.change_overflow = function() M._classes_group_changer_menu(overflow_group) end

local overflow_x_group = {
    { keymaps = { "a", "A" }, classes = { "overflow-x-auto" } },
    { keymaps = { "h", "H" }, classes = { "overflow-x-hidden" } },
    { keymaps = { "c", "C" }, classes = { "overflow-x-clip" } },
    { keymaps = { "v", "V" }, classes = { "overflow-x-visible" } },
    { keymaps = { "s", "S" }, classes = { "overflow-x-scroll" } },
}
M.change_overflow_x = function() M._classes_group_changer_menu(overflow_x_group) end

local overflow_y_group = {
    { keymaps = { "a", "A" }, classes = { "overflow-y-auto" } },
    { keymaps = { "h", "B" }, classes = { "overflow-y-hidden" } },
    { keymaps = { "c", "C" }, classes = { "overflow-y-clip" } },
    { keymaps = { "v", "V" }, classes = { "overflow-y-visible" } },
    { keymaps = { "s", "S" }, classes = { "overflow-y-scroll" } },
}
M.change_overflow_y = function() M._classes_group_changer_menu(overflow_y_group) end

-- Overscroll

local overscroll_group = {
    { keymaps = { "a", "A" }, classes = { "overscroll-auto" } },
    { keymaps = { "c", "C" }, classes = { "overscroll-contain" } },
    { keymaps = { "n", "N" }, classes = { "overscroll-none" } },
}
M.change_overscroll = function() M._classes_group_changer_menu(overscroll_group) end

local overscroll_x_group = {
    { keymaps = { "a", "A" }, classes = { "overscroll-x-auto" } },
    { keymaps = { "c", "C" }, classes = { "overscroll-x-contain" } },
    { keymaps = { "n", "N" }, classes = { "overscroll-x-none" } },
}
M.change_overscroll_x = function() M._classes_group_changer_menu(overscroll_x_group) end

local overscroll_y_group = {
    { keymaps = { "a", "A" }, classes = { "overscroll-y-auto" } },
    { keymaps = { "c", "C" }, classes = { "overscroll-y-contain" } },
    { keymaps = { "n", "N" }, classes = { "overscroll-y-none" } },
}
M.change_overscroll_y = function() M._classes_group_changer_menu(overscroll_y_group) end

-- Position
local position_group = {
    { keymaps = { "s" }, classes = { "sticky" } },
    { keymaps = { "f", "F" }, classes = { "fixed" } },
    { keymaps = { "a", "A" }, classes = { "absolute" } },
    { keymaps = { "r", "R" }, classes = { "relative" } },
    { keymaps = { "S" }, classes = { "static" } },
}
M.change_position = function() M._classes_group_changer_menu(position_group) end

-- Visibility
local visibility_group = {
    { keymaps = { "v", "V" }, classes = { "visible" } },
    { keymaps = { "i", "I" }, classes = { "invisible" } },
    { keymaps = { "c", "C" }, classes = { "collapse" } },
}
M.change_visibility = function() M._classes_group_changer_menu(visibility_group) end

-- Grid Auto Flow
local grid_flow_group = {
    { keymaps = { "r" }, classes = { "grid-flow-row" } },
    { keymaps = { "c" }, classes = { "grid-flow-col" } },
    { keymaps = { "d" }, classes = { "grid-flow-dense" } },
    { keymaps = { "R" }, classes = { "grid-flow-row-dense" } },
    { keymaps = { "C" }, classes = { "grid-flow-col-dense" } },
}
M.change_grid_flow = function() M._classes_group_changer_menu(grid_flow_group) end

-- Background Attachment
local background_attachments_group = {
    { keymaps = { "f" }, classes = { "bg-fixed" } },
    { keymaps = { "l" }, classes = { "bg-local" } },
    { keymaps = { "s" }, classes = { "bg-scroll" } },
}
M.change_background_attachment = function()
    M._classes_group_changer_menu(background_attachments_group)
end

-- Background Clip
local background_clip_group = {
    { keymaps = { "b" }, classes = { "bg-clip-border" } },
    { keymaps = { "p" }, classes = { "bg-clip-padding" } },
    { keymaps = { "c" }, classes = { "bg-clip-content" } },
    { keymaps = { "t" }, classes = { "bg-clip-text" } },
}
M.change_background_clip = function() M._classes_group_changer_menu(background_clip_group) end

-- Background Origin
local background_origin_group = {
    { keymaps = { "b" }, classes = { "bg-origin-border" } },
    { keymaps = { "p" }, classes = { "bg-origin-padding" } },
    { keymaps = { "c" }, classes = { "bg-origin-content" } },
}
M.change_background_origin = function() M._classes_group_changer_menu(background_origin_group) end

-- Background Repeat
local background_repeat_group = {
    { keymaps = { "r" }, classes = { "bg-repeat" } },
    { keymaps = { "n", "/" }, classes = { "bg-no-repeat" } },
    { keymaps = { "x" }, classes = { "bg-repeat-x" } },
    { keymaps = { "y" }, classes = { "bg-repeat-y" } },
    { keymaps = { "R" }, classes = { "bg-repeat-round" } },
    { keymaps = { "s", "S" }, classes = { "bg-repeat-square" } },
}
M.change_background_repeat = function() M._classes_group_changer_menu(background_repeat_group) end

-- Background Position
local backround_position_group = {
    { keymaps = { "t" }, classes = { "bg-top" } },
    { keymaps = { "b" }, classes = { "bg-bottom" } },
    { keymaps = { "c" }, classes = { "bg-center" } },
    { keymaps = { "l" }, classes = { "bg-left" } },
    { keymaps = { "r" }, classes = { "bg-right" } },
    "",
    { keymaps = { "u" }, classes = { "bg-left-top" } },
    { keymaps = { "i" }, classes = { "bg-left-bottom" } },
    { keymaps = { "o" }, classes = { "bg-right-top" } },
    { keymaps = { "p" }, classes = { "bg-right-bottom" } },
}
M.change_backround_position = function() M._classes_group_changer_menu(backround_position_group) end

-- Background Size
local background_size_group = {
    { keymaps = { "a" }, classes = { "bg-auto" } },
    { keymaps = { "c" }, classes = { "bg-cover" } },
    { keymaps = { "C" }, classes = { "bg-contain" } },
}
M.change_background_size = function() M._classes_group_changer_menu(background_size_group) end

-- Background Image
local background_image_group = {
    { keymaps = { "n", "/" }, classes = { "bg-none" } },
    "",
    { keymaps = { "t" }, classes = { "bg-gradient-to-t" } },
    { keymaps = { "l" }, classes = { "bg-gradient-to-l" } },
    { keymaps = { "b" }, classes = { "bg-gradient-to-b" } },
    { keymaps = { "r" }, classes = { "bg-gradient-to-r" } },
    "",
    { keymaps = { "u" }, classes = { "bg-gradient-to-tl" } },
    { keymaps = { "p" }, classes = { "bg-gradient-to-tr" } },
    { keymaps = { "i" }, classes = { "bg-gradient-to-bl" } },
    { keymaps = { "o" }, classes = { "bg-gradient-to-br" } },
}
M.change_background_image = function() M._classes_group_changer_menu(background_image_group) end

-- Mix Blend Mode
local mix_blend_mode_group = {
    { keymaps = { "n" }, classes = { "mix-blend-normal" } },
    { keymaps = { "m" }, classes = { "mix-blend-multiply" } },
    { keymaps = { "s" }, classes = { "mix-blend-screen" } },
    { keymaps = { "o" }, classes = { "mix-blend-overlay" } },
    { keymaps = { "d" }, classes = { "mix-blend-darken" } },
    { keymaps = { "l" }, classes = { "mix-blend-lighten" } },
    "",
    { keymaps = { "D" }, classes = { "mix-blend-color-dodge" } },
    { keymaps = { "B" }, classes = { "mix-blend-color-burn" } },
    { keymaps = { "hl" }, classes = { "mix-blend-hard-light" } },
    { keymaps = { "sl" }, classes = { "mix-blend-soft-light" } },
    "",
    { keymaps = { "D" }, classes = { "mix-blend-difference" } },
    { keymaps = { "E" }, classes = { "mix-blend-exclusion" } },
    "",
    { keymaps = { "hu", "he" }, classes = { "mix-blend-hue" } },
    { keymaps = { "S" }, classes = { "mix-blend-saturation" } },
    { keymaps = { "c" }, classes = { "mix-blend-color" } },
    { keymaps = { "u" }, classes = { "mix-blend-luminosity" } },
    { keymaps = { "p" }, classes = { "mix-blend-plus-lighter" } },
}
M.change_mix_blend_mode = function() M._classes_group_changer_menu(mix_blend_mode_group) end

-- Background Blend Mode
local bg_blend_mode_group = {
    { keymaps = { "n" }, classes = { "bg-blend-normal" } },
    { keymaps = { "m" }, classes = { "bg-blend-multiply" } },
    { keymaps = { "s" }, classes = { "bg-blend-screen" } },
    { keymaps = { "o" }, classes = { "bg-blend-overlay" } },
    { keymaps = { "d" }, classes = { "bg-blend-darken" } },
    { keymaps = { "l" }, classes = { "bg-blend-lighten" } },
    "",
    { keymaps = { "D" }, classes = { "bg-blend-color-dodge" } },
    { keymaps = { "B" }, classes = { "bg-blend-color-burn" } },
    { keymaps = { "hl" }, classes = { "bg-blend-hard-light" } },
    { keymaps = { "sl" }, classes = { "bg-blend-soft-light" } },
    "",
    { keymaps = { "D" }, classes = { "bg-blend-difference" } },
    { keymaps = { "E" }, classes = { "bg-blend-exclusion" } },
    "",
    { keymaps = { "hu", "he" }, classes = { "bg-blend-hue" } },
    { keymaps = { "S" }, classes = { "bg-blend-saturation" } },
    { keymaps = { "c" }, classes = { "bg-blend-color" } },
    { keymaps = { "u" }, classes = { "bg-blend-luminosity" } },
    { keymaps = { "p" }, classes = { "bg-blend-plus-lighter" } },
}
M.change_bg_blend_mode = function() M._classes_group_changer_menu(bg_blend_mode_group) end

--------------------------------- Tables ---------------------------------

-- Border Collapse
local border_collapse_group = {
    { keymaps = { "c", "C" }, classes = { "border-collapse" } },
    { keymaps = { "s", "S" }, classes = { "border-separate" } },
}
M.change_border_collapse = function() M._classes_group_changer_menu(border_collapse_group) end

-- Table Layout
local table_layout_group = {
    { keymaps = { "a", "A" }, classes = { "table-auto" } },
    { keymaps = { "f", "F" }, classes = { "table-fixed" } },
}
M.change_table_layout = function() M._classes_group_changer_menu(table_layout_group) end

-- Caption Side
local caption_side_group = {
    { keymaps = { "t", "T" }, classes = { "caption-top" } },
    { keymaps = { "b", "B" }, classes = { "caption-bottom" } },
}
M.change_caption_side = function() M._classes_group_changer_menu(caption_side_group) end

--------------------------------- Transitions ---------------------------------

-- Transition timing Function
local transition_timing_group = {
    { keymaps = { "l" }, classes = { "ease-linear" } },
    { keymaps = { "i" }, classes = { "ease-in" } },
    { keymaps = { "o" }, classes = { "ease-out" } },
    { keymaps = { "2", "a" }, classes = { "ease-in-out" } },
}
M.change_transition_timing = function() M._classes_group_changer_menu(transition_timing_group) end

-- Animation
local animation_group = {
    { keymaps = { "n", "/" }, classes = { "none" } },
    { keymaps = { "s" }, classes = { "spin" } },
    { keymaps = { "p" }, classes = { "ping" } },
    { keymaps = { "P" }, classes = { "pulse" } },
    { keymaps = { "b" }, classes = { "bounce" } },
}
M.change_animation = function() M._classes_group_changer_menu(animation_group) end

-- Apprearance
local appearance_group = {
    { keymaps = { "n", "/" }, classes = { "appearance-none" } },
}
M.change_appearance = function() M._classes_group_changer_menu(appearance_group) end

-- Cursor
local cursor_group = {
    { keymaps = { "A" }, classes = { "cursor-auto" } },
    { keymaps = { "d" }, classes = { "cursor-default" } },
    { keymaps = { "p" }, classes = { "cursor-pointer" } },
    { keymaps = { "w" }, classes = { "cursor-wait" } },
    { keymaps = { "t" }, classes = { "cursor-text" } },
    { keymaps = { "m" }, classes = { "cursor-move" } },
    { keymaps = { "h" }, classes = { "cursor-help" } },
    { keymaps = { "N" }, classes = { "cursor-not-allowed" } },
    { keymaps = { "/" }, classes = { "cursor-none" } },
    "",
    { keymaps = { "cm" }, classes = { "cursor-context-menu" } },
    { keymaps = { "P" }, classes = { "cursor-progress" } },
    { keymaps = { "ce" }, classes = { "cursor-cell" } },
    { keymaps = { "ch" }, classes = { "cursor-crosshair" } },
    { keymaps = { "v" }, classes = { "cursor-vertial-text" } },
    { keymaps = { "al" }, classes = { "cursor-alias" } },
    { keymaps = { "cp" }, classes = { "cursor-copy" } },
    { keymaps = { "nd" }, classes = { "cursor-no-drop" } },
    { keymaps = { "g" }, classes = { "cursor-grab" } },
    { keymaps = { "G" }, classes = { "cursor-grabbing" } },
    "",
    { keymaps = { "as" }, classes = { "cursor-all-scroll" } },
    { keymaps = { "cr" }, classes = { "cursor-col-resize" } },
    { keymaps = { "rr" }, classes = { "cursor-row-resize" } },
    { keymaps = { "nr" }, classes = { "cursor-n-resize" } },
    { keymaps = { "er" }, classes = { "cursor-e-resize" } },
    { keymaps = { "sr" }, classes = { "cursor-s-resize" } },
    { keymaps = { "wr" }, classes = { "cursor-w-resize" } },
    { keymaps = { "ne" }, classes = { "cursor-ne-resize" } },
    { keymaps = { "nw" }, classes = { "cursor-nw-resize" } },
    { keymaps = { "se" }, classes = { "cursor-se-resize" } },
    { keymaps = { "sw" }, classes = { "cursor-sw-resize" } },
    { keymaps = { "ew" }, classes = { "cursor-ew-resize" } },
    { keymaps = { "ns" }, classes = { "cursor-ns-resize" } },
    { keymaps = { "NE" }, classes = { "cursor-nesw-resize" } },
    { keymaps = { "NW" }, classes = { "cursor-nwse-resize" } },
    { keymaps = { "i" }, classes = { "cursor-zoom-in" } },
    { keymaps = { "o" }, classes = { "cursor-zoom-out" } },
}
M.change_cursor = function() M._classes_group_changer_menu(cursor_group) end

-- Pointer Events
local poiiter_events_group = {
    { keymaps = { "n", "N", "/" }, classes = { "pointer-events-none" } },
    { keymaps = { "a", "A" }, classes = { "pointer-events-auto" } },
}
M.change_pointer_events = function() M._classes_group_changer_menu(poiiter_events_group) end

-- Resize
local resize_group = {
    { keymaps = { "r" }, classes = { "resize" } },
    { keymaps = { "x" }, classes = { "resize-x" } },
    { keymaps = { "y" }, classes = { "resize-y" } },
    { keymaps = { "n", "N", "/" }, classes = { "resize-none" } },
}
M.change_resize = function() M._classes_group_changer_menu(resize_group) end

-- Scrol Behavior
local scroll_behavior_group = {
    { keymaps = { "a", "A" }, classes = { "scroll-auto" } },
    { keymaps = { "s", "S" }, classes = { "scroll-smooth" } },
}
M.change_scroll_behavior = function() M._classes_group_changer_menu(scroll_behavior_group) end

-- Scroll Snap Align
local snap_align_group = {
    { keymaps = { "s" }, classes = { "snap-start" } },
    { keymaps = { "e" }, classes = { "snap-end" } },
    { keymaps = { "c" }, classes = { "snap-center" } },
    { keymaps = { "a", "n", "/" }, classes = { "snap-align-none" } },
}
M.change_snap_align = function() M._classes_group_changer_menu(snap_align_group) end

-- Scroll Snap Stop
local snap_stop_group = {
    { keymaps = { "n" }, classes = { "snap-normal" } },
    { keymaps = { "a" }, classes = { "snap-always" } },
}
M.change_snap_stop = function() M._classes_group_changer_menu(snap_stop_group) end

-- Scrol Snap type
local snap_type_group = {
    { keymaps = { "x" }, classes = { "snap-x" } },
    { keymaps = { "y" }, classes = { "snap-y" } },
    { keymaps = { "n", "/" }, classes = { "snap-none" } },
    { keymaps = { "b", "2" }, classes = { "snap-both" } },
    { keymaps = { "m" }, classes = { "snap-mandatory" } },
    { keymaps = { "p" }, classes = { "snap-proximity" } },
}
M.change_snap_type = function() M._classes_group_changer_menu(snap_type_group) end

-- Touch Action
local touch_action_group = {
    { keymaps = { "a" }, classes = { "touch-auto" } },
    { keymaps = { "n" }, classes = { "touch-none" } },
    { keymaps = { "x" }, classes = { "touch-pan-x" } },
    { keymaps = { "y" }, classes = { "touch-pan-y" } },
    { keymaps = { "l" }, classes = { "touch-pan-left" } },
    { keymaps = { "r" }, classes = { "touch-pan-right" } },
    { keymaps = { "u" }, classes = { "touch-pan-up" } },
    { keymaps = { "d" }, classes = { "touch-pan-down" } },
    { keymaps = { "z" }, classes = { "touch-pinch-zoom" } },
    { keymaps = { "m" }, classes = { "touch-manipulation" } },
}
M.change_touch_action = function() M._classes_group_changer_menu(touch_action_group) end

-- User Select
local user_select_group = {
    { keymaps = { "a" }, classes = { "select-auto" } },
    { keymaps = { "t" }, classes = { "select-text" } },
    { keymaps = { "A" }, classes = { "select-all" } },
    { keymaps = { "n", "/" }, classes = { "select-none" } },
}
M.change_user_select = function() M._classes_group_changer_menu(user_select_group) end

-- Screen Readers
local screen_readers_group = {
    { keymaps = { "s" }, classes = { "sr-only" } },
    { keymaps = { "n", "/" }, classes = { "not-sr-only" } },
}
M.change_screen_readers = function() M._classes_group_changer_menu(screen_readers_group) end

-- Group
local group_group = {
    { keymaps = { "g" }, classes = { "group" } },
}
M.change_group = function() M._classes_group_changer_menu(group_group) end

-- Custom (non-standard) -------------------------------

local flex_align_group = {
    { keymaps = { "i" }, classes = { "items-center" } },
    { keymaps = { "j" }, classes = { "justify-center" } },
    { keymaps = { "b" }, classes = { "justify-between" } },
    { keymaps = { "c" }, classes = { "items-center", "justify-center" } },
    { keymaps = { "a" }, classes = { "content-between" } },
}
M.change_flex_align_properties = function() M._classes_group_changer_menu(flex_align_group) end

local quick_grid_group = {
    { keymaps = { "1" }, classes = { "grid", "grid-cols-1" } },
    { keymaps = { "2" }, classes = { "grid", "grid-cols-2" } },
    { keymaps = { "3" }, classes = { "grid", "grid-cols-3" } },
    { keymaps = { "4" }, classes = { "grid", "grid-cols-4" } },
    { keymaps = { "5" }, classes = { "grid", "grid-cols-5" } },
}
M.change_quick_grid_group = function() M._classes_group_changer_menu(quick_grid_group) end

local quick_flex_group = {
    { keymaps = { "r" }, classes = { "flex", "flex-row", "gap-10" } },
    { keymaps = { "c" }, classes = { "flex", "flex-col", "gap-10" } },
    {
        keymaps = { "j" },
        classes = {
            "h-screen",
            "flex",
            "flex-col",
            "items-center",
            "justify-center",
            "gap-14",
            "bg-stone-900",
            "text-white",
        },
    },
}
M.change_quick_flex_group = function() M._classes_group_changer_menu(quick_flex_group) end

local quick_text_group = {
    { keymaps = { "j" }, classes = { "text-6xl" } },
}
M.change_quick_text_group = function() M._classes_group_changer_menu(quick_text_group) end

return M

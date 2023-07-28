local Hydra = require("hydra")
local catalyst = require("deliberate.lib.catalyst")
local visual_collector = require("deliberate.api.visual_collector")
local selection = require("deliberate.lib.selection")
local navigator = require("deliberate.api.navigator")
local pms_menu = require("deliberate.ui.pms_menu")
local colors_menu = require("deliberate.ui.colors_menu")
local cgm = require("deliberate.ui.classes_groups_menu")
local uniform = require("deliberate.api.uniform")
local utils = require("deliberate.lib.utils")

local exit_hydra = function()
    vim.api.nvim_input("<Nul>")
    visual_collector.stop()
end

local heads = {}

-------------------------------------------- <Nop>

local nop_list = { "d", "D", "x", "r", "R", "c", "u", "U" }
for _, keymap in ipairs(nop_list) do
    local hydra_mapping = { keymap, function() end, { nowait = true } }
    table.insert(heads, hydra_mapping)
end

-------------------------------------------- Manual Heads

local manual_heads = {
    {
        "l",
        function() require("deliberate.ui.tag_menu").add_tag_next() end,
        { nowait = true },
    },
    {
        "h",
        function() require("deliberate.ui.tag_menu").add_tag_previous() end,
        { nowait = true },
    },
    {
        "i",
        function() require("deliberate.ui.tag_menu").add_tag_inside() end,
        { nowait = true },
    },

    {
        ";",
        function() require("deliberate.ui.attribute_changer_menu").show() end,
        { nowait = true },
    },
    {
        "<A-;>",
        function() require("deliberate.ui.attribute_changer_menu").remove() end,
        { nowait = true },
    },

    {
        "C",
        function() require("deliberate.ui.content_replacer_menu").replace("contents.txt") end,
        { nowait = true },
    },
    {
        "<C-c>",
        function()
            require("deliberate.ui.content_replacer_menu").replace_with_group("contents.txt")
        end,
        { nowait = true },
    },
    {
        "<C-S-c>",
        function()
            require("deliberate.ui.content_replacer_menu").replace_with_group("contents.txt", true)
        end,
        { nowait = true },
    },

    {
        "!",
        function() require("deliberate.ui.tag_name_changer_menu")._change_tag_menu() end,
        { nowait = true },
    },
    {
        "@",
        function() require("deliberate.api.tag_name_changer").toggle_motion() end,
        { nowait = true },
    },
    {
        "#",
        function() require("deliberate.api.className_to_clsx").toggle_clsx() end,
        { nowait = true },
    },

    {
        "sr",
        function() require("deliberate.ui.image_src_menu").change_image_src() end,
        { nowait = true },
    },

    {
        "y",
        function() require("deliberate.api.yank").call() end,
        { nowait = true },
    },

    {
        "<A-w>",
        function() require("deliberate.api.wrap").call({ tag = "div" }) end,
        { nowait = true },
    },
    {
        "<A-S-w>",
        function() require("deliberate.api.wrap").call({ tag = "" }) end,
        { nowait = true },
    },

    {
        "v",
        function() visual_collector.toggle() end,
        { nowait = true },
    },
    {
        "V",
        function() selection.select_all_html_siblings() end,
        { nowait = true },
    },

    {
        ".",
        function() require("deliberate.api.dot_repeater").call() end,
        { nowait = true },
    },
    {
        ">",
        function() require("deliberate.api.menu_repeater").call() end,
        { nowait = true },
    },

    {
        "u",
        function() require("deliberate.api.history").undo() end,
        { nowait = true },
    },
    {
        "<C-r>",
        function() require("deliberate.api.history").redo() end,
        { nowait = true },
    },

    {
        "dl",
        function() require("deliberate.api.delete").call() end,
        { nowait = true },
    },

    {
        "`",
        function() require("deliberate.ui.pseudo_classes_input").show() end,
        { nowait = true },
    },

    {
        "~",
        function()
            vim.api.nvim_input("`")
            vim.schedule(function() vim.api.nvim_input("`") end)
        end,
        { nowait = true },
    },

    { ",", function() vim.api.nvim_input("C,") end, { nowait = true } },

    {
        "\\",
        function()
            exit_hydra()
            vim.api.nvim_input("cit{")
        end,
        { nowait = true },
    },
    {
        "{",
        function()
            exit_hydra()
            vim.api.nvim_input("O{<CR>")
        end,
        { nowait = true },
    },
    {
        "}",
        function()
            exit_hydra()
            vim.api.nvim_input("o{<CR>")
        end,
        { nowait = true },
    },

    {
        "<Plug>DeliberateHydraEsc",
        function()
            if not selection.select_move_is_active() and not visual_collector.is_active() then
                exit_hydra()
            end
            if visual_collector.is_active() then visual_collector.stop() end
            if selection.select_move_is_active() then selection.clear(true) end
        end,
        { nowait = true },
    },

    -- workaround to programmatically exit Hydra
    -- HACK: using <Nul> messes up Telescope if user set `initial_mode` to `insert`
    { "<Nul>", nil, { exit = true } },
}

for _, m_head in ipairs(manual_heads) do
    table.insert(heads, m_head)
end

-------------------------------------------- Local Helpers

local add_heads_from_tbl = function(tbl)
    for keymap, fn in pairs(tbl) do
        local hydra_mapping = {
            keymap,
            function() fn() end,
            { nowait = true },
        }
        table.insert(heads, hydra_mapping)
    end
end

-------------------------------------------- Colors Menus

local keymap_to_color_menu_fn = {
    ["t"] = colors_menu.text,
    ["B"] = colors_menu.background,
    ["bc"] = colors_menu.border,
    ["dc"] = colors_menu.divide,
    ["Rc"] = colors_menu.ring,
    ["RC"] = colors_menu.ring_offset,
    ["zf"] = colors_menu.from,
    ["zv"] = colors_menu.via,
    ["zt"] = colors_menu.to,
    ["<space>dc"] = colors_menu.decoration,
    ["<space>BC"] = colors_menu.shadow,
    ["AC"] = colors_menu.accent,
    ["cc"] = colors_menu.caret,
    ["fc"] = colors_menu.fill,
    ["sc"] = colors_menu.stroke,
    ["oc"] = colors_menu.outline,
}
add_heads_from_tbl(keymap_to_color_menu_fn)

-------------------------------------------- Tailwind Classes that can have Arbitrary Values

-- Non Axis
local non_axis_map = {
    ["fz"] = pms_menu.change_font_size,
    ["ff"] = pms_menu.change_font_family,
    ["fC"] = pms_menu.change_line_clamp,
    ["fT"] = pms_menu.change_tracking,
    ["fL"] = pms_menu.change_leading,
    ["<space>dt"] = pms_menu.change_td_thickness,
    ["<space>in"] = pms_menu.change_text_indent,
    ["<space>uo"] = pms_menu.change_underline_offset,
    ["<space>al"] = pms_menu.change_vertical_align,
    ["<space>co"] = pms_menu.change_content,
    ["<space>li"] = pms_menu.change_list_image,
    ["O"] = pms_menu.change_opacity,
    ["bo"] = pms_menu.change_border_opacity,
    ["do"] = pms_menu.change_divide_opacity,
    ["Rw"] = pms_menu.change_ring_width,
    ["Ro"] = pms_menu.change_ring_offset,
    ["RO"] = pms_menu.change_ring_opacity,
    ["W"] = pms_menu.change_width,
    ["E"] = pms_menu.change_height,
    ["ww"] = pms_menu.change_min_width,
    ["we"] = pms_menu.change_min_height,
    ["wW"] = pms_menu.change_max_width,
    ["wE"] = pms_menu.change_max_height,
    ["fx"] = pms_menu.change_flex,
    ["fb"] = pms_menu.change_basis,
    ["fg"] = pms_menu.change_grow,
    ["fs"] = pms_menu.change_shrink,
    ["fo"] = pms_menu.change_order,
    ["AR"] = pms_menu.change_aspect_ratio,
    ["co"] = pms_menu.change_columns,
    ["at"] = pms_menu.change_top,
    ["ab"] = pms_menu.change_bottom,
    ["al"] = pms_menu.change_left,
    ["ar"] = pms_menu.change_right,
    ["Is"] = pms_menu.change_inset_start,
    ["Ie"] = pms_menu.change_inset_end,
    ["zi"] = pms_menu.change_z_index,
    ["gc"] = pms_menu.change_grid_cols,
    ["cS"] = pms_menu.change_col_span,
    ["cs"] = pms_menu.change_col_start,
    ["ce"] = pms_menu.change_col_end,
    ["gr"] = pms_menu.change_grid_rows,
    ["rS"] = pms_menu.change_row_span,
    ["rs"] = pms_menu.change_row_start,
    ["re"] = pms_menu.change_row_end,
    ["Ar"] = pms_menu.change_auto_rows,
    ["Ac"] = pms_menu.change_auto_cols,
    ["<space>bp"] = pms_menu.change_bg_position,
    ["<space>BS"] = pms_menu.change_box_shadow,
    ["<space>Bl"] = pms_menu.change_blur,
    ["<space>Br"] = pms_menu.change_brightness,
    ["<space>Co"] = pms_menu.change_contrast,
    ["<space>Dr"] = pms_menu.change_drop_shadow,
    ["<space>Gr"] = pms_menu.change_grayscale,
    ["<space>Hr"] = pms_menu.change_hue_rotate,
    ["<space>Iv"] = pms_menu.change_invert,
    ["<space>Sa"] = pms_menu.change_saturate,
    ["<space>Pi"] = pms_menu.change_sepia,
    ["<space>Bd"] = pms_menu.change_backdrop_blur,
    ["<space>Bb"] = pms_menu.change_backdrop_brightness,
    ["<space>Bc"] = pms_menu.change_backdrop_contrast,
    ["<space>Bg"] = pms_menu.change_backdrop_grayscale,
    ["<space>Bh"] = pms_menu.change_backdrop_hue_rotate,
    ["<space>Bi"] = pms_menu.change_backrop_invert,
    ["<space>Bo"] = pms_menu.change_backdrop_opacity,
    ["<space>Bs"] = pms_menu.change_backdrop_saturate,
    ["<space>Bp"] = pms_menu.change_backdrop_sepia,
    ["Tr"] = pms_menu.change_transition,
    ["Td"] = pms_menu.change_duration,
    ["TD"] = pms_menu.change_delay,
    ["Rt"] = pms_menu.change_rotate,
    ["Sk"] = pms_menu.change_skew,
    ["or"] = pms_menu.change_origin,
    ["<space>wc"] = pms_menu.change_will_change,
    ["sw"] = pms_menu.change_stroke_width,
    ["ow"] = pms_menu.change_outline_width,
    ["oo"] = pms_menu.change_outline_offset,
}
add_heads_from_tbl(non_axis_map)

-- With Axis
local axis_map = {
    p = { { "", "x", "y", "t", "b", "l", "r", "e", "s" }, pms_menu.change_padding },
    m = { { "", "x", "y", "t", "b", "l", "r", "e", "s" }, pms_menu.change_margin },
    s = { { "x", "y" }, pms_menu.change_spacing },
    d = { { "x", "y" }, pms_menu.change_divide },
    b = { { "", "t", "b", "l", "r" }, pms_menu.change_border_width },
    r = {
        {
            { "a", "" },
            { "h", "l" },
            { "l", "r" },
            { "k", "t" },
            { "j", "b" },
            { "u", "tl" },
            { "i", "bl" },
            { "o", "br" },
            { "p", "tr" },
        },
        pms_menu.change_border_radius,
    },
    ["inset"] = { { "", "x", "y" }, pms_menu.change_inset },
    ["gap"] = { { "", "x", "y" }, pms_menu.change_gap },
    ["border-spacing"] = { { "x", "y" }, pms_menu.change_border_spacing },
    ["scale"] = { { "", "x", "y" }, pms_menu.change_scale },
    ["translate"] = { { "x", "y" }, pms_menu.change_translate },
    ["scroll-m"] = { { "", "x", "y", "t", "b", "l", "r", "e", "s" }, pms_menu.change_scroll_margin },
    ["scroll-p"] = {
        { "", "x", "y", "t", "b", "l", "r", "e", "s" },
        pms_menu.change_scroll_padding,
    },
}

local find_axis_keymap = function(property, key_axis)
    if property == "inset" then
        if key_axis == "" then
            return "II"
        else
            property = "I"
        end
    end
    if property == "gap" then
        if key_axis == "" then
            return "G"
        else
            property = "g"
        end
    end
    if property == "scale" then
        if key_axis == "" then
            return "Sc"
        else
            property = "S"
        end
    end
    if property == "scroll-m" then
        if key_axis == "" then
            return "sM"
        else
            property = "sm"
        end
    end
    if property == "scroll-p" then
        if key_axis == "" then
            return "sP"
        else
            property = "sp"
        end
    end

    if property == "translate" then property = "T" end
    if property == "border-spacing" then property = "Ts" end

    if property == "b" and key_axis == "" then return "bd" end
    if key_axis == "" then return string.upper(property) end
    return property .. key_axis
end

for property, value_tbl in pairs(axis_map) do
    local axies, fn = unpack(value_tbl)
    for _, key_to_axis in ipairs(axies) do
        local key_axis, argument_axis
        if type(key_to_axis) == "string" then
            key_axis, argument_axis = key_to_axis, key_to_axis
        elseif type(key_to_axis) == "table" then
            key_axis, argument_axis = unpack(key_to_axis)
        end
        local hydra_mapping = {
            find_axis_keymap(property, key_axis),
            function() fn({ axis = argument_axis }) end,
            { nowait = true },
        }
        table.insert(heads, hydra_mapping)
    end
end

-------------------------------------------- Replace Classes Groups

local classes_groups_dict = {
    ["F"] = { cgm.change_flex_properties },
    ["fw"] = { cgm.change_flex_wrap_properties },
    ["Al"] = { cgm.change_flex_align_properties },
    ["AA"] = { cgm.change_font_smoothing },
    ["fS"] = { cgm.change_font_style },
    ["fW"] = { cgm.change_font_weight },
    ["<space>ta"] = { cgm.change_text_align },
    ["<space>td"] = { cgm.change_text_decoration },
    ["<space>tf"] = { cgm.change_text_transform },
    ["<space>to"] = { cgm.change_text_overflow },
    ["<space>ds"] = { cgm.change_decoration_style },
    ["<space>ws"] = { cgm.change_whitespace },
    ["<space>wb"] = { cgm.change_word_break },
    ["<space>hy"] = { cgm.change_hyphens },
    ["fV"] = { cgm.change_font_variant_numeric },
    ["<space>lp"] = { cgm.change_list_style_position },
    ["<space>lt"] = { cgm.change_list_style_type },
    ["ds"] = { cgm.change_divide_style },
    ["bs"] = { cgm.change_border_style },
    ["bB"] = { cgm.change_break_before },
    ["bA"] = { cgm.change_break_after },
    ["bI"] = { cgm.change_break_inside },
    ["bD"] = { cgm.change_box_decoration },
    ["bS"] = { cgm.change_box_sizing },
    ["<space>c"] = { cgm.change_container },
    ["di"] = { cgm.change_display },
    ["fl"] = { cgm.change_float },
    ["cl"] = { cgm.change_clear },
    ["IS"] = { cgm.change_isolate },
    ["of"] = { cgm.change_object_fit },
    ["op"] = { cgm.change_object_positon },
    ["ov"] = { cgm.change_overflow },
    ["ox"] = { cgm.change_overflow_x },
    ["oy"] = { cgm.change_overflow_y },
    ["oV"] = { cgm.change_overscroll },
    ["oX"] = { cgm.change_overscroll_x },
    ["oY"] = { cgm.change_overscroll_y },
    ["po"] = { cgm.change_position },
    ["<space>v"] = { cgm.change_visibility },
    ["gf"] = { cgm.change_grid_flow },
    ["ac"] = { cgm.change_align_content },
    ["as"] = { cgm.change_align_self },
    ["ai"] = { cgm.change_align_items },
    ["<space>jc"] = { cgm.change_justifity_content },
    ["<space>ji"] = { cgm.change_justifity_items },
    ["<space>js"] = { cgm.change_justifity_self },
    ["<space>pc"] = { cgm.change_place_content },
    ["<space>pi"] = { cgm.change_place_items },
    ["<space>ps"] = { cgm.change_place_self },
    ["<space>ba"] = { cgm.change_background_attachment },
    ["<space>bc"] = { cgm.change_background_clip },
    ["<space>bo"] = { cgm.change_background_origin },
    ["<space>br"] = { cgm.change_background_repeat },
    ["<space>bp"] = { cgm.change_backround_position },
    ["<space>bs"] = { cgm.change_background_size },
    ["<space>bi"] = { cgm.change_background_image },
    ["<space>mb"] = { cgm.change_mix_blend_mode },
    ["<space>bb"] = { cgm.change_bg_blend_mode },
    ["Tc"] = { cgm.change_border_collapse },
    ["Tl"] = { cgm.change_table_layout },
    ["TC"] = { cgm.change_caption_side },
    ["Tt"] = { cgm.change_transition_timing },
    ["An"] = { cgm.change_animation },
    ["ap"] = { cgm.change_appearance },
    ["cu"] = { cgm.change_cursor },
    ["<space>pe"] = { cgm.change_pointer_events },
    ["RS"] = { cgm.change_resize },
    ["sb"] = { cgm.change_scroll_behavior },
    ["sn"] = { cgm.change_snap_align },
    ["st"] = { cgm.change_snap_stop },
    ["TA"] = { cgm.change_touch_action },
    ["<space>us"] = { cgm.change_user_select },
    ["<space>sr"] = { cgm.change_screen_readers },
    ["<space>g"] = { cgm.change_group },
    ["os"] = { cgm.change_outline_style },
}

for keymap, fn_and_args in pairs(classes_groups_dict) do
    local fn, args = unpack(fn_and_args)
    local hydra_mapping = {
        keymap,
        function() fn(unpack(args or {})) end,
        { nowait = true },
    }
    table.insert(heads, hydra_mapping)
end

-------------------------------------------- Navigation & Selection

local basic_navigation = {
    ["j"] = { destination = "next" },
    ["k"] = { destination = "previous" },
    ["J"] = { destination = "next-sibling" },
    ["K"] = { destination = "previous-sibling" },
    ["H"] = { destination = "parent" },
    ["<Tab>"] = { destination = "next", select_move = true },
    ["<S-Tab>"] = { destination = "previous", select_move = true },
}

for keymap, args in pairs(basic_navigation) do
    local hydra_mapping = {
        keymap,
        function() utils.execute_with_count(navigator.move, args) end,
        { nowait = true },
    }
    table.insert(heads, hydra_mapping)
end

-- Toggle current selection
table.insert(heads, {
    "<A-Tab>",
    function() catalyst.move_to(true) end,
    { nowait = true },
})

-- Uniform Navigation
local uniform_navigation = {
    ["<A-j>"] = { destination = "next" },
    ["<A-k>"] = { destination = "previous" },
}

for keymap, args in pairs(uniform_navigation) do
    local hydra_mapping = {
        keymap,
        function() utils.execute_with_count(uniform.move, args) end,
        { nowait = true },
    }
    table.insert(heads, hydra_mapping)
end

-------------------------------------------- Paste

local paste_map = {
    ["pa"] = { destination = "next" },
    ["pA"] = { destination = "previous" },
    ["pi"] = { destination = "inside", paste_inside_destination = "after-all-children" },
    ["pI"] = { destination = "inside", paste_inside_destination = "before-all-children" },
}

local paste_fn = require("deliberate.api.paste").call

for keymap, args in pairs(paste_map) do
    local hydra_mapping

    if args.destination == "inside" then
        hydra_mapping = {
            keymap,
            function()
                paste_fn(args)
                utils.reset_count()
            end,
            { nowait = true },
        }
    else
        hydra_mapping = {
            keymap,
            function() utils.execute_with_count(paste_fn, args) end,
            { nowait = true },
        }
    end

    table.insert(heads, hydra_mapping)
end

-------------------------------------------- Hydra

Hydra({
    name = "Deliberate",
    config = {
        hint = false,
        color = "pink",
        invoke_on_body = true,
        on_enter = function()
            require("deliberate.lib.selection.extmark_archive").clear_all()

            catalyst.initiate({
                win = vim.api.nvim_get_current_win(),
                buf = vim.api.nvim_get_current_buf(),
            })
        end,
        on_exit = function() selection.wipe() end,
    },
    mode = "n",
    body = "<Plug>DeliberateHydraEsc",
    heads = heads,
})

return {
    exit_hydra = exit_hydra,
}

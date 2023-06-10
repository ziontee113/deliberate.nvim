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

local augroup = vim.api.nvim_create_augroup("Deliberate Hydra Exit", { clear = true })
local autocmd_id

local exit_hydra = function()
    vim.api.nvim_input("<Nul>")
    visual_collector.stop()
    selection.clear(true)
    pcall(vim.api.nvim_del_autocmd, autocmd_id)
end

local heads = {
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
        "T",
        function() require("deliberate.ui.content_replacer_menu").replace("contents.txt") end,
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
        "pa",
        function() require("deliberate.api.paste").call({ destination = "next" }) end,
        { nowait = true },
    },
    {
        "pA",
        function() require("deliberate.api.paste").call({ destination = "previous" }) end,
        { nowait = true },
    },

    {
        "v",
        function() visual_collector.toggle() end,
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
        "dc",
        function() colors_menu.divide() end,
        { nowait = true },
    },
    {
        "Rc",
        function() colors_menu.ring() end,
        { nowait = true },
    },
    {
        "RC",
        function() colors_menu.ring_offset() end,
        { nowait = true },
    },

    {
        "`",
        function() require("deliberate.ui.pseudo_classes_input").show() end,
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
    { "<Nul>", nil, { exit = true } },
}

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
}
add_heads_from_tbl(keymap_to_color_menu_fn)

-------------------------------------------- Tailwind Classes that can have Arbitrary Values

-- Non Axis
local non_axis_map = {
    ["fz"] = pms_menu.change_font_size,
    ["ff"] = pms_menu.change_font_family,
    ["fc"] = pms_menu.change_line_clamp,
    ["fT"] = pms_menu.change_tracking,
    ["fL"] = pms_menu.change_leading,
    ["<space>dt"] = pms_menu.change_td_thickness,
    ["<space>uo"] = pms_menu.change_underline_offset,

    ["<space>li"] = pms_menu.change_list_image,

    ["O"] = pms_menu.change_opacity,
    ["bo"] = pms_menu.change_border_opacity,
    ["do"] = pms_menu.change_divide_opacity,
    ["Rw"] = pms_menu.change_ring_width,
    ["Ro"] = pms_menu.change_ring_offset,
    ["RO"] = pms_menu.change_ring_opacity,

    ["W"] = pms_menu.change_width,
    ["E"] = pms_menu.change_height,
    ["mW"] = pms_menu.change_min_width,
    ["mE"] = pms_menu.change_min_height,
    ["xW"] = pms_menu.change_max_width,
    ["xE"] = pms_menu.change_max_height,

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
    ["<A-a>"] = { cgm.change_text_align },
    ["<A-d>"] = { cgm.change_text_decoration },
    ["<A-t>"] = { cgm.change_text_transform },
    ["<space>ds"] = { cgm.change_decoration_style },
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
    ["C"] = { cgm.change_container },

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
    ["V"] = { cgm.change_visibility },

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

-------------------------------------------- Hydra

Hydra({
    name = "Deliberate",
    config = {
        hint = false,
        color = "pink",
        invoke_on_body = true,
        on_enter = function()
            catalyst.initiate({
                win = vim.api.nvim_get_current_win(),
                buf = vim.api.nvim_get_current_buf(),
            })

            autocmd_id = vim.api.nvim_create_autocmd({ "BufWritePost" }, {
                buffer = vim.api.nvim_get_current_buf(),
                group = augroup,
                callback = function() exit_hydra() end,
            })
        end,
        on_exit = function() selection.clear() end,
    },
    mode = "n",
    body = "<Plug>DeliberateHydraEsc",
    heads = heads,
})

return {
    exit_hydra = exit_hydra,
}

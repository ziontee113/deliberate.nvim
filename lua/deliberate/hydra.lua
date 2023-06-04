local Hydra = require("hydra")
local catalyst = require("deliberate.lib.catalyst")
local visual_collector = require("deliberate.api.visual_collector")
local selection = require("deliberate.lib.selection")
local navigator = require("deliberate.api.navigator")
local pms_menu = require("deliberate.ui.pms_menu")
local colors_menu = require("deliberate.ui.colors_menu")
local classes_groups_menu = require("deliberate.ui.classes_groups_menu")
local html_tags = require("deliberate.api.html_tag")
local uniform = require("deliberate.api.uniform")
local utils = require("deliberate.lib.utils")

local augroup = vim.api.nvim_create_augroup("Deliberate Hydra Exit", { clear = true })
local autocmd_id

local exit_hydra = function()
    vim.api.nvim_input("<Plug>DeliberateExitHydra")

    visual_collector.stop()
    selection.clear(true)

    vim.api.nvim_del_autocmd(autocmd_id)
end

local heads = {
    {
        "y",
        function() require("deliberate.api.yank").call() end,
        { nowait = true },
    },
    {
        "pa",
        function() require("deliberate.api.paste")({ destination = "next" }) end,
        { nowait = true },
    },
    {
        "pA",
        function() require("deliberate.api.paste")({ destination = "previous" }) end,
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
        "u",
        function() require("deliberate.api.undo").call() end,
        { nowait = true },
    },
    {
        "d",
        function() require("deliberate.api.delete").call() end,
        { nowait = true },
    },

    {
        "t",
        function() colors_menu.change_text_color() end,
        { nowait = true },
    },
    {
        "b",
        function() colors_menu.change_background_color() end,
        { nowait = true },
    },

    {
        "`",
        function() require("deliberate.ui.pseudo_classes_input").show() end,
        { nowait = true },
    },

    {
        "<Esc>",
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
    { "<Plug>DeliberateExitHydra", nil, { exit = true } },
}

-------------------------------------------- Padding / Margin / Spacing heads

local properties = {
    p = { "", "x", "y", "t", "b", "l", "r" },
    m = { "", "x", "y", "t", "b", "l", "r" },
    s = { "x", "y" },
}

for property, axies in pairs(properties) do
    for _, axis in ipairs(axies) do
        local keymap = property .. axis
        if axis == "" then keymap = string.upper(property) end

        local hydra_mapping = {
            keymap,
            function()
                if property == "p" then
                    pms_menu.change_padding({ axis = axis })
                elseif property == "m" then
                    pms_menu.change_margin({ axis = axis })
                elseif property == "s" then
                    pms_menu.change_spacing({ axis = axis })
                end
            end,
            { nowait = true },
        }
        table.insert(heads, hydra_mapping)
    end
end

-------------------------------------------- Replace Classes Groups

local classes_groups_dict = {
    ["fl"] = classes_groups_menu.change_flex_properties,
    ["a"] = classes_groups_menu.change_flex_align_properties,

    ["z"] = classes_groups_menu.change_font_size,
    ["fs"] = classes_groups_menu.change_font_style,
    ["fw"] = classes_groups_menu.change_font_weight,
    ["<A-a>"] = classes_groups_menu.change_text_align,
    ["<A-d>"] = classes_groups_menu.change_text_decoration,

    ["O"] = classes_groups_menu.change_opacity,
}

for keymap, fn in pairs(classes_groups_dict) do
    local hydra_mapping = {
        keymap,
        function() fn() end,
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

-------------------------------------------- Add Tags

local tags_dict = {
    ["D"] = { tag = "div", destination = "next", content = "" },
    ["U"] = { tag = "ul", destination = "next", content = "" },
}
for keymap, args in pairs(tags_dict) do
    local hydra_mapping = {
        keymap,
        function() utils.execute_with_count(html_tags.add, args) end,
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
    body = "<Esc>",
    heads = heads,
})

return {
    exit_hydra = exit_hydra,
}

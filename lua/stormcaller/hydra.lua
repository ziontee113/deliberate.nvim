local Hydra = require("hydra")
local catalyst = require("stormcaller.lib.catalyst")
local visual_collector = require("stormcaller.api.visual_collector")
local selection = require("stormcaller.lib.selection")
local navigator = require("stormcaller.api.navigator")
local pms_menu = require("stormcaller.ui.pms_menu")
local tag = require("stormcaller.api.html_tag")
local uniform = require("stormcaller.api.uniform")

local exit_hydra = function() vim.api.nvim_input("<Plug>DeliberateExitHydra") end

local heads = {
    {
        "j",
        function() navigator.move({ destination = "next" }) end,
        { nowait = true, desc = "Navigator Move Down" },
    },
    {
        "k",
        function() navigator.move({ destination = "previous" }) end,
        { nowait = true, desc = "Navigator Move Up" },
    },

    {
        "<A-j>",
        function() uniform.move({ destination = "next" }) end,
        { nowait = true },
    },
    {
        "<A-k>",
        function() uniform.move({ destination = "previous" }) end,
        { nowait = true },
    },

    {
        "<Tab>",
        function() navigator.move({ destination = "next", select_move = true }) end,
        { nowait = true },
    },
    {
        "<S-Tab>",
        function() navigator.move({ destination = "previous", select_move = true }) end,
        { nowait = true },
    },
    {
        "<A-Tab>",
        function() catalyst.move_to(true) end,
        { nowait = true },
    },

    {
        "v",
        function() visual_collector.toggle() end,
        { nowait = true },
    },

    {
        "D",
        function() tag.add({ tag = "div", destination = "next", content = "" }) end,
        { nowait = true },
    },
    {
        "U",
        function() tag.add({ tag = "ul", destination = "next", content = "" }) end,
        { nowait = true },
    },

    {
        "u",
        function() require("stormcaller.api.undo").call() end,
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

--------------------------------------------

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

--------------------------------------------

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

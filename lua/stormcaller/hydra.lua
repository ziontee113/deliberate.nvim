local Hydra = require("hydra")
local catalyst = require("stormcaller.lib.catalyst")
local visual_collector = require("stormcaller.api.visual_collector")
local selection = require("stormcaller.lib.selection")
local navigator = require("stormcaller.api.navigator")

local exit_hydra = function() vim.api.nvim_input("<Plug>DeliberateExitHydra") end

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
    heads = {
        {
            "j",
            function() navigator.move({ destination = "next" }) end,
            { nowait = true },
        },
        {
            "k",
            function() navigator.move({ destination = "previous" }) end,
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
    },
})

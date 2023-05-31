local Hydra = require("hydra")
local catalyst = require("stormcaller.lib.catalyst")
local visual_mode = require("stormcaller.api.visual_mode")
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
            function() visual_mode.toogle() end,
            { nowait = true },
        },

        {
            "<Esc>",
            function()
                if not selection.select_move_is_active() and not visual_mode.is_active() then
                    exit_hydra()
                end
                if selection.select_move_is_active() then selection.clear(true) end
                if visual_mode.is_active() then visual_mode.off() end
            end,
            { nowait = true },
        },

        -- workaround to programmatically exit Hydra
        { "<Plug>DeliberateExitHydra", nil, { exit = true } },
    },
})
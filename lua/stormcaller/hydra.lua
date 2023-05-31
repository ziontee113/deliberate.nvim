local Hydra = require("hydra")
local catalyst = require("stormcaller.lib.catalyst")
local selection = require("stormcaller.lib.selection")
local navigator = require("stormcaller.api.navigator")

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

        { "<Esc>", nil, { exit = true, nowait = true } },
    },
})

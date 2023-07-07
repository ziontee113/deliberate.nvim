local PopUp = require("deliberate.lib.ui.PopUp")
local Input = require("deliberate.lib.ui.Input")
local tag_changer = require("deliberate.api.tag_name_changer")
local menu_repeater = require("deliberate.api.menu_repeater")

local M = {}

local items = {
    { keymaps = { "d" }, text = "div" },
    { keymaps = { "u" }, text = "ul" },
    "",
    { keymaps = { "1" }, text = "h1" },
    { keymaps = { "2" }, text = "h2" },
    { keymaps = { "3" }, text = "h3" },
    { keymaps = { "4" }, text = "h4" },
    { keymaps = { "5" }, text = "h5" },
    { keymaps = { "6" }, text = "h6" },
    { keymaps = { "p" }, text = "p" },
    "",
    { keymaps = { "l" }, text = "li" },
    { keymaps = { "s" }, text = "span" },
    "",
    { keymaps = { "b" }, text = "button" },
    { keymaps = { "i" }, text = "img" },

    { keymaps = ",", text = "", hidden = true, arbitrary = true },
}

local show_arbitrary_input = function(metadata)
    local input = Input:new({
        title = "Change Tag Name",
        width = 15,
        callback = function(result) tag_changer.change_to(result) end,
    })

    local row, col = unpack(vim.api.nvim_win_get_position(0))
    input:show(metadata, row, col)
end

M._change_tag_menu = function()
    menu_repeater.register(M._change_tag_menu)

    local popup = PopUp:new({
        title = string.format("Change Tag"),
        steps = {
            {
                items = items,
                callback = function(_, item, metadata)
                    if item.arbitrary then
                        show_arbitrary_input(metadata)
                    else
                        tag_changer.change_to(item.text)
                    end
                end,
            },
        },
    })

    popup:show()
end

return M

local PopUp = require("deliberate.lib.ui.PopUp")
local Input = require("deliberate.lib.ui.Input")
local catalyst = require("deliberate.lib.catalyst")
local selection = require("deliberate.lib.selection")
local html_tag = require("deliberate.api.html_tag")
local utils = require("deliberate.lib.utils")
local menu_repeater = require("deliberate.api.menu_repeater")
local M = {}

local tag_map = {
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
    { keymaps = { "S" }, text = "section" },
    "",
    { keymaps = { "b" }, text = "button" },
    { keymaps = { "i" }, text = "img", self_closing = true },
    "",
    { keymaps = { ";r" }, text = "DropdownMenu.Root" },
    { keymaps = { ";p" }, text = "DropdownMenu.Portal" },
    { keymaps = { ";c" }, text = "DropdownMenu.Content" },
    { keymaps = { ";g" }, text = "DropdownMenu.RadioGroup" },
    { keymaps = { ";r" }, text = "DropdownMenu.RadioItem" },
    { keymaps = { ";i" }, text = "DropdownMenu.Item" },

    { keymaps = ",", text = "", hidden = true, self_closing = true, arbitrary = true },
    { keymaps = ".", text = "", hidden = true, self_closing = false, arbitrary = true },
    { keymaps = "<", text = "", hidden = true, self_closing = true, arbitrary = true },
    { keymaps = ">", text = "", hidden = true, self_closing = false, arbitrary = true },
}

M._add_tag_with_count = function(tag, destination, self_closing, count)
    vim.bo[catalyst.buf()].undolevels = vim.bo[catalyst.buf()].undolevels
    selection.archive_for_undo()
    require("deliberate.api.dot_repeater").register(
        M._add_tag_with_count,
        tag,
        destination,
        self_closing,
        count
    )

    for i = 1, count do
        if destination == "inside" and i > 1 then destination = "next" end

        html_tag.add({
            destination = destination,
            tag = tag,
            content = "",
            self_closing = self_closing,
        })
    end
end

local show_remove_arbitrary_input = function(metadata, destination, count, self_closing)
    local input = Input:new({
        title = string.format("Add tag: %s", destination),
        width = 15,
        callback = function(result)
            M._add_tag_with_count(result, destination, self_closing or false, count)
        end,
    })
    local row, col = unpack(vim.api.nvim_win_get_position(0))
    input:show(metadata, row, col)
end

M._add_tag_menu = function(destination)
    menu_repeater.register(M._add_tag_menu, destination)

    local count = utils.get_count()

    local popup = PopUp:new({
        title = string.format(" %s ", destination),
        steps = {
            {
                items = tag_map,
                callback = function(_, item, metadata)
                    if item.arbitrary then
                        show_remove_arbitrary_input(metadata, destination, count, item.self_closing)
                    else
                        M._add_tag_with_count(
                            item.text,
                            destination,
                            item.self_closing or false,
                            count
                        )
                    end
                end,
            },
        },
    })

    popup:show()
end

M.add_tag_next = function() M._add_tag_menu("next") end
M.add_tag_previous = function() M._add_tag_menu("previous") end
M.add_tag_inside = function() M._add_tag_menu("inside") end

return M

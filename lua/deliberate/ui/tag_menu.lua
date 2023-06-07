local PopUp = require("deliberate.lib.ui.PopUp")
local html_tag = require("deliberate.api.html_tag")
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
    "",
    { keymaps = { "l" }, text = "li" },
    { keymaps = { "s" }, text = "span" },
    "",
    { keymaps = { "b" }, text = "button" },
}

local add_tag_menu = function(destination)
    local popup = PopUp:new({
        title = string.format(" %s ", destination),
        steps = {
            {
                items = tag_map,
                callback = function(_, current_item)
                    html_tag.add({
                        destination = destination,
                        tag = current_item.text,
                        content = "",
                    })
                end,
            },
        },
    })

    popup:show()
end

M.add_tag_next = function() add_tag_menu("next") end
M.add_tag_previous = function() add_tag_menu("previous") end
M.add_tag_inside = function() add_tag_menu("inside") end

return M

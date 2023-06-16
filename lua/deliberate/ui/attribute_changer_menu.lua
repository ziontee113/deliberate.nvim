local PopUp = require("deliberate.lib.ui.PopUp")
local Input = require("deliberate.lib.ui.Input")
local attr_changer = require("deliberate.lib.attribute_changer")
local menu_repeater = require("deliberate.api.menu_repeater")

local M = {}

local items = {
    { keymaps = { "a" }, text = "alt" },
    { keymaps = { "s" }, text = "src" },
    { keymaps = { "c" }, text = "onClick" },

    { keymaps = "0", text = "", hidden = true },
    { keymaps = ",", text = "", hidden = true, arbitrary = true },
}

local show_arbitrary_input = function(metadata)
    local input = Input:new({
        title = "Attribute",
        width = 15,
        callback = function(result) attr_changer.change({ attribute = result, content = "{}" }) end,
        defer_fn = function(result)
            attr_changer.jump_to_attribute_value_node(result)
            vim.cmd("startinsert")
        end,
    })

    local row, col = unpack(vim.api.nvim_win_get_position(0))
    input:show(metadata, row, col)
end

M.show = function()
    menu_repeater.register(M.show)

    local popup = PopUp:new({
        steps = {
            {
                items = items,
                callback = function(_, current_item, metadata)
                    if current_item.arbitrary == true then
                        show_arbitrary_input(metadata)
                    else
                        attr_changer.change({ attribute = current_item.text, content = "{}" })
                    end
                end,
            },
        },
        defer_fn = function(results)
            if results[1] ~= "" then
                attr_changer.jump_to_attribute_value_node(results[1])
                vim.cmd("startinsert")
            end
        end,
    })

    popup:show()
end

return M

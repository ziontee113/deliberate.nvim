local PopUp = require("deliberate.lib.ui.PopUp")
local Input = require("deliberate.lib.ui.Input")
local attr_changer = require("deliberate.lib.attribute_changer")
local dot_repeater = require("deliberate.api.dot_repeater")
local menu_repeater = require("deliberate.api.menu_repeater")

local M = {}
local latest_arbitrary_input_value

local content = "{  }"
local col_offset = -1

local items = {
    { keymaps = { "a" }, text = "alt" },
    { keymaps = { "s" }, text = "src" },
    { keymaps = { "c" }, text = "onClick", exit_hydra = true },

    { keymaps = "0", text = "", hidden = true },
    { keymaps = ",", text = "", hidden = true, arbitrary = true },
}

local show_arbitrary_input = function(metadata)
    local input = Input:new({
        title = "Attribute",
        width = 15,
        callback = function(result) attr_changer.change({ attribute = result, content = content }) end,
        defer_fn = function(result)
            latest_arbitrary_input_value = result
            attr_changer.jump_to_attribute_value_node(result)
            vim.cmd("startinsert")
        end,
    })

    local row, col = unpack(vim.api.nvim_win_get_position(0))
    input:show(metadata, row, col)
end

local defer_fn = function(current_item, dot_repeat)
    local attribute = dot_repeat and latest_arbitrary_input_value or current_item.text
    if current_item.text ~= "" or dot_repeat then
        attr_changer.jump_to_attribute_value_node(attribute, col_offset)
        vim.cmd("startinsert")
    end
end

local handle_result = function(current_item, metadata, dot_repeat)
    if current_item.exit_hydra then require("deliberate.hydra").exit_hydra() end

    vim.schedule(function()
        if current_item.arbitrary == true then
            if dot_repeat then
                attr_changer.change({ attribute = latest_arbitrary_input_value, content = content })
            else
                show_arbitrary_input(metadata)
            end
        else
            attr_changer.change({ attribute = current_item.text, content = content })
        end

        defer_fn(current_item, dot_repeat)
    end)
end

M.show = function()
    menu_repeater.register(M.show)

    local popup = PopUp:new({
        steps = {
            {
                items = items,
                callback = function(_, current_item, metadata)
                    dot_repeater.register(handle_result, current_item, metadata, true)
                    handle_result(current_item, metadata)
                end,
            },
        },
        defer_fn = function(results) defer_fn(results[1]) end,
    })

    popup:show()
end

return M

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
    { keymaps = { "s" }, text = "src" },
    { keymaps = { "A" }, text = "alt" },
    "",
    { keymaps = { "c" }, text = "onClick", exit_hydra = true },
    "",
    { keymaps = { "C" }, text = "className", exit_hydra = true },
    "",
    { keymaps = { "i" }, text = "initial", content = "{{  }}", col_offset = -2, exit_hydra = true },
    {
        keymaps = { "a" },
        text = "animate",
        content = "{{  }}",
        col_offset = -2,
        exit_hydra = true,
    },

    { keymaps = ",", text = "", hidden = true, arbitrary = true },
}

local show_arbitrary_input = function(metadata)
    local input = Input:new({
        title = "Attribute",
        width = 15,
        callback = function(result) attr_changer.change({ attribute = result, content = content }) end,
        defer_fn = function(result)
            latest_arbitrary_input_value = result
            attr_changer.jump_to_attribute_value_node(result, col_offset)
            vim.cmd("startinsert")
        end,
    })

    local row, col = unpack(vim.api.nvim_win_get_position(0))
    input:show(metadata, row, col, true)
end

local defer_fn = function(current_item, dot_repeat)
    local attribute = dot_repeat and latest_arbitrary_input_value or current_item.text
    if current_item.text ~= "" or dot_repeat then
        attr_changer.jump_to_attribute_value_node(attribute, current_item.col_offset or col_offset)
        vim.cmd("startinsert")
    end
end

local handle_result = function(current_item, metadata, dot_repeat)
    if current_item.exit_hydra then require("deliberate.hydra").exit_hydra() end

    vim.schedule(function()
        if current_item.arbitrary == true then
            if dot_repeat then
                attr_changer.change({
                    attribute = latest_arbitrary_input_value,
                    content = current_item.content or content,
                })
            else
                show_arbitrary_input(metadata)
            end
        else
            attr_changer.change({
                attribute = current_item.text,
                content = current_item.content or content,
                col_offset = current_item.col_offset or col_offset,
            })
        end

        defer_fn(current_item, dot_repeat)
    end)
end

M.show = function()
    menu_repeater.register(M.show)

    local popup = PopUp:new({
        title = "Change Attribute",
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

-- Remove

local show_remove_arbitrary_input = function(metadata)
    local input = Input:new({
        title = "Remove Attribute",
        width = 15,
        callback = function(result) attr_changer.remove(result) end,
    })
    local row, col = unpack(vim.api.nvim_win_get_position(0))
    input:show(metadata, row, col)
end
M.remove = function()
    menu_repeater.register(M.remove)
    local popup = PopUp:new({
        title = "Remove Attribute",
        steps = {
            {
                items = items,
                callback = function(_, current_item, metadata)
                    if current_item.arbitrary then
                        show_remove_arbitrary_input(metadata)
                    else
                        attr_changer.remove(current_item.text)
                    end
                end,
            },
        },
    })
    popup:show()
end

return M

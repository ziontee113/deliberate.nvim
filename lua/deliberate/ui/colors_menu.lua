local PopUp = require("deliberate.lib.ui.PopUp")
local Input = require("deliberate.lib.ui.Input")
local tcm = require("deliberate.api.tailwind_class_modifier")
local transformer = require("deliberate.lib.arbitrary_transformer")
local menu_repeater = require("deliberate.api.menu_repeater")

local M = {}

local colors = {
    { text = "", keymaps = { "0" }, hidden = true },
    { text = "slate", keymaps = { "sl" } },
    { text = "gray", keymaps = { "G" } },
    { text = "zinc", keymaps = { "z" } },
    { text = "neutral", keymaps = { "n" } },
    { text = "stone", keymaps = { "st" } },
    { text = "red", keymaps = { "r" } },
    { text = "orange", keymaps = { "o" } },
    { text = "amber", keymaps = { "a" } },
    { text = "yellow", keymaps = { "y" } },
    { text = "lime", keymaps = { "l" } },
    { text = "green", keymaps = { "g" } },
    { text = "emerald", keymaps = { "e" } },
    { text = "teal", keymaps = { "t" } },
    { text = "cyan", keymaps = { "c" } },
    { text = "sky", keymaps = { "sk" } },
    { text = "blue", keymaps = { "b" } },
    { text = "indigo", keymaps = { "i" } },
    { text = "violet", keymaps = { "v" } },
    { text = "purple", keymaps = { "p" } },
    { text = "fuchsia", keymaps = { "f" } },
    { text = "pink", keymaps = { "P" } },
    { text = "rose", keymaps = { "R" } },
    "",
    { text = "white", keymaps = { "w" }, single = true },
    { text = "black", keymaps = { "B" }, single = true },
    "",
    { text = "inherit", keymaps = { "I" }, single = true },
    { text = "current", keymaps = { "C" }, single = true },
    { text = "transparent", keymaps = { "T" }, single = true },

    { text = "", keymaps = { "," }, arbitrary = true, hidden = true },
}

local steps = {
    { text = "100", keymaps = { "m", "1", "q" } },
    { text = "200", keymaps = { ",", "2", "w" } },
    { text = "300", keymaps = { ".", "3", "e" } },
    { text = "400", keymaps = { "j", "4", "r" } },
    { text = "500", keymaps = { "k", "5", "a" } },
    { text = "600", keymaps = { "l", "6", "s" } },
    { text = "700", keymaps = { "u", "7", "d" } },
    { text = "800", keymaps = { "i", "8", "f" } },
    { text = "900", keymaps = { "o", "9", "g" } },
}

local show_arbitrary_input = function(metadata, prefix, fn, property)
    local input = Input:new({
        title = "Input Color",
        width = 15,
        on_change = function(result)
            local value = transformer.input_to_color(result)
            value = string.format("%s-[%s]", prefix, value)
            fn({ value = value, property = property })
        end,
    })

    local row, col = unpack(vim.api.nvim_win_get_position(0))
    input:show(metadata, row, col)
end

M._menu = function(filetype, prefix, fn, property)
    menu_repeater.register(M._menu, filetype, prefix, fn, property)

    local popup = PopUp:new({
        filetype = filetype,
        steps = {
            {
                items = colors,
                format_fn = function(_, current_item)
                    return string.format("%s-%s", prefix, current_item.text)
                end,
                callback = function(_, current_item, metadata)
                    if current_item.arbitrary == true then
                        show_arbitrary_input(metadata, prefix, fn, property)
                        return true
                    end
                    if current_item.text == "" then
                        fn({ value = "", property = property })
                        return true
                    end
                    if current_item.single then
                        local value = string.format("%s-%s", prefix, current_item.text)
                        fn({ value = value, property = property })
                        return true
                    end
                end,
            },
            {
                items = steps,
                format_fn = function(results, current_item)
                    return string.format("%s-%s-%s", prefix, results[1], current_item.text)
                end,
                callback = function(results)
                    local value = string.format("%s-%s-%s", prefix, results[1], results[2])
                    fn({ value = value, property = property })
                end,
            },
        },
    })

    popup:show()
end

-------------------------------------------- Public Methods

local txt_ft = "tailwind-text-color-picker"
local bg_ft = "tailwind-bg-color-picker"
local fn = tcm._change

M.text = function() M._menu(txt_ft, "text", tcm.change_text_color) end
M.background = function() M._menu(bg_ft, "bg", tcm.change_background_color) end
M.border = function() M._menu(bg_ft, "border", fn, "border-color") end
M.divide = function() M._menu(bg_ft, "divide", fn, "divide-color") end
M.ring = function() M._menu(bg_ft, "ring", fn, "ring-color") end
M.ring_offset = function() M._menu(bg_ft, "ring-offset", fn, "ring-offset-color") end
M.from = function() M._menu(bg_ft, "from", fn, "from-color") end
M.via = function() M._menu(bg_ft, "via", fn, "via-color") end
M.to = function() M._menu(bg_ft, "to", fn, "to-color") end
M.decoration = function() M._menu(bg_ft, "decoration", fn, "text-decoration-color") end
M.shadow = function() M._menu(bg_ft, "shadow", fn, "shadow-color") end
M.accent = function() M._menu(bg_ft, "accent", fn, "accent-color") end
M.caret = function() M._menu(bg_ft, "caret", fn, "caret-color") end
M.fill = function() M._menu(bg_ft, "fill", fn, "fill-color") end
M.stroke = function() M._menu(bg_ft, "stroke", fn, "stroke-color") end

return M

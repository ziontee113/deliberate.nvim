local menu_repeater = require("deliberate.api.menu_repeater")
local M = {}

local show_input_window = function(buf, width, height, title, winhl)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "cursor",
        row = 1,
        col = 1,
        width = width,
        height = height,
        style = "minimal",
        border = "single",
        title = title or "",
        title_pos = "center",
    })

    vim.api.nvim_win_set_option(win, "winhl", winhl or "Normal:Normal,FloatBorder:@function")

    return win
end

local text_change_callback = function(line)
    local content = require("deliberate.lib.pseudo_classes.mixer").translate_alias_string(line)
    require("deliberate.lib.pseudo_classes.manager").update(content)
    require("deliberate.lib.indicator").highlight_pseudo_classes()
end

local stop_insert_and_close_window = function(win)
    vim.cmd("stopinsert")
    vim.api.nvim_win_close(win, true)

    -- NOTE: why the heck do I have to do this? `nvim_win_close` just move the cursor for no good reasons.
    vim.defer_fn(function() vim.cmd("norm! ^") end, 50)
end

local set_close_keymaps = function(win, buf, keymaps_tbl)
    for _, keymap in ipairs(keymaps_tbl) do
        vim.keymap.set(
            { "n", "i" },
            keymap,
            function() stop_insert_and_close_window(win) end,
            { buffer = buf }
        )
    end
end

local augroup =
    vim.api.nvim_create_augroup("Deliberate Pseudo Classes Input Augroup", { clear = true })
M.show = function()
    menu_repeater.register(M.show)

    local buf = vim.api.nvim_create_buf(false, true)
    local win = show_input_window(buf, 20, 1, "Pseudo Classes")

    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        buffer = buf,
        group = augroup,
        callback = function()
            local line = vim.api.nvim_buf_get_lines(buf, 0, -1, false)[1]
            text_change_callback(line)
        end,
    })

    vim.cmd("startinsert")

    set_close_keymaps(win, buf, { "<Esc>", "<CR>", "`", "~", ">" })

    return buf, win
end

return M

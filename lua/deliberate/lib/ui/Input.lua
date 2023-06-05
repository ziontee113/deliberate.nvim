local Input = {}
Input.__index = Input

-- Private

function Input:_execute_callback()
    vim.cmd("stopinsert")

    local result = vim.api.nvim_buf_get_lines(0, 0, -1, false)[1]
    self.callback(result)
    self:hide()

    vim.api.nvim_set_current_win(self.target_win)
end

function Input:_set_hide_keymaps()
    if not self.keymaps.hide then self.keymaps.hide = { "<Esc>", "q" } end

    for _, mapping in ipairs(self.keymaps.hide) do
        vim.keymap.set(
            "n",
            mapping,
            function() vim.api.nvim_win_close(self.win, true) end,
            { buffer = self.buf, nowait = true }
        )
    end
end

function Input:_set_confirm_keymaps()
    vim.keymap.set(
        { "n", "i" },
        "<CR>",
        function() self:_execute_callback() end,
        { buffer = self.buf, nowait = true }
    )
end

-- Public

function Input:show(metadata, row, col)
    metadata = metadata or {}

    vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, {})

    self.target_win = metadata.target_win or vim.api.nvim_get_current_win()
    self.target_buf = vim.api.nvim_get_current_buf()

    self.win = vim.api.nvim_open_win(self.buf, true, {
        relative = "editor",
        row = row or 1,
        col = col or 1,
        width = self.width or 20,
        height = self.height or 1,
        style = "minimal",
        border = "single",
        title = self.title or "",
        title_pos = self.title_pos or "center",
    })

    vim.api.nvim_win_set_option(
        self.win,
        "winhl",
        self.winhl or "Normal:Normal,FloatBorder:@function"
    )
    vim.api.nvim_win_set_option(self.win, "cursorline", true)

    self:_set_hide_keymaps()

    vim.cmd("startinsert")
end

function Input:hide()
    vim.api.nvim_win_hide(self.win)
    pcall(vim.api.nvim_buf_del, self.buf)
end

function Input:new(opts)
    local input = setmetatable(opts or {}, Input)

    input.buf = vim.api.nvim_create_buf(false, true)
    input.keymaps = input.keymaps or {}

    input:_set_confirm_keymaps()

    return input
end

return Input
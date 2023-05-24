local ns = vim.api.nvim_create_namespace("namespace_name")
vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

vim.keymap.set("n", "<leader>a", function()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    vim.api.nvim_buf_set_extmark(0, ns, row - 1, col + 1, {
        virt_text = { { "V", "Normal" } },
        virt_text_pos = "eol",
    })
end, {})

vim.keymap.set("n", "<leader>l", function()
    local all_extmarks = vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {})
    N(all_extmarks)

    local row = unpack(vim.api.nvim_win_get_cursor(0))
    vim.api.nvim_buf_set_lines(0, row, row, false, { "-- this is a comment" })

    all_extmarks = vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {})
    N(all_extmarks)
end, {})

-- {{{nvim-execute-on-save}}}

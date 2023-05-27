-- This config file is for both local testing and CI workflow.

vim.o.swapfile = false
vim.bo.swapfile = false

vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 0
vim.o.smarttab = true
vim.o.expandtab = true

local augroup = vim.api.nvim_create_augroup("filetype specific tabstop", { clear = true })
vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = "svelte",
    group = augroup,
    callback = function()
        vim.o.tabstop = 4
        vim.o.shiftwidth = 4
    end,
})

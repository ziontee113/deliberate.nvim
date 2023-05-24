-- Dependencies for local testing (using Lazy.nvim)
vim.opt.rtp:append("~/.local/share/nvim/lazy/plenary.nvim")
require("plenary.busted")

vim.opt.rtp:append("~/.local/share/nvim/lazy/nvim-treesitter")
require("nvim-treesitter")

-- Setup Editor Options
vim.opt.rtp:append(".")

-- Disable Swapfile
vim.o.swapfile = false
vim.bo.swapfile = false

vim.o.tabstop = 2
vim.o.softtabstop = 0
vim.o.shiftwidth = 2
vim.o.smarttab = true
vim.o.expandtab = true

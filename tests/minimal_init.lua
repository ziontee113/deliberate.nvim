-- Dependencies for local testing (using Lazy.nvim)
vim.opt.rtp:append("~/.local/share/nvim/lazy/plenary.nvim")
require("plenary.busted")

vim.opt.rtp:append("~/.local/share/nvim/lazy/nvim-treesitter")
require("nvim-treesitter")

-- Setup Editor Options
vim.opt.rtp:append(".")

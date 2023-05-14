-- Setup Plenary
local plenary_dir = "/tmp/plenary.nvim"
local is_not_a_directory = vim.fn.isdirectory(plenary_dir) == 0
if is_not_a_directory then
    vim.fn.system({ "git", "clone", "https://github.com/nvim-lua/plenary.nvim", plenary_dir })
end

vim.opt.rtp:append(plenary_dir)

vim.cmd("runtime plugin/plenary.vim")
require("plenary.busted")

-- Setup nvim-treesitter
local ts_dir = "/tmp/nvim-treesitter"
local ts_dir_is_not_a_directory = vim.fn.isdirectory(ts_dir) == 0
if ts_dir_is_not_a_directory then
    vim.fn.system({
        "git",
        "clone",
        "https://github.com/nvim-treesitter/nvim-treesitter/",
        ts_dir,
    })
end

vim.opt.rtp:append(ts_dir)
require("nvim-treesitter.configs").setup({
    ensure_installed = { "tsx" },
    sync_install = false,
    auto_install = true,
    highlight = { enable = false },
})

vim.cmd("TSInstall all")

-- Setup Editor Options
vim.opt.rtp:append(".")

vim.o.splitright = true

vim.o.tabstop = 4
vim.o.softtabstop = 0
vim.o.shiftwidth = 2
vim.o.smarttab = true
vim.o.expandtab = true

vim.o.swapfile = false
vim.bo.swapfile = false

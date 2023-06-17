# Deliberate.nvim

### Deliberate.nvim is a sub-mode for Neovim to manipulate HTML syntax & Tailwind CSS Classes.

## 📣 Important Notice: ⚠️

This plugin is still in development and not yet stable. I apologize for any inconvenience caused.
<br/>
Additionally, documentation is currently unavailable. I appreciate your patience as I work on improving stability and providing comprehensive documentation.
<br/>
Your feedback is valuable for the development of the project. Thank you for your support.

## Usage:

You can watch the full demo of the plugin here: [Alternative way to manipulate HTML + Tailwind CSS in Neovim. Handy or impractical?](https://youtu.be/eWRoxJatH8A)

## Installation: 💾

For Lazy:

```lua
return {
    "ziontee113/deliberate.nvim",
    dependencies = {
        {
            "anuvyklack/hydra.nvim",
        },
    },
    config = function()
        local supported_filetypes = { "typescriptreact", "svelte" }
        local augroup = vim.api.nvim_create_augroup("DeliberateEntryPoint", { clear = true })
        vim.api.nvim_create_autocmd({ "FileType" }, {
            pattern = supported_filetypes,
            group = augroup,
            callback = function()
                local bufnr = vim.api.nvim_get_current_buf()
                if vim.tbl_contains(supported_filetypes, vim.bo.ft) then
                    vim.keymap.set("n", "<Esc>", function()
                        vim.api.nvim_input("<Plug>DeliberateHydraEsc")
                    end, { buffer = bufnr })
                    vim.keymap.set("i", "<Plug>DeliberateHydraEsc", "<Nop>", {})
                end
            end,
        })

        require("deliberate.hydra")
    end,
}
```

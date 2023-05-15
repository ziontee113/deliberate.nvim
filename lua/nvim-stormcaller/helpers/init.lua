local M = {}

M.set_buf_content = function(content)
    if type(content) == "string" then content = vim.split(content, "\n") end
    vim.api.nvim_buf_set_lines(0, 0, -1, false, content)
end

M.assert_cursor_node_has_text = function(want)
    local cursor_node = require("nvim-stormcaller.lib.navigator").get_cursor_node()
    local cursor_node_text = vim.treesitter.get_node_text(cursor_node, 0)
    assert.equals(want, cursor_node_text)
end

M.assert_first_line_of_node_has_text = function(want)
    local cursor_node = require("nvim-stormcaller.lib.navigator").get_cursor_node()
    local cursor_node_text = vim.treesitter.get_node_text(cursor_node, 0)
    assert.equals(want, vim.split(cursor_node_text, "\n")[1])
end
M.assert_last_line_of_node_has_text = function(want)
    local cursor_node = require("nvim-stormcaller.lib.navigator").get_cursor_node()
    local cursor_node_text = vim.treesitter.get_node_text(cursor_node, 0)
    local split = vim.split(cursor_node_text, "\n")
    assert.equals(want, split[#split])
end

return M

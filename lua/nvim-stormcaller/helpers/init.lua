local M = {}

M.set_buf_content = function(content)
    if type(content) == "string" then
        content = vim.split(content, "\n")
    end
    vim.api.nvim_buf_set_lines(0, 0, -1, false, content)
end

return M

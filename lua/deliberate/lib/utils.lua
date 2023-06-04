local M = {}

-------------------------------------------- String Related

---@param class_names string[]
---@return string[]
M.remove_empty_strings = function(class_names)
    for i = #class_names, 1, -1 do
        if class_names[i] == "" then table.remove(class_names, i) end
    end
    return class_names
end

M.pseudo_split = function(single_class)
    local lua_patterns = require("deliberate.lib.lua_patterns")
    local pseudo_prefix, style = string.match(single_class, lua_patterns.pseudo_splitter)
    if not style then
        style = single_class
        pseudo_prefix = ""
    end
    return pseudo_prefix, style
end

-------------------------------------------- Vim Utils

M.get_count = function()
    local count = vim.v.count
    if count < 1 then count = 1 end
    return count
end

M.reset_count = function() vim.cmd("norm! ") end

M.execute_with_count = function(fn, ...)
    local count = M.get_count()
    for _ = 1, count do
        fn(...)
    end
    M.reset_count()
end

M.feed_keys = function(input)
    local feed = vim.api.nvim_replace_termcodes(input, true, true, true)
    vim.api.nvim_feedkeys(feed, "mtix", false)
end

return M

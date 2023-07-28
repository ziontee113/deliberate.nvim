local M = {}

M.read_lines_from_file = function(file_path)
    local ok, file_lines = pcall(vim.fn.readfile, file_path)
    if ok then return file_lines end
end

M.get_root_from_str = function(str, parser_name)
    local parser_ok, parser = pcall(vim.treesitter.get_string_parser, str, parser_name)
    if parser_ok then
        local trees = parser:parse()
        local root = trees[1]:root()
        return root
    end
end

M.query = function(str, parser_name, root, query)
    local parsed_query = vim.treesitter.query.parse(parser_name, query)
    local all_captures = {}

    for _, matches, _ in parsed_query:iter_matches(root, str) do
        for _, node in ipairs(matches) do
            table.insert(all_captures, node)
        end
    end

    if #all_captures > 0 then return all_captures end
end

return M

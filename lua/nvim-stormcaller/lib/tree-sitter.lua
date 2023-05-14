local M = {}

M.find_closest_parent_with_types = function(o)
    local node = o.node
    while node do
        if vim.tbl_contains(o.desired_parent_types, node:type()) then
            break
        end
        node = node:parent()
    end

    if node ~= o.node then
        return node
    end
end

return M

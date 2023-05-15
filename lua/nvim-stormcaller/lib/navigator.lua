local ts_utils = require("nvim-treesitter.ts_utils")
local lib_ts = require("nvim-stormcaller.lib.tree-sitter")

local M = {}

local _cursor_node

M.get_cursor_node = function()
    return _cursor_node
end

---@class find_closest_jsx_node_to_cursor_Opts
---@field buf number
---@field win number

---@param o find_closest_jsx_node_to_cursor_Opts
---@return table, string
local find_closest_jsx_node_to_cursor = function(o)
    local all_jsx_nodes = lib_ts.capture_nodes_with_queries({
        buf = o.buf,
        parser_name = "tsx",
        queries = {
            "(jsx_fragment) @jsx_fragment",
            "(jsx_element) @jsx_element",
            "(jsx_self_closing_element) @jsx_self_closing_element",
        },
        capture_groups = { "jsx_element", "jsx_self_closing_element", "jsx_fragment" },
    })

    local cur_line = unpack(vim.api.nvim_win_get_cursor(o.win))
    local closest_distance, closest_node, jump_destination = math.huge, nil, nil

    for _, node in ipairs(all_jsx_nodes) do
        local start_row, _, end_row, _ = node:range()
        if math.abs(start_row - cur_line) < closest_distance then
            closest_node = node
            jump_destination = "start-of-node"
            closest_distance = math.abs(start_row - cur_line)
        end
        if math.abs(end_row - cur_line) < closest_distance then
            closest_node = node
            jump_destination = "end-of-node"
            closest_distance = math.abs(end_row - cur_line)
        end
    end

    return closest_node, jump_destination
end

---@class navigator_initiate_Opts
---@field win number
---@field buf number

---@param o navigator_initiate_Opts
M.initiate = function(o)
    vim.cmd("norm! ^")

    local current_node = ts_utils.get_node_at_cursor(0)
    local parent = lib_ts.find_closest_parent_with_types({
        node = current_node,
        desired_parent_types = { "jsx_element", "jsx_self_closing_element" },
    })

    if parent then
        lib_ts.put_cursor_at_start_of_node({ node = parent, win = o.win })
        _cursor_node = parent
    else
        local closest_node, jump_destination =
            find_closest_jsx_node_to_cursor({ win = o.win, buf = o.buf })
        if closest_node then
            if jump_destination == "start-of-node" then
                lib_ts.put_cursor_at_start_of_node({ win = o.win, node = closest_node })
            elseif jump_destination == "end-of-node" then
                lib_ts.put_cursor_at_end_of_node({ win = o.win, node = closest_node })
            end
            _cursor_node = closest_node
        end
    end
end

-- local find_target_node = function(o)
--     if o.destination == "next-node-on-screen" then
--         -- TODO:
--     end
-- end
--
-- M.move = function(o)
--     local target_node = find_target_node(o)
-- end

return M

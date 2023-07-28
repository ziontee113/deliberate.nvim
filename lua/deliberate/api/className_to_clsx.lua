local selection = require("deliberate.lib.selection")
local aggregator = require("deliberate.lib.tree-sitter.language_aggregator")
local lib_ts = require("deliberate.lib.tree-sitter")

local M = {}

M.add = function()
    for i = 1, #selection.items() do
        local item = selection.items()[i]
        local className_string_node =
            aggregator.get_className_property_string_node(item.buf, item.node)

        if not className_string_node then goto continue end

        local node_text = vim.treesitter.get_node_text(className_string_node, 0)
        local replacement = string.format("{clsx(%s)}", node_text)

        lib_ts.replace_node_text({
            node = className_string_node,
            replacement = replacement,
            buf = item.buf,
        })

        selection.refresh_tree()

        ::continue::
    end
end

M.remove = function()
    for i = 1, #selection.items() do
        local item = selection.items()[i]
        local clsx_expression = aggregator.get_clsx_expression(item.buf, item.node)
        if not clsx_expression then goto continue end

        local call_expression_node = lib_ts.get_children_with_types({
            node = clsx_expression,
            desired_types = { "call_expression" },
        })[1]

        local arguments_node = lib_ts.get_children_with_types({
            node = call_expression_node,
            desired_types = { "arguments" },
        })[1]

        if
            arguments_node:named_child_count() == 1
            and arguments_node:named_child(0):type() == "string"
        then
            local le_string = vim.treesitter.get_node_text(arguments_node:named_child(0), 0)

            lib_ts.replace_node_text({
                node = clsx_expression,
                replacement = le_string,
                buf = item.buf,
            })

            selection.refresh_tree()
        end

        ::continue::
    end
end

M.toggle_clsx = function()
    local firstItem = selection.items()[1]

    vim.bo[firstItem.buf].undolevels = vim.bo[firstItem.buf].undolevels
    selection.archive_for_undo()
    require("deliberate.api.dot_repeater").register(M.toggle_motion)

    local first_clsx_string_node =
        aggregator.get_clsx_string_node(selection.items()[1].buf, selection.nodes()[1])

    if not first_clsx_string_node then
        M.add()
    else
        M.remove()
    end
end

return M

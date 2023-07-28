local selection = require("deliberate.lib.selection")
local aggregator = require("deliberate.lib.tree-sitter.language_aggregator")
local lib_ts = require("deliberate.lib.tree-sitter")

local M = {}

M.execute = function()
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

return M

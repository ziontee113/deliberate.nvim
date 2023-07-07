local M = {}

local selection = require("deliberate.lib.selection")
local catalyst = require("deliberate.lib.catalyst")
local aggregator = require("deliberate.lib.tree-sitter.language_aggregator")
local lib_ts = require("deliberate.lib.tree-sitter")

M.change_to = function(target_name)
    if vim.bo[(catalyst.buf())].ft ~= "typescriptreact" then return end

    vim.bo[catalyst.buf()].undolevels = vim.bo[catalyst.buf()].undolevels
    selection.archive_for_undo()
    require("deliberate.api.dot_repeater").register(M.change_to, target_name)

    for i = 1, #selection.nodes() do
        local node = selection.nodes()[i]
        local opening_tag_identifier = aggregator.get_tag_identifier_node(node)

        if aggregator.node_is_self_closing(node) then
            lib_ts.replace_node_text({
                node = opening_tag_identifier,
                buf = catalyst.buf(),
                replacement = target_name,
            })
        else
            local _, closing_tag = aggregator.get_opening_and_closing_tags(node)
            lib_ts.replace_node_text({
                node = opening_tag_identifier,
                buf = catalyst.buf(),
                replacement = target_name,
            })
            lib_ts.replace_node_text({
                node = closing_tag,
                buf = catalyst.buf(),
                replacement = string.format("</%s>", target_name),
            })
        end

        selection.refresh_tree()
    end
end

return M

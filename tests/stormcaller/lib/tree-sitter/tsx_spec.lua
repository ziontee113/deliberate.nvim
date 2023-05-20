local helpers = require("stormcaller.helpers")
local lib_ts_tsx = require("stormcaller.lib.tree-sitter.tsx")

describe("get_all_jsx_nodes_in_buffer()", function()
    it("works", function()
        helpers.set_buffer_content_as_multiple_react_components()

        local all_nodes, grouped_captures = lib_ts_tsx.get_all_jsx_nodes_in_buffer(0)

        assert.equals(#all_nodes, 20)
        assert.equals(#grouped_captures["jsx_fragment"], 1)
        assert.equals(#grouped_captures["jsx_element"], 17)
        assert.equals(#grouped_captures["jsx_self_closing_element"], 2)

        vim.api.nvim_buf_delete(0, { force = true })
    end)
end)

describe("get_tag_identifier_node()", function()
    it("works for `jsx_element` node type", function()
        helpers.set_buffer_content_as_multiple_react_components()

        local _, grouped_captures = lib_ts_tsx.get_all_jsx_nodes_in_buffer(0)
        local node = grouped_captures["jsx_element"][1]

        local tag_idenifier_node = lib_ts_tsx.get_tag_identifier_node(node)
        helpers.asset_node_has_text(tag_idenifier_node, "p")

        vim.api.nvim_buf_delete(0, { force = true })
    end)

    it("works for `jsx_self_closing_element` node type", function()
        helpers.set_buffer_content_as_multiple_react_components()

        local _, grouped_captures = lib_ts_tsx.get_all_jsx_nodes_in_buffer(0)
        local node = grouped_captures["jsx_self_closing_element"][1]

        local tag_idenifier_node = lib_ts_tsx.get_tag_identifier_node(node)
        helpers.asset_node_has_text(tag_idenifier_node, "OtherComponent")

        vim.api.nvim_buf_delete(0, { force = true })
    end)
end)

require("tests.editor_config")

local helpers = require("stormcaller.helpers")
local lib_ts_svelte = require("stormcaller.lib.tree-sitter.svelte")

describe("get_all_html_nodes_in_buffer()", function()
    before_each(function() helpers.set_buffer_content_as_svelte_file() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)

    it("works", function()
        local all_nodes, grouped_captures = lib_ts_svelte.get_all_html_nodes_in_buffer(0)

        assert.equals(17, #all_nodes)
        assert.equals(17, #grouped_captures["element"])
    end)
end)

describe("get_tag_identifier_node()", function()
    helpers.set_buffer_content_as_svelte_file()

    it("works for element that has both starting and closing elements", function()
        local all_nodes = lib_ts_svelte.get_all_html_nodes_in_buffer(0)
        local normal_node = all_nodes[15]
        helpers.assert_node_has_text(normal_node, "<h1>Ligma</h1>")

        local tag_idenifier_node = lib_ts_svelte.get_tag_identifier_node(normal_node)
        helpers.assert_node_has_text(tag_idenifier_node, "h1")
    end)

    it("works for element that has only self_closing_tag", function()
        local all_nodes = lib_ts_svelte.get_all_html_nodes_in_buffer(0)
        local self_closing_node = all_nodes[13]
        helpers.assert_node_has_text(self_closing_node, "<Counter />")

        local tag_idenifier_node = lib_ts_svelte.get_tag_identifier_node(self_closing_node)
        helpers.assert_node_has_text(tag_idenifier_node, "Counter")
    end)

    vim.api.nvim_buf_delete(0, { force = true })
end)

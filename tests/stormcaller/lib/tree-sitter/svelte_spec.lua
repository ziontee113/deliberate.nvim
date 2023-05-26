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

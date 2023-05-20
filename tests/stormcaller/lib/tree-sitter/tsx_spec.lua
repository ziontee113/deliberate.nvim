local helpers = require("stormcaller.helpers")
local lib_ts_tsx = require("stormcaller.lib.tree-sitter.tsx")

describe("get_all_jsx_nodes_in_buffer()", function()
    it("works", function()
        helpers.set_buffer_content_as_react_component()

        local all_nodes, grouped_captures = lib_ts_tsx.get_all_jsx_nodes_in_buffer(0)

        assert.equals(#all_nodes, 6)
        assert.equals(#grouped_captures["jsx_fragment"], 1)
        assert.equals(#grouped_captures["jsx_element"], 5)
        assert.equals(#grouped_captures["jsx_self_closing_element"], 0)

        vim.api.nvim_buf_delete(0, { force = true })
    end)
end)

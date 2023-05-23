local helpers = require("stormcaller.helpers")
local catalyst = require("stormcaller.lib.catalyst")
local navigator = require("stormcaller.lib.navigator")
local tag = require("stormcaller.api.html_tag")

describe("add()", function()
    before_each(function() helpers.set_buffer_content_as_multiple_react_components() end)
    after_each(function() helpers.clean_up() end)

    it("works for single target (at cursor node only, no multi selection)", function()
        vim.cmd("norm! 22gg^") -- cursor to <li>Contacts</li>

        catalyst.initiate({ win = 0, buf = 0 })
        helpers.assert_catalyst_node_has_text("<li>Contacts</li>")

        tag.add("li")

        navigator.move({ destination = "next" })
        helpers.assert_catalyst_node_has_text("<li>###</li>")
        helpers.assert_entire_first_line_of_catalyst_node_has_text("        <li>###</li>")
    end)

    -- it("works for multi selection", function()
    --     vim.cmd("norm! 22gg^") -- cursor to <li>Contacts</li>
    --
    --     catalyst.initiate({ win = 0, buf = 0 })
    --     helpers.assert_catalyst_node_has_text("<li>Contacts</li>")
    --
    --     navigator.move({ destination = "next", track_selection = true })
    --     navigator.move({ destination = "next", track_selection = true })
    --
    --     local selected_nodes = catalyst.selected_nodes()
    --     assert.equals(2, #selected_nodes)
    --     helpers.assert_node_has_text(selected_nodes[1], "<li>Contacts</li>")
    --     helpers.assert_node_has_text(selected_nodes[2], "<li>FAQ</li>")
    --
    --     tag.add("li")
    --
    --     local text = vim.treesitter.get_node_text(catalyst.node():parent(), 0)
    --     print(text)
    --
    --     selected_nodes = catalyst.selected_nodes()
    --     assert.equals(2, #selected_nodes)
    --     helpers.assert_node_has_text(selected_nodes[1], "<li>###</li>")
    --     helpers.assert_node_has_text(selected_nodes[2], "<li>###</li>")
    -- end)
end)

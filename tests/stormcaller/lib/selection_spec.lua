local catalyst = require("stormcaller.lib.catalyst")
local navigator = require("stormcaller.api.navigator")
local selection = require("stormcaller.lib.selection")
local helpers = require("stormcaller.helpers")

describe("selection.nodes()", function()
    helpers.set_buffer_content_as_multiple_react_components()

    vim.cmd("norm! 22gg^") -- cursor to <li>Contacts</li>

    it("returns correct nodes after initiating catalyst", function()
        catalyst.initiate({ win = 0, buf = 0 })
        helpers.assert_node_has_text(selection.nodes()[1], "<li>Contacts</li>")
    end)

    it("returns correct nodes after moving catalyst", function()
        navigator.move({ destination = "next" })
        assert.equals(1, #selection.nodes())
        helpers.assert_node_has_text(selection.nodes()[1], "<li>FAQ</li>")

        navigator.move({ destination = "next" })
        assert.equals(1, #selection.nodes())
        helpers.assert_node_has_text(selection.nodes()[1], "<OtherComponent />")
    end)

    it("returns correct nodes after selecting with tracking once", function()
        navigator.move({ destination = "previous", select_move = true })
        helpers.assert_node_has_text(selection.nodes()[1], "<OtherComponent />")
    end)

    it("returns correct nodes after selecting with tracking 2nd and 3rd time", function()
        navigator.move({ destination = "previous", select_move = true })
        helpers.assert_node_has_text(selection.nodes()[1], "<OtherComponent />")
        helpers.assert_node_has_text(selection.nodes()[2], "<li>FAQ</li>")

        navigator.move({ destination = "previous", select_move = true })
        helpers.assert_node_has_text(selection.nodes()[1], "<OtherComponent />")
        helpers.assert_node_has_text(selection.nodes()[2], "<li>FAQ</li>")
        helpers.assert_node_has_text(selection.nodes()[3], "<li>Contacts</li>")
    end)

    it("returned nodes stays the same due to new node already in selection table", function()
        navigator.move({ destination = "next" })
        navigator.move({ destination = "next", select_move = true })

        assert.equals(3, #selection.nodes())
        helpers.assert_node_has_text(selection.nodes()[1], "<OtherComponent />")
        helpers.assert_node_has_text(selection.nodes()[2], "<li>FAQ</li>")
        helpers.assert_node_has_text(selection.nodes()[3], "<li>Contacts</li>")
    end)

    it("returns only current catalyst node after clear() was called", function()
        selection.clear()
        assert.equals(1, #selection.nodes())
        helpers.assert_node_has_text(selection.nodes()[1], "<li>FAQ</li>")
    end)

    helpers.clean_up()
end)

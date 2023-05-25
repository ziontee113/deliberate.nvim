local visual_mode = require("stormcaller.api.visual_mode")
local navigator = require("stormcaller.api.navigator")
local catalyst = require("stormcaller.lib.catalyst")
local selection = require("stormcaller.lib.selection")
local helpers = require("stormcaller.helpers")

describe("visual_mode", function()
    helpers.set_buffer_content_as_multiple_react_components()

    vim.cmd("norm! 22gg^") -- cursor to <li>Contacts</li>

    it("works when only selecting items with visual_mode.on()", function()
        visual_mode.on()

        catalyst.initiate({ win = 0, buf = 0 })
        navigator.move({ destination = "next" })

        assert.equals(2, #selection.nodes())
        helpers.assert_node_has_text(selection.nodes()[1], "<li>Contacts</li>")
        helpers.assert_node_has_text(selection.nodes()[2], "<li>FAQ</li>")

        navigator.move({ destination = "next" })

        assert.equals(3, #selection.nodes())
        helpers.assert_node_has_text(selection.nodes()[1], "<li>Contacts</li>")
        helpers.assert_node_has_text(selection.nodes()[2], "<li>FAQ</li>")
        helpers.assert_node_has_text(selection.nodes()[3], "<OtherComponent />")
    end)

    it("returns to normal selecting behavior after visual_mode.off()", function()
        visual_mode.off()

        assert.equals(1, #selection.nodes())
        helpers.assert_node_has_text(selection.nodes()[1], "<OtherComponent />")

        navigator.move({ destination = "previous" })
        assert.equals(1, #selection.nodes())
        helpers.assert_node_has_text(selection.nodes()[1], "<li>FAQ</li>")
    end)

    helpers.clean_up()
end)

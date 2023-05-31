local visual_mode = require("stormcaller.api.visual_mode")
local navigator = require("stormcaller.api.navigator")
local catalyst = require("stormcaller.lib.catalyst")
local selection = require("stormcaller.lib.selection")
local helpers = require("stormcaller.helpers")

describe("visual_mode", function()
    helpers.set_buffer_content_as_multiple_react_components()

    it("works when only selecting items with visual_mode.on()", function()
        helpers.initiate("22gg^", "<li>Contacts</li>")

        visual_mode.on()

        navigator.move({ destination = "next" })

        assert.equals(2, #selection.nodes())
        helpers.node_has_text(selection.nodes()[1], "<li>Contacts</li>")
        helpers.node_has_text(selection.nodes()[2], "<li>FAQ</li>")

        navigator.move({ destination = "next" })

        assert.equals(3, #selection.nodes())
        helpers.node_has_text(selection.nodes()[1], "<li>Contacts</li>")
        helpers.node_has_text(selection.nodes()[2], "<li>FAQ</li>")
        helpers.node_has_text(selection.nodes()[3], "<OtherComponent />")
    end)

    it("returns to normal selecting behavior after visual_mode.off()", function()
        visual_mode.off()

        assert.equals(1, #selection.nodes())
        helpers.node_has_text(selection.nodes()[1], "<OtherComponent />")

        navigator.move({ destination = "previous" })
        assert.equals(1, #selection.nodes())
        helpers.node_has_text(selection.nodes()[1], "<li>FAQ</li>")
    end)

    it("navigator.move({select_move = true}) works as normal", function()
        navigator.move({ destination = "previous", select_move = true })

        assert.equals(1, #selection.nodes())
        helpers.node_has_text(selection.nodes()[1], "<li>FAQ</li>")

        navigator.move({ destination = "previous", select_move = true })

        assert.equals(2, #selection.nodes())
        helpers.node_has_text(selection.nodes()[1], "<li>FAQ</li>")
        helpers.node_has_text(selection.nodes()[2], "<li>Contacts</li>")
    end)

    helpers.clean_up()
end)

describe("combine `select_move` with `visual_mode`", function()
    helpers.set_buffer_content_as_multiple_react_components()

    it("works", function()
        helpers.initiate("23gg^", "<li>FAQ</li>")

        -- select nodes using select_move
        navigator.move({ destination = "previous", select_move = true })
        navigator.move({ destination = "previous", select_move = true })
        helpers.selection_is(2, {
            "<li>FAQ</li>",
            "<li>Contacts</li>",
        })

        -- select nodes with Visual Mode
        helpers.move("previous", "<li>Home</li>")
        helpers.selection_is(2, {
            "<li>FAQ</li>",
            "<li>Contacts</li>",
        })
        visual_mode.on()
        helpers.selection_is(3, {
            "<li>FAQ</li>",
            "<li>Contacts</li>",
            "<li>Home</li>",
        })

        navigator.move({ destination = "previous" })
        helpers.selection_is(4, {
            "<li>FAQ</li>",
            "<li>Contacts</li>",
            "<li>Home</li>",
            { '<div className="h-screen w-screen bg-zinc-900">', helpers.node_first_line },
        })
    end)

    helpers.clean_up()
end)

local catalyst = require("stormcaller.lib.catalyst")
local navigator = require("stormcaller.api.navigator")
local selection = require("stormcaller.lib.selection")
local helpers = require("stormcaller.helpers")

describe("typescriptreact selection.nodes()", function()
    helpers.set_buffer_content_as_multiple_react_components()

    vim.cmd("norm! 22gg^") -- cursor to <li>Contacts</li>

    it("returns correct nodes after initiating catalyst", function()
        catalyst.initiate({ win = 0, buf = 0 })
        helpers.node_has_text(selection.nodes()[1], "<li>Contacts</li>")
    end)

    it("returns correct nodes after moving catalyst", function()
        navigator.move({ destination = "next" })
        assert.equals(1, #selection.nodes())
        helpers.node_has_text(selection.nodes()[1], "<li>FAQ</li>")

        navigator.move({ destination = "next" })
        assert.equals(1, #selection.nodes())
        helpers.node_has_text(selection.nodes()[1], "<OtherComponent />")
    end)

    it("returns correct nodes after selecting with tracking once", function()
        navigator.move({ destination = "previous", select_move = true })
        helpers.node_has_text(selection.nodes()[1], "<OtherComponent />")
    end)

    it("returns correct nodes after selecting with tracking 2nd and 3rd time", function()
        navigator.move({ destination = "previous", select_move = true })
        helpers.node_has_text(selection.nodes()[1], "<OtherComponent />")
        helpers.node_has_text(selection.nodes()[2], "<li>FAQ</li>")

        navigator.move({ destination = "previous", select_move = true })
        helpers.node_has_text(selection.nodes()[1], "<OtherComponent />")
        helpers.node_has_text(selection.nodes()[2], "<li>FAQ</li>")
        helpers.node_has_text(selection.nodes()[3], "<li>Contacts</li>")
    end)

    it("returned nodes stays the same due to new node already in selection table", function()
        navigator.move({ destination = "next" })
        navigator.move({ destination = "next", select_move = true })

        assert.equals(3, #selection.nodes())
        helpers.node_has_text(selection.nodes()[1], "<OtherComponent />")
        helpers.node_has_text(selection.nodes()[2], "<li>FAQ</li>")
        helpers.node_has_text(selection.nodes()[3], "<li>Contacts</li>")
    end)

    it("returns only current catalyst node after clear() was called", function()
        selection.clear()
        assert.equals(1, #selection.nodes())
        helpers.node_has_text(selection.nodes()[1], "<li>FAQ</li>")
    end)

    helpers.clean_up()
end)

describe("svelte selection.nodes()", function()
    helpers.set_buffer_content_as_svelte_file()

    vim.cmd("norm! 32gg^")

    it("returns correct nodes after initiating catalyst", function()
        catalyst.initiate({ win = 0, buf = 0 })
        helpers.node_has_text(selection.nodes()[1], "<h1>Ligma</h1>")
    end)

    it("returns correct nodes after moving catalyst", function()
        navigator.move({ destination = "next" })
        assert.equals(1, #selection.nodes())
        helpers.node_has_text(selection.nodes()[1], "<h3>is a made-up term</h3>")

        navigator.move({ destination = "next" })
        assert.equals(1, #selection.nodes())
        helpers.node_has_text(
            selection.nodes()[1],
            "<p>that gained popularity as part of an Internet prank or meme.</p>"
        )
    end)

    it("returns correct nodes after selecting with tracking once", function()
        navigator.move({ destination = "previous", select_move = true })
        helpers.node_has_text(
            selection.nodes()[1],
            "<p>that gained popularity as part of an Internet prank or meme.</p>"
        )
    end)

    it("returns correct nodes after selecting with tracking 2nd and 3rd time", function()
        navigator.move({ destination = "previous", select_move = true })
        helpers.node_has_text(
            selection.nodes()[1],
            "<p>that gained popularity as part of an Internet prank or meme.</p>"
        )
        helpers.node_has_text(selection.nodes()[2], "<h3>is a made-up term</h3>")

        navigator.move({ destination = "previous", select_move = true })
        helpers.node_has_text(
            selection.nodes()[1],
            "<p>that gained popularity as part of an Internet prank or meme.</p>"
        )
        helpers.node_has_text(selection.nodes()[2], "<h3>is a made-up term</h3>")
        helpers.node_has_text(selection.nodes()[3], "<h1>Ligma</h1>")
    end)

    it("returned nodes stays the same due to new node already in selection table", function()
        navigator.move({ destination = "next" })
        navigator.move({ destination = "next", select_move = true })

        assert.equals(3, #selection.nodes())
        helpers.node_has_text(
            selection.nodes()[1],
            "<p>that gained popularity as part of an Internet prank or meme.</p>"
        )
        helpers.node_has_text(selection.nodes()[2], "<h3>is a made-up term</h3>")
        helpers.node_has_text(selection.nodes()[3], "<h1>Ligma</h1>")
    end)

    it("returns only current catalyst node after clear() was called", function()
        selection.clear()
        assert.equals(1, #selection.nodes())
        helpers.node_has_text(selection.nodes()[1], "<h3>is a made-up term</h3>")
    end)

    helpers.clean_up()
end)

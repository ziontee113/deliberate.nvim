require("tests.editor_config")

local navigator = require("stormcaller.api.navigator")
local selection = require("stormcaller.lib.selection")

local h = require("stormcaller.helpers")
local initiate = h.initiate
local mova = h.move_then_assert_selection

describe("typescriptreact selection.nodes()", function()
    h.set_buffer_content_as_multiple_react_components()

    it("works on initiate", function() initiate("22gg^", "<li>Contacts</li>") end)
    it("move next 2 times", function()
        mova("next", 1, { "<li>FAQ</li>" }, "<li>FAQ</li>")
        mova("next", 1, { "<OtherComponent />" }, "<OtherComponent />")
    end)
    it(
        "returns correct nodes after selecting with select_move once",
        function() mova({ "previous", true }, 1, { "<OtherComponent />" }, "<li>FAQ</li>") end
    )
    it("returns correct nodes after selecting with tracking 2nd and 3rd time", function()
        mova({ "previous", true }, 2, { "<OtherComponent />", "<li>FAQ</li>" }, "<li>Contacts</li>")
        mova({ "previous", true }, 3, {
            "<OtherComponent />",
            "<li>FAQ</li>",
            "<li>Contacts</li>",
        }, { "<li>", h.catalyst_first })
    end)
    it("remove 1 item from selection due to 'selecting over' an already selected node", function()
        navigator.move({ destination = "next" })
        mova({ "next", true }, 2, {
            "<OtherComponent />",
            "<li>FAQ</li>",
        }, "<li>FAQ</li>")
    end)
    it("returns only current catalyst node after clear() was called", function()
        selection.clear()
        assert.equals(1, #selection.nodes())
        h.node_has_text(selection.nodes()[1], "<li>FAQ</li>")
    end)

    h.clean_up()
end)

describe("svelte selection.nodes()", function()
    h.set_buffer_content_as_svelte_file()

    it("works on initiate", function() initiate("32gg^", "<h1>Ligma</h1>") end)
    it("returns correct nodes after moving catalyst", function()
        mova("next", 1, "<h3>is a made-up term</h3>", "<h3>is a made-up term</h3>")
        mova(
            "next",
            1,
            "<p>that gained popularity as part of an Internet prank or meme.</p>",
            "<p>that gained popularity as part of an Internet prank or meme.</p>"
        )
    end)
    it(
        "returns correct nodes after selecting with tracking once",
        function()
            mova(
                { "previous", true },
                1,
                { "<p>that gained popularity as part of an Internet prank or meme.</p>" },
                "<h3>is a made-up term</h3>"
            )
        end
    )
    it("returns correct nodes after selecting with tracking 2nd and 3rd time", function()
        mova({ "previous", true }, 2, {
            "<p>that gained popularity as part of an Internet prank or meme.</p>",
            "<h3>is a made-up term</h3>",
        }, "<h1>Ligma</h1>")
        mova({ "previous", true }, 3, {
            "<p>that gained popularity as part of an Internet prank or meme.</p>",
            "<h3>is a made-up term</h3>",
            "<h1>Ligma</h1>",
        }, { "<section>", h.catalyst_first })
    end)
    it("remove 1 item from selection due to 'selecting over' an already selected node", function()
        navigator.move({ destination = "next" })
        mova({ "next", true }, 2, {
            "<p>that gained popularity as part of an Internet prank or meme.</p>",
            "<h3>is a made-up term</h3>",
        }, "<h3>is a made-up term</h3>")
    end)
    it("returns only current catalyst node after clear() was called", function()
        selection.clear()
        assert.equals(1, #selection.nodes())
        h.node_has_text(selection.nodes()[1], "<h3>is a made-up term</h3>")
    end)

    h.clean_up()
end)

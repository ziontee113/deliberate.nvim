local visual_collector = require("stormcaller.api.visual_collector")
local selection = require("stormcaller.lib.selection")
local helpers = require("stormcaller.helpers")
local mova = helpers.move_then_assert_selection

describe("visual_collector", function()
    helpers.set_buffer_content_as_multiple_react_components()

    it("starts collecting nodes on move after visual_collector.start()", function()
        helpers.initiate("22gg^", "<li>Contacts</li>")

        visual_collector.start()
        helpers.selection_is(1, { "<li>Contacts</li>" })

        mova("next", 2, { "<li>Contacts</li>", "<li>FAQ</li>" }, "<li>FAQ</li>")

        mova("next", 3, {
            "<li>Contacts</li>",
            "<li>FAQ</li>",
            "<OtherComponent />",
        }, "<OtherComponent />")
    end)

    it("stops collecting nodes on move with visual_collector.on()", function()
        visual_collector.stop()
        helpers.selection_is(3, {
            "<li>Contacts</li>",
            "<li>FAQ</li>",
            "<OtherComponent />",
        })
    end)

    it("selection only gets cleared if `selection.clear()` is called", function()
        selection.clear()
        helpers.selection_is(1, "<OtherComponent />")

        mova("previous", 1, "<li>FAQ</li>", "<li>FAQ</li>")
    end)

    it("navigator.move({select_move = true}) works as normal", function()
        mova({ "previous", true }, 1, { "<li>FAQ</li>" }, "<li>Contacts</li>")
        mova({ "previous", true }, 2, { "<li>FAQ</li>", "<li>Contacts</li>" }, helpers.long_li_tag)
    end)

    it("use `visual_collector` alongside `select_move`", function()
        mova("previous", 2, { "<li>FAQ</li>", "<li>Contacts</li>" }, "<li>Home</li>")

        visual_collector.start()
        helpers.selection_is(3, { "<li>FAQ</li>", "<li>Contacts</li>", "<li>Home</li>" })

        mova("previous", 4, {
            "<li>FAQ</li>",
            "<li>Contacts</li>",
            "<li>Home</li>",
            { '<div className="h-screen w-screen bg-zinc-900">', helpers.node_first_line },
        })
    end)

    helpers.clean_up()
end)

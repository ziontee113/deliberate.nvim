require("tests.editor_config")

local yank = require("stormcaller.api.yank")
local paste = require("stormcaller.api.paste")
local h = require("stormcaller.helpers")
local movA = h.move_then_assert_selection

describe("paste()", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("works for destination = after, catalyst selection", function()
        h.initiate("22gg^", "<li>Contacts</li>")
        yank.call()
        paste({ destination = "next" })
        h.catalyst_has("<li>Contacts</li>", { 23, 8 })
        h.move("next", "<li>FAQ</li>", { 24, 8 })
    end)

    it("destination = after, multi selection, clear after yank, join on by default", function()
        h.initiate("22gg^", "<li>Contacts</li>")
        movA({ "next", true }, 1, "<li>Contacts</li>")
        movA({ "next", true }, 2, { "<li>Contacts</li>", "<li>FAQ</li>" })

        yank.call()
        h.selection_is(1, "<OtherComponent />")

        paste()

        h.catalyst_has("<li>Contacts</li>", { 25, 8 })
    end)
end)

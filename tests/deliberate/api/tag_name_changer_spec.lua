require("tests.editor_config")

local tag_changer = require("deliberate.api.tag_name_changer")
local h = require("deliberate.helpers")
local movA = h.move_then_assert_selection

describe("tag_name_changer", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("works on single selection", function()
        h.initiate("22gg^", "<li>Contacts</li>")
        tag_changer.change_to("h1")
        h.catalyst_has("<h1>Contacts</h1>")
    end)

    it("works on multiple selections", function()
        h.initiate("22gg^", "<li>Contacts</li>")
        movA({ "next", true }, 1, { "<li>Contacts</li>" })
        movA({ "next", true }, 2, { "<li>Contacts</li>", "<li>FAQ</li>" })
        tag_changer.change_to("h2")
        h.selection_is(2, { "<h2>Contacts</h2>", "<h2>FAQ</h2>" })
    end)
end)

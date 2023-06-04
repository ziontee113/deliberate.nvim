require("tests.editor_config")

local undo = require("deliberate.api.undo")
local tag = require("deliberate.api.html_tag")

local h = require("deliberate.helpers")

describe("...", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("...", function()
        h.initiate("22gg^", "<li>Contacts</li>")

        tag.add({ tag = "div", content = "", destination = "next" })
        h.selection_is(1, "<div></div>")

        undo.call(true)

        h.selection_is(1, "<li>Contacts</li>")
    end)
end)

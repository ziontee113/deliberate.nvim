require("tests.editor_config")

local archive = require("deliberate.lib.selection.extmark_archive")
local h = require("deliberate.helpers")
local tag = require("deliberate.api.html_tag")

describe("...", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("...", function()
        h.initiate("22gg^", "<li>Contacts</li>")

        tag.add({ tag = "div", content = "", destination = "next" })
        h.selection_is(1, "<div></div>")

        local latest_archive = archive.pop_undo_stack()
        assert.same({ { 21, 8 } }, latest_archive)
    end)
end)

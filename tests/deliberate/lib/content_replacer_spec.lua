require("tests.editor_config")

local replacer = require("deliberate.lib.content_replacer")
local h = require("deliberate.helpers")

describe("replacer.replace()", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("works with single line input", function()
        h.initiate("22gg^", "<li>Contacts</li>")
        replacer.replace("okman")
        h.catalyst_has("<li>okman</li>", { 22, 8 })
    end)
end)

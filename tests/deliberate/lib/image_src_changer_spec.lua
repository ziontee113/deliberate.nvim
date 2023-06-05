require("tests.editor_config")

local src_changer = require("deliberate.lib.image_src_changer")
local h = require("deliberate.helpers")

describe("src_changer.change()", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("works", function()
        h.initiate("22gg^", "<li>Contacts</li>")
        src_changer.replace("public/image.jpg")
        h.catalyst_has('<li src="public/image.jpg">Contacts</li>', { 22, 8 })
    end)
end)

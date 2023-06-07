require("tests.editor_config")

local tcm = require("deliberate.api.tailwind_class_modifier")
local dot_repeater = require("deliberate.api.dot_repeater")
local h = require("deliberate.helpers")
local movA = h.move_then_assert_selection

describe("dot_repeater.call()", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("works when applying Tailwind Classes", function()
        h.initiate("36gg^", "<li>Log In</li>")

        tcm.change_padding({ axis = "", value = "p-4" })
        h.catalyst_has('<li className="p-4">Log In</li>')

        movA("next", 1, "<li>Sign Up</li>")
        dot_repeater.call()
        h.catalyst_has('<li className="p-4">Sign Up</li>')
    end)
end)

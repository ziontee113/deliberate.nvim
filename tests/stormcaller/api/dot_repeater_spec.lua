require("tests.editor_config")

local html_tag = require("stormcaller.api.html_tag")
local tcm = require("stormcaller.api.tailwind_class_modifier")
local dot_repeater = require("stormcaller.api.dot_repeater")
local h = require("stormcaller.helpers")
local movA = h.move_then_assert_selection

describe("dot_repeater.call()", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("works when adding new html tag", function()
        h.initiate("36gg^", "<li>Log In</li>")

        html_tag.add({ tag = "li", destination = "next", content = "Singing Got Better" })
        h.catalyst_has("<li>Singing Got Better</li>", { 37, 8 })

        dot_repeater.call()
        h.catalyst_has("<li>Singing Got Better</li>", { 38, 8 })

        dot_repeater.call()
        h.catalyst_has("<li>Singing Got Better</li>", { 39, 8 })
    end)

    it("works when applying Tailwind Classes", function()
        h.initiate("36gg^", "<li>Log In</li>")

        tcm.change_padding({ axis = "", value = "p-4" })
        h.catalyst_has('<li className="p-4">Log In</li>')

        movA("next", 1, "<li>Sign Up</li>")
        dot_repeater.call()
        h.catalyst_has('<li className="p-4">Sign Up</li>')
    end)
end)

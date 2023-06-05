require("tests.editor_config")

local undo = require("deliberate.api.undo")
local tag = require("deliberate.api.html_tag")
local selection = require("deliberate.lib.selection")

local h = require("deliberate.helpers")

describe("undo.call()", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("restore previous state after tag.add()", function()
        h.initiate("36gg^", "<li>Log In</li>")

        tag.add({ tag = "div", content = "", destination = "next" })
        h.catalyst_has("<div></div>", { 37, 8 })
        h.node_has_text(
            selection.nodes()[1]:parent(),
            [[<ul>
        <li>Log In</li>
        <div></div>
        <li>Sign Up</li>
      </ul>]]
        )

        undo.call(true)

        h.catalyst_has("<li>Log In</li>", { 36, 8 })
        h.node_has_text(
            selection.nodes()[1]:parent(),
            [[<ul>
        <li>Log In</li>
        <li>Sign Up</li>
      </ul>]]
        )
    end)
end)

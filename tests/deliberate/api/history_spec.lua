require("tests.editor_config")

local history = require("deliberate.api.history")
local tag = require("deliberate.api.html_tag")
local selection = require("deliberate.lib.selection")
local visual_collector = require("deliberate.api.visual_collector")
local h = require("deliberate.helpers")
local movA = h.move_then_assert_selection

describe("history.undo()", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("restore previous state", function()
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

        history.undo(true)

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

describe("history.redo()", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    local before_undo = [[<ul>
        <li>Log In</li>
        <h1>okman</h1>
        <li>Sign Up</li>
        <h1>okman</h1>
      </ul>]]

    local after_undo = [[<ul>
        <li>Log In</li>
        <li>Sign Up</li>
      </ul>]]

    it("works", function()
        h.initiate("36gg^", "<li>Log In</li>")
        visual_collector.start()
        movA("next", 2, { "<li>Log In</li>", "<li>Sign Up</li>" })

        tag.add({ tag = "h1", content = "okman", destination = "next" })
        h.selection_is(2, { "<h1>okman</h1>", "<h1>okman</h1>" })
        h.node_has_text(selection.nodes()[1]:parent(), before_undo)

        history.undo(true)
        h.selection_is(2, { "<li>Log In</li>", "<li>Sign Up</li>" })
        h.node_has_text(selection.nodes()[1]:parent(), after_undo)

        history.redo(true)
        h.selection_is(2, { "<h1>okman</h1>", "<h1>okman</h1>" })
        h.node_has_text(selection.nodes()[1]:parent(), before_undo)

        history.undo(true)
        h.selection_is(2, { "<li>Log In</li>", "<li>Sign Up</li>" })
        h.node_has_text(selection.nodes()[1]:parent(), after_undo)

        history.redo(true)
        h.selection_is(2, { "<h1>okman</h1>", "<h1>okman</h1>" })
        h.node_has_text(selection.nodes()[1]:parent(), before_undo)
    end)
end)

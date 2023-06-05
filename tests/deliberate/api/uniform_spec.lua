require("tests.editor_config")

local selection = require("deliberate.lib.selection")
local uniform = require("deliberate.api.uniform")
local navigator = require("deliberate.api.navigator")
local tag = require("deliberate.api.html_tag")

local h = require("deliberate.helpers")
local initiate = h.initiate
local add = h.add
local move = h.move
local movesel = h.move_then_assert_selection
local long_li_tag = h.long_li_tag

describe("uniform.move()", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("works on destination == next-sibling", function()
        initiate("17gg^", "<li>Home</li>")
        movesel({ "next", true }, 1, "<li>Home</li>", long_li_tag)
        move("next", "<li>Contacts</li>")
        movesel({ "next", true }, 2, { "<li>Home</li>", "<li>Contacts</li>" }, "<li>FAQ</li>")

        uniform.move({ destination = "next-sibling" })
        h.selection_is(2, { long_li_tag, "<li>FAQ</li>" })
    end)

    it("works on destination == parent", function()
        initiate("35gg^", "<ul>", h.catalyst_first)
        navigator.move({ destination = "next", select_move = true })
        navigator.move({ destination = "next", select_move = true })
        h.selection_is(2, {
            [[<ul>
        <li>Log In</li>
        <li>Sign Up</li>
      </ul>]],
            "<li>Log In</li>",
        })

        uniform.move({ destination = "parent" })

        h.selection_is(2, {
            [[<div>
      <ul>
        <li>Log In</li>
        <li>Sign Up</li>
      </ul>
    </div>]],
            [[<ul>
        <li>Log In</li>
        <li>Sign Up</li>
      </ul>]],
        })
    end)

    it("works on destination = next & destination == previous", function()
        initiate("35gg^", "<ul>", h.catalyst_first)
        add({ "div", "next", "" }, "<div></div>", { 39, 6 })
        add({ "ul", "inside", "" }, "<ul></ul>", { 40, 8 })
        h.loop(3, add, { { "ul", "next", "" }, "<ul></ul>" })
        h.loop(4, navigator.move, { { destination = "previous", select_move = true } })
        h.selection_is(4, { "<ul></ul>", "<ul></ul>", "<ul></ul>", "<ul></ul>" })
        h.node_has_text(
            selection.nodes()[1]:parent():parent(),
            [[<div>
      <ul>
        <li>Log In</li>
        <li>Sign Up</li>
      </ul>
      <div>
        <ul></ul>
        <ul></ul>
        <ul></ul>
        <ul></ul>
      </div>
    </div>]]
        )

        tag.add({ tag = "li", destination = "inside", content = "1st" })
        tag.add({ tag = "li", destination = "next", content = "2nd" })
        tag.add({ tag = "li", destination = "next", content = "3rd" })
        h.node_has_text(
            selection.nodes()[1]:parent():parent(),
            [[<div>
        <ul>
          <li>1st</li>
          <li>2nd</li>
          <li>3rd</li>
        </ul>
        <ul>
          <li>1st</li>
          <li>2nd</li>
          <li>3rd</li>
        </ul>
        <ul>
          <li>1st</li>
          <li>2nd</li>
          <li>3rd</li>
        </ul>
        <ul>
          <li>1st</li>
          <li>2nd</li>
          <li>3rd</li>
        </ul>
      </div>]]
        )
        h.selection_is(4, { "<li>3rd</li>", "<li>3rd</li>", "<li>3rd</li>", "<li>3rd</li>" })
        h.catalyst_first("<li>3rd</li>", { 43, 10 })

        uniform.move({ destination = "previous" })
        h.selection_is(4, { "<li>2nd</li>", "<li>2nd</li>", "<li>2nd</li>", "<li>2nd</li>" })

        uniform.move({ destination = "previous" })
        h.selection_is(4, { "<li>1st</li>", "<li>1st</li>", "<li>1st</li>", "<li>1st</li>" })

        uniform.move({ destination = "previous" })
        local ul_content = [[<ul>
          <li>1st</li>
          <li>2nd</li>
          <li>3rd</li>
        </ul>]]
        h.selection_is(4, { ul_content, ul_content, ul_content, ul_content })

        -- should do nothing
        uniform.move({ destination = "previous" })
        h.selection_is(4, { ul_content, ul_content, ul_content, ul_content })

        -- should select children
        uniform.move({ destination = "next" })
        h.selection_is(4, { "<li>1st</li>", "<li>1st</li>", "<li>1st</li>", "<li>1st</li>" })

        uniform.move({ destination = "next" })
        h.selection_is(4, { "<li>2nd</li>", "<li>2nd</li>", "<li>2nd</li>", "<li>2nd</li>" })

        uniform.move({ destination = "next" })
        h.selection_is(4, { "<li>3rd</li>", "<li>3rd</li>", "<li>3rd</li>", "<li>3rd</li>" })
    end)
end)

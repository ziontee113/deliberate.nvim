require("tests.editor_config")

local catalyst = require("stormcaller.lib.catalyst")
local selection = require("stormcaller.lib.selection")
local navigator = require("stormcaller.api.navigator")
local html_tag = require("stormcaller.api.html_tag")

local h = require("stormcaller.helpers")
local initiate = h.initiate
local move = h.move
local mova = h.move_then_assert_selection

local add = function(args, has_text, cursor, has_entire_line)
    html_tag.add({ tag = args[1], destination = args[2], content = args[3] })
    h.catalyst_has(has_text)
    if cursor then assert.same(cursor, vim.api.nvim_win_get_cursor(0)) end
    if has_entire_line then h.catalyst_entire_first_line(has_entire_line) end
end

-------------------------------------------- Typescriptreact

describe("tag.add() on current catalyst node", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("destination = next", function()
        initiate("22gg^", "<li>Contacts</li>")
        add({ "li", "next" }, "<li>###</li>", { 23, 8 }, "        <li>###</li>")
    end)

    it("destination = previous", function()
        initiate("22gg^", "<li>Contacts</li>")
        add({ "h3", "previous" }, "<h3>###</h3>", { 22, 8 }, "        <h3>###</h3>")
    end)

    it("destination = inside", function()
        initiate("22gg^", "<li>Contacts</li>")
        add({ "div", "next", "" }, "<div></div>", { 23, 8 })
        -- test destination = inside on tag with no children
        add({ "h1", "inside", "inside the div" }, "<h1>inside the div</h1>", { 24, 10 })
        h.node_has_text(
            catalyst.node():parent(),
            [[<div>
          <h1>inside the div</h1>
        </div>]]
        )
        add({ "p", "next", "Lorem ipsum" }, "<p>Lorem ipsum</p>", { 25, 10 })
        h.node_has_text(
            catalyst.node():parent(),
            [[<div>
          <h1>inside the div</h1>
          <p>Lorem ipsum</p>
        </div>]]
        )
        -- test destination = inside on tag already has children
        move("parent", "<div>", { 23, 8 }, h.catalyst_first)
        add({ "h3", "inside" }, "<h3>###</h3>", { 26, 10 })
        h.node_has_text(
            catalyst.node():parent(),
            [[<div>
          <h1>inside the div</h1>
          <p>Lorem ipsum</p>
          <h3>###</h3>
        </div>]]
        )
    end)
end)

describe("tag.add() on multiple (all) selected nodes", function()
    h.set_buffer_content_as_multiple_react_components()

    it("add new tag after each selection", function()
        initiate("22gg^", "<li>Contacts</li>")
        mova({ "next", true }, 1, "<li>Contacts</li>")
        mova({ "next", true }, 2, { "<li>Contacts</li>", "<li>FAQ</li>" })
        html_tag.add({ tag = "li", destination = "next", content = "first_add" })
        h.selection_is(2, { "<li>first_add</li>", "<li>first_add</li>" })
        h.node_has_text(
            selection.nodes()[1]:parent(),
            [[<div className="h-screen w-screen bg-zinc-900">
        <li>Home</li>
        <li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>
        <li>Contacts</li>
        <li>first_add</li>
        <li>FAQ</li>
        <li>first_add</li>
        <OtherComponent />
      </div>]]
        )
        h.catalyst_has("<OtherComponent />", { 26, 8 })
    end)

    it("clear current selection, select 2 tags, add new tag after each selection", function()
        selection.clear()
        mova({ "previous", true }, 1, "<OtherComponent />", "<li>first_add</li>")
        move("previous", "<li>FAQ</li>")
        move("previous", "<li>first_add</li>")
        move("previous", "<li>Contacts</li>")
        move("previous", "        </li>", { 21, 12 }, h.catalyst_last)
        move("previous", "<li>Home</li>")
        mova({ "previous", true }, 2, {
            "<OtherComponent />",
            "<li>Home</li>",
        }, { '<div className="h-screen w-screen bg-zinc-900">', h.catalyst_first })

        html_tag.add({ tag = "h1", destination = "next", content = "2nd" })
        h.selection_is(2, {
            "<h1>2nd</h1>",
            "<h1>2nd</h1>",
        })
        h.node_has_text(
            selection.nodes()[1]:parent(),
            [[<div className="h-screen w-screen bg-zinc-900">
        <li>Home</li>
        <h1>2nd</h1>
        <li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>
        <li>Contacts</li>
        <li>first_add</li>
        <li>FAQ</li>
        <li>first_add</li>
        <OtherComponent />
        <h1>2nd</h1>
      </div>]]
        )
    end)

    it("keeping current selection, add new tag before each selection", function()
        html_tag.add({ tag = "h3", destination = "previous", content = "third-add-call" })
        h.selection_is(2, {
            "<h3>third-add-call</h3>",
            "<h3>third-add-call</h3>",
        })
        h.node_has_text(
            selection.nodes()[1]:parent(),
            [[<div className="h-screen w-screen bg-zinc-900">
        <li>Home</li>
        <h3>third-add-call</h3>
        <h1>2nd</h1>
        <li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>
        <li>Contacts</li>
        <li>first_add</li>
        <li>FAQ</li>
        <li>first_add</li>
        <OtherComponent />
        <h3>third-add-call</h3>
        <h1>2nd</h1>
      </div>]]
        )
    end)

    h.clean_up()
end)

describe("further tag.add() tests with destination = inside", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("assure tag.add() works when tag already has children", function()
        initiate("34gg^", "<div>", h.catalyst_first)
        add({ "h1", "inside", "2NE1" }, "<h1>2NE1</h1>", { 39, 6 })
        h.node_has_text(
            selection.nodes()[1]:parent(),
            [[<div>
      <ul>
        <li>Log In</li>
        <li>Sign Up</li>
      </ul>
      <h1>2NE1</h1>
    </div>]]
        )
    end)

    it("assure tag.add() works when selection is composed with parent & children nodes", function()
        initiate("34gg^", "<div>", h.catalyst_first)
        navigator.move({ destination = "next", select_move = true })
        navigator.move({ destination = "next", select_move = true })
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

        -- add with destination = "inside"
        html_tag.add({ tag = "p", content = "Beyonce", destination = "inside" })
        h.selection_is(2, {
            "<p>Beyonce</p>",
            "<p>Beyonce</p>",
        })
        h.node_has_text(
            selection.nodes()[1]:parent(),
            [[<div>
      <ul>
        <li>Log In</li>
        <li>Sign Up</li>
        <p>Beyonce</p>
      </ul>
      <p>Beyonce</p>
    </div>]]
        )

        -- add with destination = "next"
        html_tag.add({ tag = "h3", content = "Partition", destination = "next" })
        h.selection_is(2, {
            "<h3>Partition</h3>",
            "<h3>Partition</h3>",
        })
        h.node_has_text(
            selection.nodes()[1]:parent(),
            [[<div>
      <ul>
        <li>Log In</li>
        <li>Sign Up</li>
        <p>Beyonce</p>
        <h3>Partition</h3>
      </ul>
      <p>Beyonce</p>
      <h3>Partition</h3>
    </div>]]
        )
    end)
end)

-------------------------------------------- Svelte

describe("tag.add() on current catalyst node", function()
    before_each(function() h.set_buffer_content_as_svelte_file() end)
    after_each(function() h.clean_up() end)

    it("destination = next", function()
        initiate("24gg^", "<h2>", h.catalyst_first)
        add({ "li", "next", "next" }, "<li>next</li>", { 27, 4 }, "    <li>next</li>")
    end)

    it("destination = previous", function()
        initiate("24gg^", "<h2>", h.catalyst_first)
        add({ "h3", "previous", "prev" }, "<h3>prev</h3>", { 24, 4 }, "    <h3>prev</h3>")
    end)
end)

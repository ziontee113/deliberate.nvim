require("tests.editor_config")

local ts_utils = require("nvim-treesitter.ts_utils")
local lib_ts_tsx = require("stormcaller.lib.tree-sitter.tsx")

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

describe("add()", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("works for single target (cursor node only), destination = next", function()
        initiate("22gg^", "<li>Contacts</li>")
        add({ "li", "next" }, "<li>###</li>", { 23, 8 }, "        <li>###</li>") -- catalyst node should be updated to newly created node without manual `navigator.move()`
    end)

    it("works for single target (cursor node only), destination = previous", function()
        initiate("22gg^", "<li>Contacts</li>")
        add({ "h3", "previous" }, "<h3>###</h3>", { 22, 8 }, "        <h3>###</h3>") -- catalyst node should be updated to newly created node without manual `navigator.move()`
    end)

    it("works for single target (cursor node only), destination = inside", function()
        initiate("22gg^", "<li>Contacts</li>")
        add({ "div", "next", "" }, "<div></div>", { 23, 8 })
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
    end)
end)

describe("tag.add() chain testing with destinations `next` & `previous`", function()
    h.set_buffer_content_as_multiple_react_components()

    it("Adds new tag after each selected node", function()
        initiate("22gg^", "<li>Contacts</li>")
        mova({ "next", true }, 1, "<li>Contacts</li>")
        mova({ "next", true }, 2, { "<li>Contacts</li>", "<li>FAQ</li>" })

        html_tag.add({ tag = "li", destination = "next", content = "first_add" })
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
        h.selection_is(2, { "<li>first_add</li>", "<li>first_add</li>" })
        h.catalyst_has("<OtherComponent />")
        assert.same({ 26, 8 }, vim.api.nvim_win_get_cursor(0))
    end)

    it("clears current selection, select 2 tags, add new tag after each selection", function()
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
        h.selection_is(2, {
            "<h1>2nd</h1>",
            "<h1>2nd</h1>",
        })
    end)

    it("keeping current selection, add new tag before each selection", function()
        html_tag.add({ tag = "h3", destination = "previous", content = "third-add-call" })
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
        h.selection_is(2, {
            "<h3>third-add-call</h3>",
            "<h3>third-add-call</h3>",
        })
    end)

    h.clean_up()
end)

describe("tag.add() with inside destination", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("works when tag already has children", function()
        vim.cmd("norm! 16gg^") -- cursor to <div className="h-screen w-screen bg-zinc-900">

        catalyst.initiate({ win = 0, buf = 0 })
        h.catalyst_first('<div className="h-screen w-screen bg-zinc-900">')

        html_tag.add({ tag = "h1", content = "2NE1", destination = "inside" })

        h.node_has_text(selection.nodes()[1], "<h1>2NE1</h1>")
        h.node_has_text(
            selection.nodes()[1]:parent(),
            [[<div className="h-screen w-screen bg-zinc-900">
        <li>Home</li>
        <li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>
        <li>Contacts</li>
        <li>FAQ</li>
        <OtherComponent />
        <h1>2NE1</h1>
      </div>]]
        )
    end)

    it("chains with destination = next afterwards", function()
        vim.cmd("norm! 34gg^") -- cursor to <div>

        catalyst.initiate({ win = 0, buf = 0 })

        navigator.move({ destination = "next", select_move = true })
        navigator.move({ destination = "next", select_move = true })

        assert.equals(2, #selection.nodes())
        h.node_has_text(
            selection.nodes()[1],
            [[<div>
      <ul>
        <li>Log In</li>
        <li>Sign Up</li>
      </ul>
    </div>]]
        )
        h.node_has_text(
            selection.nodes()[2],
            [[<ul>
        <li>Log In</li>
        <li>Sign Up</li>
      </ul>]]
        )

        -- add with destination = "inside"
        html_tag.add({ tag = "p", content = "Beyonce", destination = "inside" })

        assert.equals(2, #selection.nodes())
        h.node_has_text(selection.nodes()[1], "<p>Beyonce</p>")
        h.node_has_text(selection.nodes()[2], "<p>Beyonce</p>")

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

        assert.equals(2, #selection.nodes())
        h.node_has_text(selection.nodes()[1], "<h3>Partition</h3>")
        h.node_has_text(selection.nodes()[2], "<h3>Partition</h3>")

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

describe("tag.add() chain testing with destinations `next` & `previous` & `inside`", function()
    h.set_buffer_content_as_multiple_react_components()

    it("first select 2 li elements, then add empty <div> tag after each selection", function()
        vim.cmd("norm! 22gg^") -- cursor to <li>Contacts</li>

        catalyst.initiate({ win = 0, buf = 0 })
        h.catalyst_has("<li>Contacts</li>")

        navigator.move({ destination = "next", select_move = true })
        navigator.move({ destination = "next", select_move = true })

        assert.equals(2, #selection.nodes())
        h.node_has_text(selection.nodes()[1], "<li>Contacts</li>")
        h.node_has_text(selection.nodes()[2], "<li>FAQ</li>")

        html_tag.add({ tag = "div", destination = "next", content = "" })

        h.node_has_text(
            selection.nodes()[1]:parent(),
            [[<div className="h-screen w-screen bg-zinc-900">
        <li>Home</li>
        <li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>
        <li>Contacts</li>
        <div></div>
        <li>FAQ</li>
        <div></div>
        <OtherComponent />
      </div>]]
        )

        -- check that selection becomes newly added tags
        assert.equals(2, #selection.nodes())
        h.node_has_text(selection.nodes()[1], "<div></div>")
        h.node_has_text(selection.nodes()[2], "<div></div>")

        -- assure that the catalyst node's cursor auto moves after the buffer change caused by `tag.add()`
        local node_at_cursor = ts_utils.get_node_at_cursor()
        local html_node_at_cursor = lib_ts_tsx.get_html_node(node_at_cursor)
        h.node_has_text(html_node_at_cursor, "<OtherComponent />")
    end)

    it("adds new <p> tag inside each selection", function()
        html_tag.add({ tag = "p", destination = "inside", content = "testing_1" })

        assert.equals(2, #selection.nodes())
        h.node_has_text(selection.nodes()[1], "<p>testing_1</p>")
        h.node_has_text(selection.nodes()[2], "<p>testing_1</p>")

        h.node_has_text(
            selection.nodes()[1]:parent():parent(),
            [[<div className="h-screen w-screen bg-zinc-900">
        <li>Home</li>
        <li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>
        <li>Contacts</li>
        <div>
          <p>testing_1</p>
        </div>
        <li>FAQ</li>
        <div>
          <p>testing_1</p>
        </div>
        <OtherComponent />
      </div>]]
        )
    end)

    it("add new <h2> tag after each selection", function()
        html_tag.add({ tag = "h2", destination = "next", content = "2nd round of insert" })

        assert.equals(2, #selection.nodes())
        h.node_has_text(selection.nodes()[1], "<h2>2nd round of insert</h2>")
        h.node_has_text(selection.nodes()[2], "<h2>2nd round of insert</h2>")

        h.node_has_text(
            selection.nodes()[1]:parent():parent(),
            [[<div className="h-screen w-screen bg-zinc-900">
        <li>Home</li>
        <li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>
        <li>Contacts</li>
        <div>
          <p>testing_1</p>
          <h2>2nd round of insert</h2>
        </div>
        <li>FAQ</li>
        <div>
          <p>testing_1</p>
          <h2>2nd round of insert</h2>
        </div>
        <OtherComponent />
      </div>]]
        )
    end)

    h.clean_up()
end)

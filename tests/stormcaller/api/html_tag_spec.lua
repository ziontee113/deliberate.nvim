require("tests.editor_config")

local ts_utils = require("nvim-treesitter.ts_utils")
local lib_ts_tsx = require("stormcaller.lib.tree-sitter.tsx")

local helpers = require("stormcaller.helpers")
local catalyst = require("stormcaller.lib.catalyst")
local navigator = require("stormcaller.lib.navigator")
local tag = require("stormcaller.api.html_tag")

describe("add()", function()
    before_each(function() helpers.set_buffer_content_as_multiple_react_components() end)
    after_each(function() helpers.clean_up() end)

    it("works for single target (cursor node only), destination = next", function()
        vim.cmd("norm! 22gg^") -- cursor to <li>Contacts</li>

        catalyst.initiate({ win = 0, buf = 0 })
        helpers.assert_catalyst_node_has_text("<li>Contacts</li>")

        tag.add({ tag = "li", destination = "next" })

        -- catalyst node should be updated to newly created node without manual `navigator.move()`
        helpers.assert_catalyst_node_has_text("<li>###</li>")
        helpers.assert_entire_first_line_of_catalyst_node_has_text("        <li>###</li>")
    end)

    it("works for single target (cursor node only), destination = previous", function()
        vim.cmd("norm! 22gg^") -- cursor to <li>Contacts</li>

        catalyst.initiate({ win = 0, buf = 0 })
        helpers.assert_catalyst_node_has_text("<li>Contacts</li>")

        tag.add({ tag = "li", destination = "previous" })

        -- catalyst node should be updated to newly created node without manual `navigator.move()`
        helpers.assert_catalyst_node_has_text("<li>###</li>")
        helpers.assert_entire_first_line_of_catalyst_node_has_text("        <li>###</li>")
    end)

    it("works for single target (cursor node only), destination = inside", function()
        vim.cmd("norm! 22gg^") -- cursor to <li>Contacts</li>

        catalyst.initiate({ win = 0, buf = 0 })
        helpers.assert_catalyst_node_has_text("<li>Contacts</li>")

        tag.add({ tag = "div", destination = "next", content = "" })
        helpers.assert_catalyst_node_has_text("<div></div>")

        tag.add({ tag = "h1", destination = "inside", content = "inside the div" })
        helpers.assert_catalyst_node_has_text("<h1>inside the div</h1>")

        helpers.assert_node_has_text(
            catalyst.node():parent(),
            [[<div>
          <h1>inside the div</h1>
        </div>]]
        )

        tag.add({ tag = "p", destination = "next", content = "Lorem ipsum" })
        helpers.assert_catalyst_node_has_text("<p>Lorem ipsum</p>")

        helpers.assert_node_has_text(
            catalyst.node():parent(),
            [[<div>
          <h1>inside the div</h1>
          <p>Lorem ipsum</p>
        </div>]]
        )
    end)
end)

describe("tag.add() chain testing with destinations `next` & `previous`", function()
    helpers.set_buffer_content_as_multiple_react_components()

    it("Adds new tag after each selected node", function()
        vim.cmd("norm! 22gg^") -- cursor to <li>Contacts</li>

        catalyst.initiate({ win = 0, buf = 0 })
        helpers.assert_catalyst_node_has_text("<li>Contacts</li>")

        navigator.move({ destination = "next", track_selection = true })
        navigator.move({ destination = "next", track_selection = true })

        local selected_nodes = catalyst.selected_nodes()
        assert.equals(2, #selected_nodes)
        helpers.assert_node_has_text(selected_nodes[1], "<li>Contacts</li>")
        helpers.assert_node_has_text(selected_nodes[2], "<li>FAQ</li>")

        tag.add({ tag = "li", destination = "next", content = "first_add" })

        helpers.assert_node_has_text(
            selected_nodes[1]:parent(),
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

        -- check that selection becomes newly added tags
        selected_nodes = catalyst.selected_nodes()
        assert.equals(2, #selected_nodes)
        helpers.assert_node_has_text(selected_nodes[1], "<li>first_add</li>")
        helpers.assert_node_has_text(selected_nodes[2], "<li>first_add</li>")

        -- assure that the catalyst node's cursor auto moves after the buffer change caused by `tag.add()`
        local node_at_cursor = ts_utils.get_node_at_cursor()
        local jsx_node_at_cursor = lib_ts_tsx.get_jsx_node(node_at_cursor)
        helpers.assert_node_has_text(jsx_node_at_cursor, "<OtherComponent />")
    end)

    it("clears current selection, select 2 tags, add new tag after each selection", function()
        catalyst.clear_multi_selection()

        navigator.move({ destination = "previous", track_selection = true }) -- select `OtherComponent` tag

        navigator.move({ destination = "previous" }) -- moves upwards
        navigator.move({ destination = "previous" })
        navigator.move({ destination = "previous" })
        navigator.move({ destination = "previous" })
        navigator.move({ destination = "previous" }) -- up to <li>Home</li>
        navigator.move({ destination = "previous", track_selection = true }) -- and select it

        -- make sure we selected the right stuffs
        local selected_nodes = catalyst.selected_nodes()
        assert.equals(2, #selected_nodes)
        helpers.assert_node_has_text(selected_nodes[1], "<OtherComponent />")
        helpers.assert_node_has_text(selected_nodes[2], "<li>Home</li>")

        -- execute `tag.add()`
        tag.add({ tag = "h1", destination = "next", content = "2nd" })

        selected_nodes = catalyst.selected_nodes()
        helpers.assert_node_has_text(
            selected_nodes[1]:parent(),
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

        helpers.assert_node_has_text(selected_nodes[1], "<h1>2nd</h1>")
        helpers.assert_node_has_text(selected_nodes[2], "<h1>2nd</h1>")
    end)

    it("keeping current selection, add new tag before each selection", function()
        tag.add({ tag = "h3", destination = "previous", content = "third-add-call" })

        local selected_nodes = catalyst.selected_nodes()
        helpers.assert_node_has_text(
            selected_nodes[1]:parent(),
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

        helpers.assert_node_has_text(selected_nodes[1], "<h3>third-add-call</h3>")
        helpers.assert_node_has_text(selected_nodes[2], "<h3>third-add-call</h3>")
    end)

    helpers.clean_up()
end)

describe("tag.add() chain testing with destinations `next` & `previous`", function()
    helpers.set_buffer_content_as_multiple_react_components()

    it("first select 2 li elements, then add empty <div> tag after each selection", function()
        vim.cmd("norm! 22gg^") -- cursor to <li>Contacts</li>

        catalyst.initiate({ win = 0, buf = 0 })
        helpers.assert_catalyst_node_has_text("<li>Contacts</li>")

        navigator.move({ destination = "next", track_selection = true })
        navigator.move({ destination = "next", track_selection = true })

        local selected_nodes = catalyst.selected_nodes()
        assert.equals(2, #selected_nodes)
        helpers.assert_node_has_text(selected_nodes[1], "<li>Contacts</li>")
        helpers.assert_node_has_text(selected_nodes[2], "<li>FAQ</li>")

        tag.add({ tag = "div", destination = "next", content = "" })

        helpers.assert_node_has_text(
            selected_nodes[1]:parent(),
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
        selected_nodes = catalyst.selected_nodes()
        assert.equals(2, #selected_nodes)
        helpers.assert_node_has_text(selected_nodes[1], "<div></div>")
        helpers.assert_node_has_text(selected_nodes[2], "<div></div>")

        -- assure that the catalyst node's cursor auto moves after the buffer change caused by `tag.add()`
        local node_at_cursor = ts_utils.get_node_at_cursor()
        local jsx_node_at_cursor = lib_ts_tsx.get_jsx_node(node_at_cursor)
        helpers.assert_node_has_text(jsx_node_at_cursor, "<OtherComponent />")
    end)

    it("adds new <p> tag inside each selection", function()
        tag.add({ tag = "p", destination = "inside", content = "testing_1" })

        local selected_nodes = catalyst.selected_nodes()
        assert.equals(2, #selected_nodes)
        helpers.assert_node_has_text(selected_nodes[1], "<p>testing_1</p>")
        helpers.assert_node_has_text(selected_nodes[2], "<p>testing_1</p>")

        helpers.assert_node_has_text(
            selected_nodes[1]:parent():parent(),
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
        tag.add({ tag = "h2", destination = "next", content = "2nd round of insert" })

        local selected_nodes = catalyst.selected_nodes()
        assert.equals(2, #selected_nodes)
        helpers.assert_node_has_text(selected_nodes[1], "<h2>2nd round of insert</h2>")
        helpers.assert_node_has_text(selected_nodes[2], "<h2>2nd round of insert</h2>")

        helpers.assert_node_has_text(
            selected_nodes[1]:parent():parent(),
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

    helpers.clean_up()
end)

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

        tag.add("li", "next")

        -- catalyst node should be updated to newly created node without manual `navigator.move()`
        helpers.assert_catalyst_node_has_text("<li>###</li>")
        helpers.assert_entire_first_line_of_catalyst_node_has_text("        <li>###</li>")
    end)

    it("works for single target (cursor node only), destination = previous", function()
        vim.cmd("norm! 22gg^") -- cursor to <li>Contacts</li>

        catalyst.initiate({ win = 0, buf = 0 })
        helpers.assert_catalyst_node_has_text("<li>Contacts</li>")

        tag.add("li", "previous")

        -- catalyst node should be updated to newly created node without manual `navigator.move()`
        helpers.assert_catalyst_node_has_text("<li>###</li>")
        helpers.assert_entire_first_line_of_catalyst_node_has_text("        <li>###</li>")
    end)

    it("works for multi selection", function()
        vim.cmd("norm! 22gg^") -- cursor to <li>Contacts</li>

        catalyst.initiate({ win = 0, buf = 0 })
        helpers.assert_catalyst_node_has_text("<li>Contacts</li>")

        navigator.move({ destination = "next", track_selection = true })
        navigator.move({ destination = "next", track_selection = true })

        local selected_nodes = catalyst.selected_nodes()
        assert.equals(2, #selected_nodes)
        helpers.assert_node_has_text(selected_nodes[1], "<li>Contacts</li>")
        helpers.assert_node_has_text(selected_nodes[2], "<li>FAQ</li>")

        tag.add("li", "next")

        helpers.assert_node_has_text(
            selected_nodes[1]:parent(),
            [[<div className="h-screen w-screen bg-zinc-900">
        <li>Home</li>
        <li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>
        <li>Contacts</li>
        <li>###</li>
        <li>FAQ</li>
        <li>###</li>
        <OtherComponent />
      </div>]]
        )

        -- check that selection becomes newly added tags
        selected_nodes = catalyst.selected_nodes()
        assert.equals(2, #selected_nodes)
        helpers.assert_node_has_text(selected_nodes[1], "<li>###</li>")
        helpers.assert_node_has_text(selected_nodes[2], "<li>###</li>")

        -- assure that the catalyst node's cursor auto moves after the buffer change caused by `tag.add()`
        local node_at_cursor = ts_utils.get_node_at_cursor()
        local jsx_node_at_cursor = lib_ts_tsx.get_jsx_node(node_at_cursor)
        helpers.assert_node_has_text(jsx_node_at_cursor, "<OtherComponent />")

        -- clear multi selection, intent to select a few different tags, then use `tag.add()`
        catalyst.clear_multi_selection()

        navigator.move({ destination = "previous", track_selection = true }) -- select `OtherComponent` tag

        navigator.move({ destination = "previous" }) -- moves upwards
        navigator.move({ destination = "previous" })
        navigator.move({ destination = "previous" })
        navigator.move({ destination = "previous" })
        navigator.move({ destination = "previous" }) -- up to <li>Home</li>
        navigator.move({ destination = "previous", track_selection = true }) -- and select it

        -- make sure we selected the right stuffs
        selected_nodes = catalyst.selected_nodes()
        assert.equals(2, #selected_nodes)
        helpers.assert_node_has_text(selected_nodes[1], "<OtherComponent />")
        helpers.assert_node_has_text(selected_nodes[2], "<li>Home</li>")

        -- execute `tag.add()`
        tag.add("h1", "next")

        selected_nodes = catalyst.selected_nodes()
        helpers.assert_node_has_text(
            selected_nodes[1]:parent(),
            [[<div className="h-screen w-screen bg-zinc-900">
        <li>Home</li>
        <h1>###</h1>
        <li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>
        <li>Contacts</li>
        <li>###</li>
        <li>FAQ</li>
        <li>###</li>
        <OtherComponent />
        <h1>###</h1>
      </div>]]
        )

        helpers.assert_node_has_text(selected_nodes[1], "<h1>###</h1>")
        helpers.assert_node_has_text(selected_nodes[2], "<h1>###</h1>")

        -- execute `tag.add()` with destination = "previous"
        tag.add("h3", "previous")

        selected_nodes = catalyst.selected_nodes()
        helpers.assert_node_has_text(
            selected_nodes[1]:parent(),
            [[<div className="h-screen w-screen bg-zinc-900">
        <li>Home</li>
        <h3>###</h3>
        <h1>###</h1>
        <li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>
        <li>Contacts</li>
        <li>###</li>
        <li>FAQ</li>
        <li>###</li>
        <OtherComponent />
        <h3>###</h3>
        <h1>###</h1>
      </div>]]
        )

        helpers.assert_node_has_text(selected_nodes[1], "<h3>###</h3>")
        helpers.assert_node_has_text(selected_nodes[2], "<h3>###</h3>")
    end)
end)

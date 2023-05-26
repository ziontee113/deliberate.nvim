require("tests.editor_config")

local catalyst = require("stormcaller.lib.catalyst")
local selection = require("stormcaller.lib.selection")
local navigator = require("stormcaller.api.navigator")
local helpers = require("stormcaller.helpers")

local initiate = function(cmd, wanted_text, assert_fn)
    vim.cmd(string.format("norm! %s", cmd))
    catalyst.initiate({ win = 0, buf = 0 })
    assert_fn = assert_fn or helpers.assert_catalyst_node_has_text
    assert_fn(wanted_text)
end

local move = function(destination, wanted_text, position, assert_fn)
    navigator.move({ destination = destination })
    assert_fn = assert_fn or helpers.assert_catalyst_node_has_text
    assert_fn(wanted_text)
    assert.are.same(position, vim.api.nvim_win_get_cursor(0))
end

local long_li_tag = [[<li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>]]

describe("typescriptreact navigator.move()", function()
    before_each(function() helpers.set_buffer_content_as_multiple_react_components() end)
    after_each(function() helpers.clean_up() end)

    it("direction = next-sibling", function()
        initiate("17gg^", "<li>Home</li>")
        move("next-sibling", long_li_tag, { 18, 8 })
        move("next-sibling", "<li>Contacts</li>", { 22, 8 })
        move("next-sibling", "<li>FAQ</li>", { 23, 8 })
        move("next-sibling", "<OtherComponent />", { 24, 8 })
        move("next-sibling", "<OtherComponent />", { 24, 8 }) -- stays in place since no next siblings
    end)

    it("direction = previous-sibling", function()
        initiate("23gg^", "<li>FAQ</li>")
        move("previous-sibling", "<li>Contacts</li>", { 22, 8 })
        move("previous-sibling", long_li_tag, { 21, 12 }) -- put cursor at end of tag since we're moving up and target start and end not on same line
        move("previous-sibling", "<li>Home</li>", { 17, 8 })
        move("previous-sibling", "<li>Home</li>", { 17, 8 }) -- stays in place since no more prevous sibling
    end)

    it("direction = next", function()
        initiate(
            "16gg",
            '<div className="h-screen w-screen bg-zinc-900">',
            helpers.assert_first_line_of_catalyst_node_has_text
        )

        move("next", "<li>Home</li>", { 17, 8 })
        move("next", long_li_tag, { 18, 8 })
        move("next", "<li>Contacts</li>", { 22, 8 })
        move("next", "<li>FAQ</li>", { 23, 8 })
        move("next", "<OtherComponent />", { 24, 8 })
        move("next", "      </div>", { 25, 11 }, helpers.assert_last_line_of_catalyst_node_has_text)
        move("next", "    </>", { 26, 6 }, helpers.assert_last_line_of_catalyst_node_has_text)
        move("next", "<div>", { 34, 4 }, helpers.assert_first_line_of_catalyst_node_has_text) --> should jump to next html Component
        move("next", "<ul>", { 35, 6 }, helpers.assert_first_line_of_catalyst_node_has_text)
    end)

    it("direction = previous", function()
        initiate("22gg^", "<li>Contacts</li>")
        move("previous", long_li_tag, { 21, 12 })
        move("previous", "<li>Home</li>", { 17, 8 })
        move(
            "previous",
            '<div className="h-screen w-screen bg-zinc-900">',
            { 16, 6 },
            helpers.assert_first_line_of_catalyst_node_has_text
        )
        move("previous", "<>", { 15, 4 }, helpers.assert_first_line_of_catalyst_node_has_text)
        move("previous", "    </p>", { 6, 7 }, helpers.assert_last_line_of_catalyst_node_has_text)
    end)

    it("direction = parent", function()
        initiate("22gg^", "<li>Contacts</li>")
        move(
            "parent",
            '<div className="h-screen w-screen bg-zinc-900">',
            { 16, 6 },
            helpers.assert_first_line_of_catalyst_node_has_text
        )
        move("parent", "<>", { 15, 4 }, helpers.assert_first_line_of_catalyst_node_has_text)
        move("parent", "<>", { 15, 4 }, helpers.assert_first_line_of_catalyst_node_has_text) -- stands still since no more html parent from here
    end)
end)

describe("navigator.move() with `select_move` option", function()
    before_each(function() helpers.set_buffer_content_as_multiple_react_components() end)
    after_each(function() helpers.clean_up() end)

    it("update `selected_nodes` correctly without using `select_move` option", function()
        vim.cmd("norm! 17gg^") -- cursor to start of 1st <li> tag

        -- inititation
        catalyst.initiate({ win = 0, buf = 0 })

        assert.equals(#selection.nodes(), 1)
        helpers.assert_node_has_text(selection.nodes()[1], "<li>Home</li>")

        -- 1st move
        navigator.move({ destination = "next" })

        assert.equals(#selection.nodes(), 1)

        helpers.assert_node_has_text(
            selection.nodes()[1],
            [[<li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>]]
        )

        -- 2nd move
        navigator.move({ destination = "next" })

        assert.equals(#selection.nodes(), 1)

        helpers.assert_node_has_text(selection.nodes()[1], "<li>Contacts</li>")

        -- 3rd move
        navigator.move({ destination = "next" })

        assert.equals(#selection.nodes(), 1)

        helpers.assert_node_has_text(selection.nodes()[1], "<li>FAQ</li>")
    end)

    it("update `selection.nodes()` correctly with `select_move` option used", function()
        vim.cmd("norm! 17gg^") -- cursor to start of 1st <li> tag

        -- inititation
        catalyst.initiate({ win = 0, buf = 0 })

        assert.equals(#selection.nodes(), 1)
        helpers.assert_node_has_text(selection.nodes()[1], "<li>Home</li>")

        -- 1st move: "next" destination, with NO select_move, cursor moves to the next node, but `selection.nodes()` stays the same
        navigator.move({ destination = "next", select_move = true })

        helpers.assert_catalyst_node_has_text([[<li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>]])

        assert.equals(#selection.nodes(), 1)
        helpers.assert_node_has_text(selection.nodes()[1], "<li>Home</li>")

        -- 2nd move: "next" destination, with NO select_move, cursor moves to the next node, but `selection.nodes()` stays the same
        -- cursor moves to the node, but does not add it to the `selection.nodes()` table.
        navigator.move({ destination = "next" })

        helpers.assert_catalyst_node_has_text("<li>Contacts</li>")

        assert.equals(#selection.nodes(), 1)
        helpers.assert_node_has_text(selection.nodes()[1], "<li>Home</li>")

        -- 3rd move: "next" destination, with select_move, node on cursor gets added to `selection.nodes()`,
        -- then cursor moves to next node.
        navigator.move({ destination = "next", select_move = true })

        assert.equals(#selection.nodes(), 2)

        helpers.assert_node_has_text(selection.nodes()[1], "<li>Home</li>")
        helpers.assert_node_has_text(selection.nodes()[2], "<li>Contacts</li>")

        -- 4th move: with tracking
        navigator.move({ destination = "next", select_move = true })

        assert.equals(#selection.nodes(), 3)

        helpers.assert_node_has_text(selection.nodes()[1], "<li>Home</li>")
        helpers.assert_node_has_text(selection.nodes()[2], "<li>Contacts</li>")
        helpers.assert_node_has_text(selection.nodes()[3], "<li>FAQ</li>")
    end)
end)

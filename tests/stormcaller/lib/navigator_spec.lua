local catalyst = require("stormcaller.lib.catalyst")
local navigator = require("stormcaller.lib.navigator")
local helpers = require("stormcaller.helpers")

describe("navigator.move()", function()
    before_each(function() helpers.set_buffer_content_as_multiple_react_components() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)

    it("direction = next-sibling", function()
        vim.cmd("norm! 17gg^") -- cursor to start of 1st <li> tag

        catalyst.initiate({ win = 0, buf = 0 })
        helpers.assert_catalyst_node_has_text("<li>Home</li>")

        -- 1st move
        navigator.move({ destination = "next-sibling" })
        helpers.assert_catalyst_node_has_text([[<li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>]])

        local cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 18, 8 }, cursor_positon)

        -- 2nd move
        navigator.move({ destination = "next-sibling" })
        helpers.assert_catalyst_node_has_text("<li>Contacts</li>")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 22, 8 }, cursor_positon)

        -- 3rd move
        navigator.move({ destination = "next-sibling" })
        helpers.assert_catalyst_node_has_text("<li>FAQ</li>")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 23, 8 }, cursor_positon)

        -- 4th move
        navigator.move({ destination = "next-sibling" })
        helpers.assert_catalyst_node_has_text("<OtherComponent />")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 24, 8 }, cursor_positon)

        -- 5th move, should stay in place since no next siblings
        navigator.move({ destination = "next-sibling" })
        helpers.assert_catalyst_node_has_text("<OtherComponent />")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 24, 8 }, cursor_positon)
    end)

    it("direction = previous-sibling", function()
        vim.cmd("norm! 23gg^")

        catalyst.initiate({ win = 0, buf = 0 })
        helpers.assert_catalyst_node_has_text("<li>FAQ</li>")

        -- 1st move up
        navigator.move({ destination = "previous-sibling" })
        helpers.assert_catalyst_node_has_text("<li>Contacts</li>")

        local cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 22, 8 }, cursor_positon)

        -- 2nd move up, should put cursor at end of tag since we're moving up
        -- and target start and end not on same line.
        navigator.move({ destination = "previous-sibling" })
        helpers.assert_catalyst_node_has_text([[<li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>]])

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 21, 12 }, cursor_positon)

        -- 3rd move up
        navigator.move({ destination = "previous-sibling" })
        helpers.assert_catalyst_node_has_text("<li>Home</li>")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 17, 8 }, cursor_positon)

        -- 4th move up, should stay in place since no more prevous sibling
        navigator.move({ destination = "previous-sibling" })
        helpers.assert_catalyst_node_has_text("<li>Home</li>")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 17, 8 }, cursor_positon)
    end)

    it("direction = next", function()
        vim.cmd("norm! 16gg^") -- cursor to start of <div> tag

        catalyst.initiate({ win = 0, buf = 0 })
        helpers.assert_first_line_of_catalyst_node_has_text(
            [[<div className="h-screen w-screen bg-zinc-900">]]
        )

        -- 1st move
        navigator.move({ destination = "next" })
        helpers.assert_catalyst_node_has_text("<li>Home</li>")

        local cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 17, 8 }, cursor_positon)

        -- 2nd move
        navigator.move({ destination = "next" })
        helpers.assert_catalyst_node_has_text([[<li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>]])

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 18, 8 }, cursor_positon)

        -- 3rd move
        navigator.move({ destination = "next" })
        helpers.assert_catalyst_node_has_text("<li>Contacts</li>")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 22, 8 }, cursor_positon)

        -- 5th move
        navigator.move({ destination = "next" })
        navigator.move({ destination = "next" })

        helpers.assert_catalyst_node_has_text("<OtherComponent />")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 24, 8 }, cursor_positon)

        -- 6th move
        navigator.move({ destination = "next" })
        helpers.assert_last_line_of_catalyst_node_has_text("      </div>")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 25, 11 }, cursor_positon)

        -- 7th move
        navigator.move({ destination = "next" })
        helpers.assert_last_line_of_catalyst_node_has_text("    </>")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 26, 6 }, cursor_positon)

        -- 8th move --> should jump to next jsx Component
        navigator.move({ destination = "next" })
        helpers.assert_first_line_of_catalyst_node_has_text("<div>")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 34, 4 }, cursor_positon)

        -- 9th move
        navigator.move({ destination = "next" })
        helpers.assert_first_line_of_catalyst_node_has_text("<ul>")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 35, 6 }, cursor_positon)
    end)

    it("direction = previous", function()
        vim.cmd("norm! 22gg^") -- cursor to start 3rd <li> tag

        catalyst.initiate({ win = 0, buf = 0 })
        helpers.assert_catalyst_node_has_text("<li>Contacts</li>")

        -- 1st move
        navigator.move({ destination = "previous" })
        helpers.assert_catalyst_node_has_text([[<li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>]])

        local cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 21, 12 }, cursor_positon)

        -- 2nd move
        navigator.move({ destination = "previous" })
        helpers.assert_catalyst_node_has_text("<li>Home</li>")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 17, 8 }, cursor_positon)

        -- 3rd move
        navigator.move({ destination = "previous" })
        helpers.assert_first_line_of_catalyst_node_has_text(
            [[<div className="h-screen w-screen bg-zinc-900">]]
        )

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 16, 6 }, cursor_positon)

        -- 4th move
        navigator.move({ destination = "previous" })
        helpers.assert_first_line_of_catalyst_node_has_text("<>")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 15, 4 }, cursor_positon)

        -- 5th move
        navigator.move({ destination = "previous" })
        helpers.assert_last_line_of_catalyst_node_has_text("    </p>")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 6, 7 }, cursor_positon)
    end)

    it("direction = parent", function()
        vim.cmd("norm! 22gg^") -- cursor to start 3rd <li> tag

        catalyst.initiate({ win = 0, buf = 0 })
        helpers.assert_catalyst_node_has_text("<li>Contacts</li>")

        -- 1st move
        navigator.move({ destination = "parent" })
        helpers.assert_first_line_of_catalyst_node_has_text(
            [[<div className="h-screen w-screen bg-zinc-900">]]
        )

        local cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 16, 6 }, cursor_positon)

        -- 2nd move
        navigator.move({ destination = "parent" })
        helpers.assert_first_line_of_catalyst_node_has_text("<>")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 15, 4 }, cursor_positon)

        -- 3rd move, should stand still since no more jsx parent from here
        navigator.move({ destination = "parent" })
        helpers.assert_first_line_of_catalyst_node_has_text("<>")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 15, 4 }, cursor_positon)
    end)
end)

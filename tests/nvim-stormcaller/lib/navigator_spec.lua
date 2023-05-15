local navigator = require("nvim-stormcaller.lib.navigator")
local helpers = require("nvim-stormcaller.helpers")

local set_buffer_content_as_multiple_react_components = function()
    vim.bo.ft = "typescriptreact"
    helpers.set_buf_content([[
function OtherComponent() {
  return (
    <p>
      Astronauts in space can grow up to 2 inches taller due to the lack of
      gravity.
    </p>
  )
}

let x = 10;
let y = 100;

export default function Home() {
  return (
    <>
      <div className="h-screen w-screen bg-zinc-900">
        <li>Home</li>
        <li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>
        <li>Contacts</li>
        <li>FAQ</li>
        <OtherComponent />
      </div>
    </>
  )
}

let str = "just a random string";

function OtherOtherComponent() {
  return (
    <div>
      <ul>
        <li>Log In</li>
        <li>Sign Up</li>
      </ul>
    </div>
  )
}]])
end

describe("navigator.initiate()", function()
    before_each(function() vim.bo.ft = "typescriptreact" end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)

    it("puts cursor at start of closest tag, with initial cursor inside jsx_element", function()
        helpers.set_buf_content([[
export default function Home() {
  return (
    <>
      <div className="h-screen w-screen bg-zinc-900">
        <li>Home</li>
        <li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>
        <li>Contacts</li>
        <li>FAQ</li>
      </div>
    </>
  )
}]])

        vim.cmd("norm! 7gg0ff") -- put cursor at line 7: A new study [f]ound that

        navigator.initiate({ win = 0, buf = 0 }) -- should put cursor at line 6: [<]li>

        local cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 6, 8 }, cursor_positon)
    end)

    it(
        "puts cursor at start of closest tag, with initial cursor outside and above jsx_element",
        function()
            helpers.set_buf_content([[
export default function Home() {
  return (
    <>
      <div className="h-screen w-screen bg-zinc-900">
        <li>Home</li>
        <li>About</li>
        <li>Contacts</li>
        <li>FAQ</li>
      </div>
    </>
  )
}]])

            vim.cmd("norm! gg0") -- put cursor at line 1: {e}xport default ...

            navigator.initiate({ win = 0, buf = 0 }) -- should put cursor at line 3: [<]>

            local cursor_positon = vim.api.nvim_win_get_cursor(0)
            assert.are.same({ 3, 4 }, cursor_positon)
        end
    )

    it(
        "puts cursor at end of closest tag, with initial cursor outside and below jsx_element",
        function()
            helpers.set_buf_content([[
export default function Home() {
  return (
    <>
      <div className="h-screen w-screen bg-zinc-900">
        <li>Home</li>
        <li>About</li>
        <li>Contacts</li>
        <li>FAQ</li>
      </div>
    </>
  )
}]])

            vim.cmd("norm! G0") -- put cursor at start of last line: [}]

            navigator.initiate({ win = 0, buf = 0 }) -- should put cursor at line 10: </[>]

            local cursor_positon = vim.api.nvim_win_get_cursor(0)
            assert.are.same({ 10, 6 }, cursor_positon)
        end
    )

    it(
        [[puts cursor at end of closest jsx_element
because initial cursor was sandwiched between jsx_elements and was below closest jsx_element ]],
        function()
            set_buffer_content_as_multiple_react_components()
            vim.cmd("norm! 8gg0")

            navigator.initiate({ win = 0, buf = 0 })

            local cursor_positon = vim.api.nvim_win_get_cursor(0)
            assert.are.same({ 6, 7 }, cursor_positon)
        end
    )

    it(
        [[puts cursor at start of closest jsx_element
because initial cursor was sandwiched between jsx_elements and was above closest jsx_element ]],
        function()
            set_buffer_content_as_multiple_react_components()
            vim.cmd("norm! 12gg0")

            navigator.initiate({ win = 0, buf = 0 })

            local cursor_positon = vim.api.nvim_win_get_cursor(0)
            assert.are.same({ 15, 4 }, cursor_positon)
        end
    )
end)

describe("navigator.move()", function()
    before_each(function() set_buffer_content_as_multiple_react_components() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)

    it("direction = next-sibling", function()
        vim.cmd("norm! 17gg^") -- cursor to start of 1st <li> tag

        navigator.initiate({ win = 0, buf = 0 })
        helpers.assert_cursor_node_has_text("<li>Home</li>")

        -- 1st move
        navigator.move({ win = 0, buf = 0, destination = "next-sibling" })
        helpers.assert_cursor_node_has_text([[<li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>]])

        local cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 18, 8 }, cursor_positon)

        -- 2nd move
        navigator.move({ win = 0, buf = 0, destination = "next-sibling" })
        helpers.assert_cursor_node_has_text("<li>Contacts</li>")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 22, 8 }, cursor_positon)

        -- 3rd move
        navigator.move({ win = 0, buf = 0, destination = "next-sibling" })
        helpers.assert_cursor_node_has_text("<li>FAQ</li>")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 23, 8 }, cursor_positon)

        -- 4th move
        navigator.move({ win = 0, buf = 0, destination = "next-sibling" })
        helpers.assert_cursor_node_has_text("<OtherComponent />")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 24, 8 }, cursor_positon)

        -- 5th move, should stay in place since no next siblings
        navigator.move({ win = 0, buf = 0, destination = "next-sibling" })
        helpers.assert_cursor_node_has_text("<OtherComponent />")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 24, 8 }, cursor_positon)
    end)

    it("direction = previous-sibling", function()
        vim.cmd("norm! 23gg^")

        navigator.initiate({ win = 0, buf = 0 })
        helpers.assert_cursor_node_has_text("<li>FAQ</li>")

        -- 1st move up
        navigator.move({ win = 0, buf = 0, destination = "previous-sibling" })
        helpers.assert_cursor_node_has_text("<li>Contacts</li>")

        local cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 22, 8 }, cursor_positon)

        -- 2nd move up, should put cursor at end of tag since we're moving up
        -- and target start and end not on same line.
        navigator.move({ win = 0, buf = 0, destination = "previous-sibling" })
        helpers.assert_cursor_node_has_text([[<li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>]])

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 21, 12 }, cursor_positon)

        -- 3rd move up
        navigator.move({ win = 0, buf = 0, destination = "previous-sibling" })
        helpers.assert_cursor_node_has_text("<li>Home</li>")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 17, 8 }, cursor_positon)

        -- 4th move up, should stay in place since no more prevous sibling
        navigator.move({ win = 0, buf = 0, destination = "previous-sibling" })
        helpers.assert_cursor_node_has_text("<li>Home</li>")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 17, 8 }, cursor_positon)
    end)

    it("direction = next", function()
        vim.cmd("norm! 16gg^") -- cursor to start of <div> tag

        navigator.initiate({ win = 0, buf = 0 })
        helpers.assert_first_line_of_node_has_text(
            [[<div className="h-screen w-screen bg-zinc-900">]]
        )

        -- 1st move
        navigator.move({ win = 0, buf = 0, destination = "next" })
        helpers.assert_cursor_node_has_text("<li>Home</li>")

        local cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 17, 8 }, cursor_positon)

        -- 2nd move
        navigator.move({ win = 0, buf = 0, destination = "next" })
        helpers.assert_cursor_node_has_text([[<li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>]])

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 18, 8 }, cursor_positon)

        -- 3rd move
        navigator.move({ win = 0, buf = 0, destination = "next" })
        helpers.assert_cursor_node_has_text("<li>Contacts</li>")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 22, 8 }, cursor_positon)

        -- 5th move
        navigator.move({ win = 0, buf = 0, destination = "next" })
        navigator.move({ win = 0, buf = 0, destination = "next" })

        helpers.assert_cursor_node_has_text("<OtherComponent />")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 24, 8 }, cursor_positon)

        -- 6th move
        navigator.move({ win = 0, buf = 0, destination = "next" })
        helpers.assert_last_line_of_node_has_text("      </div>")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 25, 11 }, cursor_positon)

        -- 7th move
        navigator.move({ win = 0, buf = 0, destination = "next" })
        helpers.assert_last_line_of_node_has_text("    </>")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 26, 6 }, cursor_positon)

        -- 8th move --> should jump to next jsx Component
        navigator.move({ win = 0, buf = 0, destination = "next" })
        helpers.assert_first_line_of_node_has_text("<div>")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 34, 4 }, cursor_positon)

        -- 9th move
        navigator.move({ win = 0, buf = 0, destination = "next" })
        helpers.assert_first_line_of_node_has_text("<ul>")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 35, 6 }, cursor_positon)
    end)

    it("direction = previous", function()
        vim.cmd("norm! 22gg^") -- cursor to start 3rd <li> tag

        navigator.initiate({ win = 0, buf = 0 })
        helpers.assert_cursor_node_has_text("<li>Contacts</li>")

        -- 1st move
        navigator.move({ win = 0, buf = 0, destination = "previous" })
        helpers.assert_cursor_node_has_text([[<li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>]])

        local cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 21, 12 }, cursor_positon)

        -- 2nd move
        navigator.move({ win = 0, buf = 0, destination = "previous" })
        helpers.assert_cursor_node_has_text("<li>Home</li>")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 17, 8 }, cursor_positon)

        -- 3rd move
        navigator.move({ win = 0, buf = 0, destination = "previous" })
        helpers.assert_first_line_of_node_has_text(
            [[<div className="h-screen w-screen bg-zinc-900">]]
        )

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 16, 6 }, cursor_positon)

        -- 4th move
        navigator.move({ win = 0, buf = 0, destination = "previous" })
        helpers.assert_first_line_of_node_has_text("<>")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 15, 4 }, cursor_positon)

        -- 5th move
        navigator.move({ win = 0, buf = 0, destination = "previous" })
        helpers.assert_last_line_of_node_has_text("    </p>")

        cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 6, 7 }, cursor_positon)
    end)
end)

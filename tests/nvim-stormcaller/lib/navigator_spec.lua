local navigator = require("nvim-stormcaller.lib.navigator")
local helpers = require("nvim-stormcaller.helpers")

describe("navigator.initiate()", function()
    before_each(function()
        vim.bo.ft = "typescriptreact"
    end)
    after_each(function()
        vim.api.nvim_buf_delete(0, { force = true }) -- delete buffer after the test
    end)

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

        navigator.initiate({ win = 0 }) -- should put cursor at line 6: [<]li>

        local cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 6, 9 }, cursor_positon)
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

            navigator.initiate({ win = 0 }) -- should put cursor at line 4: [<]div className="h-screen...

            local cursor_positon = vim.api.nvim_win_get_cursor(0)
            assert.are.same({ 3, 5 }, cursor_positon)
        end
    )
end)

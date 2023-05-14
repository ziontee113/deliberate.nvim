local navigator = require("nvim-stormcaller.lib.navigator")
local helpers = require("nvim-stormcaller.helpers")

describe("navigator.initiate()", function()
    before_each(function()
        vim.bo.ft = "typescriptreact"
    end)
    after_each(function()
        vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
    end)

    it("puts cursor at start of closest tag (content on same line)", function()
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

        vim.cmd("norm! 6gg0fH") -- put cursor at <li>[A]bout</li>

        navigator.initiate() -- should put cursor at [<]li>About</li>

        local cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 6, 8 }, cursor_positon)
    end)

    it("puts cursor at start of closest tag (content on multiple lines)", function()
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

        navigator.initiate() -- should put cursor at line 6: [<]li>

        local cursor_positon = vim.api.nvim_win_get_cursor(0)
        assert.are.same({ 6, 8 }, cursor_positon)
    end)
end)

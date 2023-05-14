local ts_utils = require("nvim-treesitter.ts_utils")
local lib_ts = require("nvim-stormcaller.lib.tree-sitter")
local helpers = require("nvim-stormcaller.helpers")

describe("lib_ts.find_nearest_parent_of_types()", function()
    before_each(function()
        vim.bo.ft = "typescriptreact"
    end)
    after_each(function()
        vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
    end)

    it("works", function()
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

        local node = ts_utils.get_node_at_cursor(0)
        local parent = lib_ts.find_closest_parent_with_types({
            node = node,
            desired_parent_types = { "jsx_element", "jsx_self_closing_element" },
        })

        local parent_text = vim.treesitter.get_node_text(parent, 0)
        assert.equals(
            [[
<li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>]],
            parent_text
        )
    end)
end)

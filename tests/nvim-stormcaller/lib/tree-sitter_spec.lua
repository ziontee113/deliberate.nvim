local ts_utils = require("nvim-treesitter.ts_utils")
local lib_ts = require("nvim-stormcaller.lib.tree-sitter")
local helpers = require("nvim-stormcaller.helpers")

local set_buffer_content_as_react_component = function()
    vim.bo.ft = "typescriptreact"
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
end

describe("find_nearest_parent_of_types()", function()
    it("returns closest parent node that has one of the `desired_parent_types`", function()
        set_buffer_content_as_react_component()
        vim.cmd("norm! 7gg0ff") -- put cursor at line 7: A new study [f]ound that

        local current_node = ts_utils.get_node_at_cursor(0)
        local parent = lib_ts.find_closest_parent_with_types({
            node = current_node,
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

        vim.api.nvim_buf_delete(0, { force = true }) -- delete buffer after the test
    end)
end)

describe("put_cursor_at_node()", function()
    it("works", function()
        set_buffer_content_as_react_component()
        vim.cmd("norm! 7gg0ff") -- put cursor at line 7: A new study [f]ound that

        local current_node = ts_utils.get_node_at_cursor(0)
        local parent = lib_ts.find_closest_parent_with_types({
            node = current_node,
            desired_parent_types = { "jsx_element", "jsx_self_closing_element" },
        })

        lib_ts.put_cursor_at_start_of_node({ node = parent, win = 0 })
        local cursor_pos = vim.api.nvim_win_get_cursor(0)
        assert.same({ 6, 8 }, cursor_pos)

        vim.api.nvim_buf_delete(0, { force = true }) -- delete buffer after the test
    end)
end)

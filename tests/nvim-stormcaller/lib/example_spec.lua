local helpers = require("nvim-stormcaller.helpers")
local example_module = require("nvim-stormcaller.lib.example")

describe("example_module.example()", function()
    it("returns 2", function()
        local want = 2
        local got = example_module.example()
        assert.equals(want, got)
    end)
end)

describe("get nodes with Treesitter", function()
    before_each(function()
        vim.o.ft = "typescriptreact"
    end)

    it("works", function()
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

        vim.cmd("norm! 5gg^")

        local ts_utils = require("nvim-treesitter.ts_utils")

        local node = ts_utils.get_node_at_cursor()
        local node_text = vim.treesitter.get_node_text(node, 0)
        assert.equals("<li>", node_text)

        local jsx_node_text = vim.treesitter.get_node_text(node:parent(), 0)
        assert.equals("<li>Home</li>", jsx_node_text)
    end)
end)

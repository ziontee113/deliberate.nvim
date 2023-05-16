local M = {}

M.set_buf_content = function(content)
    if type(content) == "string" then content = vim.split(content, "\n") end
    vim.api.nvim_buf_set_lines(0, 0, -1, false, content)
end

M.assert_cursor_node_has_text = function(want)
    local cursor_node = require("nvim-stormcaller.lib.navigator").get_catalyst()
    local cursor_node_text = vim.treesitter.get_node_text(cursor_node.node, cursor_node.buf)
    assert.equals(want, cursor_node_text)
end

M.assert_first_line_of_node_has_text = function(want)
    local cursor_node = require("nvim-stormcaller.lib.navigator").get_catalyst()
    local cursor_node_text = vim.treesitter.get_node_text(cursor_node.node, cursor_node.buf)
    assert.equals(want, vim.split(cursor_node_text, "\n")[1])
end
M.assert_last_line_of_node_has_text = function(want)
    local cursor_node = require("nvim-stormcaller.lib.navigator").get_catalyst()
    local cursor_node_text = vim.treesitter.get_node_text(cursor_node.node, cursor_node.buf)
    local split = vim.split(cursor_node_text, "\n")
    assert.equals(want, split[#split])
end

M.set_buffer_content_as_multiple_react_components = function()
    vim.bo.ft = "typescriptreact"
    M.set_buf_content([[
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

return M

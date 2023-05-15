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
    it("returns given node if it's type is one of the `desired_parent_types`", function()
        set_buffer_content_as_react_component()
        vim.cmd("norm! 6gg^") -- put cursor at line 7: A new study [f]ound that

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
    after_each(function()
        vim.api.nvim_buf_delete(0, { force = true }) -- delete buffer after the test
    end)

    it("destination == start", function()
        set_buffer_content_as_react_component()
        vim.cmd("norm! 7gg0ff") -- put cursor at line 7: A new study [f]ound that

        local current_node = ts_utils.get_node_at_cursor(0)
        local parent = lib_ts.find_closest_parent_with_types({
            node = current_node,
            desired_parent_types = { "jsx_element", "jsx_self_closing_element" },
        })

        lib_ts.put_cursor_at_node({ destination = "start", node = parent, win = 0 })
        local cursor_pos = vim.api.nvim_win_get_cursor(0)
        assert.same({ 6, 8 }, cursor_pos)
    end)

    it("destination == end", function()
        set_buffer_content_as_react_component()
        vim.cmd("norm! 7gg0ff") -- put cursor at line 7: A new study [f]ound that

        local current_node = ts_utils.get_node_at_cursor(0)
        local parent = lib_ts.find_closest_parent_with_types({
            node = current_node,
            desired_parent_types = { "jsx_element", "jsx_self_closing_element" },
        })

        lib_ts.put_cursor_at_node({ destination = "end", node = parent, win = 0 })
        local cursor_pos = vim.api.nvim_win_get_cursor(0)
        assert.same({ 9, 12 }, cursor_pos)
    end)
end)

describe("capture_nodes_with_queries()", function()
    it("returns a tuple of { all_captures, grouped_captures }", function()
        set_buffer_content_as_react_component()

        local all_captures, grouped_captures = lib_ts.capture_nodes_with_queries({
            buf = 0,
            parser_name = "tsx",
            queries = {
                "(jsx_fragment) @jsx_fragment",
                "(jsx_element) @jsx_element",
                "(jsx_self_closing_element) @jsx_self_closing_element",
            },
            capture_groups = { "jsx_element", "jsx_self_closing_element", "jsx_fragment" },
        })

        assert.equals(6, #all_captures)
        assert.equals(1, #grouped_captures["jsx_fragment"])
        assert.equals(5, #grouped_captures["jsx_element"])
        assert.equals(0, #grouped_captures["jsx_self_closing_element"])

        vim.api.nvim_buf_delete(0, { force = true }) -- delete buffer after the test
    end)
end)

describe("find_named_siblings_in_direction_with_types", function()
    after_each(function()
        vim.api.nvim_buf_delete(0, { force = true }) -- delete buffer after the test
    end)

    it("returns next siblings of given node if they match given type(s)", function()
        set_buffer_content_as_react_component()
        vim.cmd("norm! 5gg^") -- cursor to start of first <li> tag

        local current_jsx_node = ts_utils.get_node_at_cursor(0):parent()
        local current_jsx_node_text = vim.treesitter.get_node_text(current_jsx_node, 0)
        assert.equals("<li>Home</li>", current_jsx_node_text)

        local next_siblings = lib_ts.find_named_siblings_in_direction_with_types({
            node = current_jsx_node,
            direction = "next",
            desired_types = { "jsx_element", "jsx_self_closing_element" },
        })

        assert.equals(
            [[<li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>]],
            vim.treesitter.get_node_text(next_siblings[1], 0)
        )
        assert.equals("<li>Contacts</li>", vim.treesitter.get_node_text(next_siblings[2], 0))
        assert.equals("<li>FAQ</li>", vim.treesitter.get_node_text(next_siblings[3], 0))
    end)

    it("returns previous siblings of given node if they match given type(s)", function()
        set_buffer_content_as_react_component()
        vim.cmd("norm! 10gg^") -- cursor to start of 3rd <li> tag

        local current_jsx_node = ts_utils.get_node_at_cursor(0):parent()
        local current_jsx_node_text = vim.treesitter.get_node_text(current_jsx_node, 0)
        assert.equals("<li>Contacts</li>", current_jsx_node_text)

        local previous_siblings = lib_ts.find_named_siblings_in_direction_with_types({
            node = current_jsx_node,
            direction = "previous",
            desired_types = { "jsx_element", "jsx_self_closing_element" },
        })

        assert.equals(
            [[<li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>]],
            vim.treesitter.get_node_text(previous_siblings[1], 0)
        )
        assert.equals("<li>Home</li>", vim.treesitter.get_node_text(previous_siblings[2], 0))
    end)
end)

describe("node_start_and_end_on_same_line", function()
    after_each(function()
        vim.api.nvim_buf_delete(0, { force = true })
    end)

    it("checks for single line case correctly", function()
        set_buffer_content_as_react_component()
        vim.cmd("norm! 10gg^") -- cursor to start of 3rd <li> tag

        local current_jsx_node = ts_utils.get_node_at_cursor(0):parent()
        local current_jsx_node_text = vim.treesitter.get_node_text(current_jsx_node, 0)
        assert.equals("<li>Contacts</li>", current_jsx_node_text)

        assert.is_true(lib_ts.node_start_and_end_on_same_line(current_jsx_node))
    end)

    it("checks for multiple lines case correctly", function()
        set_buffer_content_as_react_component()
        vim.cmd("norm! 6gg^") -- cursor to start of 2nd <li> tag

        local current_jsx_node = ts_utils.get_node_at_cursor(0):parent()
        local current_jsx_node_text = vim.treesitter.get_node_text(current_jsx_node, 0)
        assert.equals(
            [[<li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>]],
            current_jsx_node_text
        )

        assert.is_false(lib_ts.node_start_and_end_on_same_line(current_jsx_node))
    end)
end)

require("tests.editor_config")

local h = require("deliberate.helpers")
local tsx = require("deliberate.lib.tree-sitter.tsx")
local ts_utils = require("nvim-treesitter.ts_utils")

describe("get_all_html_nodes_in_buffer()", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)

    it("works", function()
        local all_nodes, grouped_captures = tsx.get_all_html_nodes_in_buffer(0)
        assert.equals(#all_nodes, 20)
        assert.equals(#grouped_captures["jsx_fragment"], 1)
        assert.equals(#grouped_captures["jsx_element"], 17)
        assert.equals(#grouped_captures["jsx_self_closing_element"], 2)
    end)
end)

describe("get_tag_identifier_node()", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)

    it("works for `jsx_element` node type", function()
        local _, grouped_captures = tsx.get_all_html_nodes_in_buffer(0)
        local node = grouped_captures["jsx_element"][1]
        local tag_idenifier_node = tsx.get_tag_identifier_node(node)
        h.node_has_text(tag_idenifier_node, "p")
    end)

    it("works for `jsx_self_closing_element` node type", function()
        local _, grouped_captures = tsx.get_all_html_nodes_in_buffer(0)
        local node = grouped_captures["jsx_self_closing_element"][1]
        local tag_idenifier_node = tsx.get_tag_identifier_node(node)
        h.node_has_text(tag_idenifier_node, "OtherComponent")
    end)
end)

describe("get_className_property_string_node()", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)

    it("works", function()
        local _, grouped_captures = tsx.get_all_html_nodes_in_buffer(0)
        local className_string_node =
            tsx.get_className_property_string_node(0, grouped_captures["jsx_element"][2])
        h.node_has_text(className_string_node, [["h-screen w-screen bg-zinc-900"]])
    end)
end)

describe("extract_class_names()", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)

    it("works", function()
        local _, grouped_captures = tsx.get_all_html_nodes_in_buffer(0)
        local class_names = tsx.extract_class_names(0, grouped_captures["jsx_element"][2])
        assert.same({ "h-screen", "w-screen", "bg-zinc-900" }, class_names)
    end)
end)

describe("get_html_node()", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)

    it("works", function()
        vim.cmd("norm! 22ggfn")
        local node_at_cursor = ts_utils.get_node_at_cursor()
        h.node_has_text(node_at_cursor, "Contacts")

        local html_node = tsx.get_html_node(node_at_cursor)
        h.node_has_text(html_node, "<li>Contacts</li>")
    end)
end)

describe("get_updated_root()", function() end) -- difficult to test

describe("get_first_closing_bracket()", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)

    it("works", function()
        vim.cmd("norm! 22ggfn")

        local html_node = tsx.get_html_node(ts_utils.get_node_at_cursor())
        h.node_has_text(html_node, "<li>Contacts</li>")

        local first_bracket_node = tsx.get_first_closing_bracket(0, html_node)
        h.node_has_text(first_bracket_node, ">")
        h.node_has_text(first_bracket_node:parent(), "<li>")
        h.node_has_text(first_bracket_node:parent():parent(), "<li>Contacts</li>")
    end)
end)

describe("get_html_children()", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)

    it("works", function()
        vim.cmd("norm! 35gg^")

        local html_node = tsx.get_html_node(ts_utils.get_node_at_cursor())
        h.node_first_line(html_node, "<ul>")

        local html_children = tsx.get_html_children(html_node)
        h.node_has_text(html_children[1], "<li>Log In</li>")
        h.node_has_text(html_children[2], "<li>Sign Up</li>")
    end)
end)

describe("get_html_siblings()", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)

    it("works", function()
        vim.cmd("norm! 22gg^")

        local html_node = tsx.get_html_node(ts_utils.get_node_at_cursor())
        h.node_has_text(html_node, "<li>Contacts</li>")

        local next_siblings = tsx.get_html_siblings(html_node, "next")
        h.node_has_text(next_siblings[1], "<li>FAQ</li>")
        h.node_has_text(next_siblings[2], "<OtherComponent />")

        local previous_siblings = tsx.get_html_siblings(html_node, "previous")
        h.node_first_line(previous_siblings[1], "<li>")
        h.node_has_text(previous_siblings[2], "<li>Home</li>")
    end)
end)

describe("get_content_nodes()", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)
    it("works", function()
        vim.cmd("norm! 22gg^")
        local html_node = tsx.get_html_node(ts_utils.get_node_at_cursor())
        h.node_has_text(html_node, "<li>Contacts</li>")
        local test_node = tsx.get_text_nodes(html_node)[1]
        h.node_has_text(test_node, "Contacts")
    end)
end)

describe("node_is_component()", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)
    it("detects node isn't a component", function()
        vim.cmd("norm! 23gg^")
        local html_node = tsx.get_html_node(ts_utils.get_node_at_cursor())
        h.node_has_text(html_node, "<li>FAQ</li>")
        assert.equals(false, tsx.node_is_component(html_node))
    end)
    it("detects node is a component", function()
        vim.cmd("norm! 24gg^")
        local html_node = tsx.get_html_node(ts_utils.get_node_at_cursor())
        h.node_has_text(html_node, "<OtherComponent />")
        assert.equals(true, tsx.node_is_component(html_node))
    end)
end)

describe("get_opening_and_closing_tags", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)
    it("detects node isn't a component", function()
        vim.cmd("norm! 23gg^")
        local html_node = tsx.get_html_node(ts_utils.get_node_at_cursor())
        h.node_has_text(html_node, "<li>FAQ</li>")
        local opening, ending = tsx.get_opening_and_closing_tags(html_node)
        h.node_has_text(opening, "<li>")
        h.node_has_text(ending, "</li>")
    end)
end)

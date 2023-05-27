require("tests.editor_config")

local ts_utils = require("nvim-treesitter.ts_utils")
local helpers = require("stormcaller.helpers")
local lib_ts_svelte = require("stormcaller.lib.tree-sitter.svelte")

describe("get_all_html_nodes_in_buffer()", function()
    before_each(function() helpers.set_buffer_content_as_svelte_file() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)

    it("works", function()
        local all_nodes, grouped_captures = lib_ts_svelte.get_all_html_nodes_in_buffer(0)

        assert.equals(17, #all_nodes)
        assert.equals(17, #grouped_captures["element"])
    end)
end)

describe("get_tag_identifier_node()", function()
    helpers.set_buffer_content_as_svelte_file()

    it("works for element that has both starting and closing elements", function()
        local all_nodes = lib_ts_svelte.get_all_html_nodes_in_buffer(0)
        local normal_node = all_nodes[15]
        helpers.node_has_text(normal_node, "<h1>Ligma</h1>")

        local tag_idenifier_node = lib_ts_svelte.get_tag_identifier_node(normal_node)
        helpers.node_has_text(tag_idenifier_node, "h1")
    end)

    it("works for element that has only self_closing_tag", function()
        local all_nodes = lib_ts_svelte.get_all_html_nodes_in_buffer(0)
        local self_closing_node = all_nodes[13]
        helpers.node_has_text(self_closing_node, "<Counter />")

        local tag_idenifier_node = lib_ts_svelte.get_tag_identifier_node(self_closing_node)
        helpers.node_has_text(tag_idenifier_node, "Counter")
    end)

    vim.api.nvim_buf_delete(0, { force = true })
end)

describe("get_className_property_string_node()", function()
    helpers.set_buffer_content_as_svelte_file()

    it("works", function()
        local all_nodes = lib_ts_svelte.get_all_html_nodes_in_buffer(0)
        local node = all_nodes[6]
        helpers.node_first_line(node, '<span class="welcome">')

        local className_string_node = lib_ts_svelte.get_className_property_string_node(0, node)
        helpers.node_has_text(className_string_node, [["welcome"]])
    end)

    vim.api.nvim_buf_delete(0, { force = true })
end)

describe("extract_class_names()", function()
    helpers.set_buffer_content_as_svelte_file()

    it("works", function()
        local all_nodes = lib_ts_svelte.get_all_html_nodes_in_buffer(0)
        local node = all_nodes[6]
        helpers.node_first_line(node, '<span class="welcome">')

        local class_names = lib_ts_svelte.extract_class_names(0, node)
        assert.same({ "welcome" }, class_names)
    end)

    vim.api.nvim_buf_delete(0, { force = true })
end)

describe("get_html_node()", function()
    before_each(function() helpers.set_buffer_content_as_svelte_file() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)

    it("works", function()
        vim.cmd("norm! 32ggfg")

        local node_at_cursor = ts_utils.get_node_at_cursor()
        local html_node = lib_ts_svelte.get_html_node(node_at_cursor)

        helpers.node_has_text(html_node, "<h1>Ligma</h1>")
    end)
end)

describe("get_first_closing_bracket()", function()
    before_each(function() helpers.set_buffer_content_as_svelte_file() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)

    it("works", function()
        vim.cmd("norm! 32ggfg")

        local html_node = lib_ts_svelte.get_html_node(ts_utils.get_node_at_cursor())
        helpers.node_has_text(html_node, "<h1>Ligma</h1>")

        local first_bracket_node = lib_ts_svelte.get_first_closing_bracket(0, html_node)
        helpers.node_has_text(first_bracket_node, ">")
        helpers.node_has_text(first_bracket_node:parent(), "<h1>")
        helpers.node_has_text(first_bracket_node:parent():parent(), "<h1>Ligma</h1>")
    end)
end)

describe("get_html_children()", function()
    before_each(function() helpers.set_buffer_content_as_svelte_file() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)

    it("works", function()
        vim.cmd("norm! 31gg^")

        local html_node = lib_ts_svelte.get_html_node(ts_utils.get_node_at_cursor())
        helpers.node_first_line(html_node, "<section>")

        local html_children = lib_ts_svelte.get_html_children(html_node)
        assert.equals(3, #html_children)
        helpers.node_has_text(html_children[1], "<h1>Ligma</h1>")
        helpers.node_has_text(html_children[2], "<h3>is a made-up term</h3>")
        helpers.node_has_text(
            html_children[3],
            "<p>that gained popularity as part of an Internet prank or meme.</p>"
        )
    end)
end)

describe("get_html_siblings()", function()
    before_each(function() helpers.set_buffer_content_as_svelte_file() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)

    it("works", function()
        vim.cmd("norm! 33gg^")

        local html_node = lib_ts_svelte.get_html_node(ts_utils.get_node_at_cursor())
        helpers.node_has_text(html_node, "<h3>is a made-up term</h3>")

        local next_siblings = lib_ts_svelte.get_html_siblings(html_node, "next")
        assert.equals(1, #next_siblings)
        helpers.node_has_text(
            next_siblings[1],
            "<p>that gained popularity as part of an Internet prank or meme.</p>"
        )

        local previous_siblings = lib_ts_svelte.get_html_siblings(html_node, "previous")
        assert.equals(1, #previous_siblings)
        helpers.node_first_line(previous_siblings[1], "<h1>Ligma</h1>")
    end)
end)

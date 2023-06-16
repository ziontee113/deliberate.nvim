require("tests.editor_config")

local ts_utils = require("nvim-treesitter.ts_utils")
local h = require("deliberate.helpers")
local svelte = require("deliberate.lib.tree-sitter.svelte")

describe("get_all_html_nodes_in_buffer()", function()
    before_each(function() h.set_buffer_content_as_svelte_file() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)

    it("works", function()
        local all_nodes, grouped_captures = svelte.get_all_html_nodes_in_buffer(0)
        assert.equals(17, #all_nodes)
        assert.equals(17, #grouped_captures["element"])
    end)
end)

describe("get_tag_identifier_node()", function()
    h.set_buffer_content_as_svelte_file()

    it("works for element that has both starting and closing elements", function()
        local all_nodes = svelte.get_all_html_nodes_in_buffer(0)
        local normal_node = all_nodes[15]
        h.node_has_text(normal_node, "<h1>Ligma</h1>")

        local tag_idenifier_node = svelte.get_tag_identifier_node(normal_node)
        h.node_has_text(tag_idenifier_node, "h1")
    end)

    it("works for element that has only self_closing_tag", function()
        local all_nodes = svelte.get_all_html_nodes_in_buffer(0)
        local self_closing_node = all_nodes[13]
        h.node_has_text(self_closing_node, "<Counter />")

        local tag_idenifier_node = svelte.get_tag_identifier_node(self_closing_node)
        h.node_has_text(tag_idenifier_node, "Counter")
    end)

    vim.api.nvim_buf_delete(0, { force = true })
end)

describe("get_className_property_string_node()", function()
    h.set_buffer_content_as_svelte_file()

    it("works", function()
        local all_nodes = svelte.get_all_html_nodes_in_buffer(0)
        local node = all_nodes[6]
        h.node_first_line(node, '<span class="welcome">')

        local className_string_node = svelte.get_className_property_string_node(0, node)
        h.node_has_text(className_string_node, [["welcome"]])
    end)

    it("returns nil if couldn't find target node", function()
        local all_nodes = svelte.get_all_html_nodes_in_buffer(0)
        local node = all_nodes[5]
        h.node_first_line(node, "<h1>")

        local className_string_node = svelte.get_className_property_string_node(0, node)
        assert.equals(nil, className_string_node)
    end)

    vim.api.nvim_buf_delete(0, { force = true })
end)

describe("extract_class_names()", function()
    h.set_buffer_content_as_svelte_file()

    it("works", function()
        local all_nodes = svelte.get_all_html_nodes_in_buffer(0)
        local node = all_nodes[6]
        h.node_first_line(node, '<span class="welcome">')

        local class_names = svelte.extract_class_names(0, node)
        assert.same({ "welcome" }, class_names)
    end)

    vim.api.nvim_buf_delete(0, { force = true })
end)

describe("get_html_node()", function()
    before_each(function() h.set_buffer_content_as_svelte_file() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)

    it("works", function()
        vim.cmd("norm! 32ggfg")
        local node_at_cursor = ts_utils.get_node_at_cursor()
        local html_node = svelte.get_html_node(node_at_cursor)
        h.node_has_text(html_node, "<h1>Ligma</h1>")
    end)
end)

describe("get_first_closing_bracket()", function()
    before_each(function() h.set_buffer_content_as_svelte_file() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)

    it("works", function()
        vim.cmd("norm! 32ggfg")

        local html_node = svelte.get_html_node(ts_utils.get_node_at_cursor())
        h.node_has_text(html_node, "<h1>Ligma</h1>")

        local first_bracket_node = svelte.get_first_closing_bracket(0, html_node)
        h.node_has_text(first_bracket_node, ">")
        h.node_has_text(first_bracket_node:parent(), "<h1>")
        h.node_has_text(first_bracket_node:parent():parent(), "<h1>Ligma</h1>")
    end)
end)

describe("get_html_children()", function()
    before_each(function() h.set_buffer_content_as_svelte_file() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)

    it("works", function()
        vim.cmd("norm! 31gg^")

        local html_node = svelte.get_html_node(ts_utils.get_node_at_cursor())
        h.node_first_line(html_node, "<section>")
        local html_children = svelte.get_html_children(html_node)
        assert.equals(3, #html_children)

        h.node_has_text(html_children[1], "<h1>Ligma</h1>")
        h.node_has_text(html_children[2], "<h3>is a made-up term</h3>")
        h.node_has_text(
            html_children[3],
            "<p>that gained popularity as part of an Internet prank or meme.</p>"
        )
    end)
end)

describe("get_html_siblings()", function()
    before_each(function() h.set_buffer_content_as_svelte_file() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)

    it("works", function()
        vim.cmd("norm! 33gg^")

        local html_node = svelte.get_html_node(ts_utils.get_node_at_cursor())
        h.node_has_text(html_node, "<h3>is a made-up term</h3>")

        local next_siblings = svelte.get_html_siblings(html_node, "next")
        assert.equals(1, #next_siblings)
        h.node_has_text(
            next_siblings[1],
            "<p>that gained popularity as part of an Internet prank or meme.</p>"
        )

        local previous_siblings = svelte.get_html_siblings(html_node, "previous")
        assert.equals(1, #previous_siblings)
        h.node_first_line(previous_siblings[1], "<h1>Ligma</h1>")
    end)
end)

describe("get_text_nodes()", function()
    before_each(function() h.set_buffer_content_as_svelte_file() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)
    it("works", function()
        vim.cmd("norm! 33gg^")
        local html_node = svelte.get_html_node(ts_utils.get_node_at_cursor())
        h.node_has_text(html_node, "<h3>is a made-up term</h3>")
        local text_node = svelte.get_text_nodes(html_node)[1]
        h.node_has_text(text_node, "is a made-up term")
    end)
end)

describe("node_is_component()", function()
    before_each(function() h.set_buffer_content_as_svelte_file() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)
    it("detects node isn't a component", function()
        vim.cmd("norm! 33gg^")
        local html_node = svelte.get_html_node(ts_utils.get_node_at_cursor())
        h.node_has_text(html_node, "<h3>is a made-up term</h3>")
        assert.equals(false, svelte.node_is_component(html_node))
    end)
    it("detects node is a component", function()
        vim.cmd("norm! 28gg^")
        local html_node = svelte.get_html_node(ts_utils.get_node_at_cursor())
        h.node_has_text(html_node, "<Counter />")
        assert.equals(true, svelte.node_is_component(html_node))
    end)
end)

describe("get_opening_and_closing_tags()", function()
    before_each(function() h.set_buffer_content_as_svelte_file() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)
    it("detects node isn't a component", function()
        vim.cmd("norm! 33gg^")
        local html_node = svelte.get_html_node(ts_utils.get_node_at_cursor())
        h.node_has_text(html_node, "<h3>is a made-up term</h3>")
        local opening, ending = svelte.get_opening_and_closing_tags(html_node)
        h.node_has_text(opening, "<h3>")
        h.node_has_text(ending, "</h3>")
    end)
end)

describe("get_src_property_string_node", function()
    before_each(function()
        vim.bo.ft = "svelte"
        h.set_buf_content([[<section>
<div className="h-screen w-screen bg-zinc-900">
    <li>Home</li>
    <img src="public/image.jpg" />
</div>
</section>]])
    end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)

    it("works", function()
        vim.cmd("norm! 4gg^")
        local html_node = svelte.get_html_node(ts_utils.get_node_at_cursor())
        h.node_has_text(html_node, '<img src="public/image.jpg" />')
        local src_string_node = svelte.get_src_property_string_node(0, html_node)
        h.node_has_text(src_string_node, '"public/image.jpg"')
    end)
end)

describe("get_attribute_value()", function()
    before_each(function() h.set_buffer_content_as_svelte_file() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)

    it("works", function()
        vim.cmd("norm! 17gg^")
        local html_node = svelte.get_html_node(ts_utils.get_node_at_cursor())
        h.node_has_text(html_node, '<img src={welcome_fallback} alt="Welcome" />')

        local attribute = "src"
        local want = "{welcome_fallback}"

        local result_node = svelte.get_attribute_value(0, html_node, attribute)
        local result_text = vim.treesitter.get_node_text(result_node, 0)

        assert.equals(want, result_text)
    end)
end)

require("tests.editor_config")

local helpers = require("stormcaller.helpers")
local lib_ts_tsx = require("stormcaller.lib.tree-sitter.tsx")
local ts_utils = require("nvim-treesitter.ts_utils")

describe("get_all_html_nodes_in_buffer()", function()
    before_each(function() helpers.set_buffer_content_as_multiple_react_components() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)

    it("works", function()
        local all_nodes, grouped_captures = lib_ts_tsx.get_all_html_nodes_in_buffer(0)

        assert.equals(#all_nodes, 20)
        assert.equals(#grouped_captures["jsx_fragment"], 1)
        assert.equals(#grouped_captures["jsx_element"], 17)
        assert.equals(#grouped_captures["jsx_self_closing_element"], 2)
    end)
end)

describe("get_tag_identifier_node()", function()
    before_each(function() helpers.set_buffer_content_as_multiple_react_components() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)

    it("works for `jsx_element` node type", function()
        local _, grouped_captures = lib_ts_tsx.get_all_html_nodes_in_buffer(0)
        local node = grouped_captures["jsx_element"][1]

        local tag_idenifier_node = lib_ts_tsx.get_tag_identifier_node(node)
        helpers.assert_node_has_text(tag_idenifier_node, "p")
    end)

    it("works for `jsx_self_closing_element` node type", function()
        local _, grouped_captures = lib_ts_tsx.get_all_html_nodes_in_buffer(0)
        local node = grouped_captures["jsx_self_closing_element"][1]

        local tag_idenifier_node = lib_ts_tsx.get_tag_identifier_node(node)
        helpers.assert_node_has_text(tag_idenifier_node, "OtherComponent")
    end)
end)

describe("get_className_property_string_node()", function()
    before_each(function() helpers.set_buffer_content_as_multiple_react_components() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)

    it("works", function()
        local _, grouped_captures = lib_ts_tsx.get_all_html_nodes_in_buffer(0)
        local className_string_node =
            lib_ts_tsx.get_className_property_string_node(0, grouped_captures["jsx_element"][2])

        helpers.assert_node_has_text(className_string_node, [["h-screen w-screen bg-zinc-900"]])
    end)
end)

describe("extract_class_names()", function()
    before_each(function() helpers.set_buffer_content_as_multiple_react_components() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)

    it("works", function()
        local _, grouped_captures = lib_ts_tsx.get_all_html_nodes_in_buffer(0)
        local class_names = lib_ts_tsx.extract_class_names(0, grouped_captures["jsx_element"][2])

        assert.same({ "h-screen", "w-screen", "bg-zinc-900" }, class_names)
    end)
end)

describe("get_html_node()", function()
    before_each(function() helpers.set_buffer_content_as_multiple_react_components() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)

    it("works", function()
        vim.cmd("norm! 22ggfn")

        local node_at_cursor = ts_utils.get_node_at_cursor()
        helpers.assert_node_has_text(node_at_cursor, "Contacts")

        local html_node = lib_ts_tsx.get_html_node(node_at_cursor)
        helpers.assert_node_has_text(html_node, "<li>Contacts</li>")
    end)
end)

describe("get_updated_root()", function() end) -- difficult to test

describe("get_first_closing_bracket()", function()
    before_each(function() helpers.set_buffer_content_as_multiple_react_components() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)

    it("works", function()
        vim.cmd("norm! 22ggfn")

        local html_node = lib_ts_tsx.get_html_node(ts_utils.get_node_at_cursor())
        helpers.assert_node_has_text(html_node, "<li>Contacts</li>")

        local first_bracket_node = lib_ts_tsx.get_first_closing_bracket(0, html_node)
        helpers.assert_node_has_text(first_bracket_node, ">")
        helpers.assert_node_has_text(first_bracket_node:parent(), "<li>")
        helpers.assert_node_has_text(first_bracket_node:parent():parent(), "<li>Contacts</li>")
    end)
end)

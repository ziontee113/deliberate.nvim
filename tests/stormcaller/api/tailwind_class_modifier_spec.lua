local tcm = require("stormcaller.api.tailwind_class_modifier")
local catalyst = require("stormcaller.lib.catalyst")
local navigator = require("stormcaller.lib.navigator")
local helpers = require("stormcaller.helpers")

local clean_up = function()
    vim.api.nvim_buf_delete(0, { force = true })
    catalyst.clear_selection()
end

describe("change_padding()", function()
    before_each(function() helpers.set_buffer_content_as_multiple_react_components() end)
    after_each(function() clean_up() end)

    it("adds className property and specified class for tag with no classNames", function()
        vim.cmd("norm! 22gg^") -- cursor to <li>Contacts</li>

        catalyst.initiate({ win = 0, buf = 0 })
        helpers.assert_catalyst_node_has_text("<li>Contacts</li>")

        tcm.change_padding({ axis = "omni", value = "p-4" })
        helpers.assert_catalyst_node_has_text('<li className="p-4">Contacts</li>')
    end)

    it("appends specified class for tag that already has classNames", function()
        vim.cmd("norm! 90gg^")

        catalyst.initiate({ win = 0, buf = 0 })
        helpers.assert_catalyst_node_has_text(
            '<h3 className="mt-4 text-sm text-gray-700">{image.name}</h3>'
        )

        tcm.change_padding({ axis = "omni", value = "p-4" })
        helpers.assert_catalyst_node_has_text(
            '<h3 className="mt-4 text-sm text-gray-700 p-4">{image.name}</h3>'
        )
    end)

    it("replaces equivalent padding omni axis using arbitrary value", function()
        vim.cmd("norm! 22gg^") -- cursor to <li>Contacts</li>
        catalyst.initiate({ win = 0, buf = 0 })

        tcm.change_padding({ axis = "omni", value = "p-[20px]" })
        helpers.assert_catalyst_node_has_text('<li className="p-[20px]">Contacts</li>')

        tcm.change_padding({ axis = "omni", value = "p-8" })
        helpers.assert_catalyst_node_has_text('<li className="p-8">Contacts</li>')
    end)

    it("replaces equivalent padding axis in-place", function()
        vim.cmd("norm! 60gg^") -- cursor to <div className="mx-auto max-w-2xl px-4 py-16 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">
        catalyst.initiate({ win = 0, buf = 0 })

        tcm.change_padding({ axis = "x", value = "px-7" })
        helpers.assert_first_line_of_catalyst_node_has_text(
            '<div className="mx-auto max-w-2xl px-7 py-16 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">'
        )

        tcm.change_padding({ axis = "y", value = "py-7" })
        helpers.assert_first_line_of_catalyst_node_has_text(
            '<div className="mx-auto max-w-2xl px-7 py-7 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">'
        )
    end)

    it("removes equivalent padding axis if value passed in is empty string", function()
        vim.cmd("norm! 60gg^") -- cursor to <div className="mx-auto max-w-2xl px-4 py-16 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">
        catalyst.initiate({ win = 0, buf = 0 })

        tcm.change_padding({ axis = "y", value = "" })
        helpers.assert_first_line_of_catalyst_node_has_text(
            '<div className="mx-auto max-w-2xl px-4 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">'
        )
        tcm.change_padding({ axis = "x", value = "" })
        helpers.assert_first_line_of_catalyst_node_has_text(
            '<div className="mx-auto max-w-2xl sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">'
        )
    end)
end)

describe("change_padding() for all `selected_nodes`", function()
    before_each(function() helpers.set_buffer_content_as_multiple_react_components() end)
    after_each(function() clean_up() end)

    it("works", function()
        vim.cmd("norm! 22gg^") -- cursor to <li>Contacts</li>

        catalyst.initiate({ win = 0, buf = 0 })
        helpers.assert_catalyst_node_has_text("<li>Contacts</li>")

        navigator.move({ destination = "next", track_selection = true })

        tcm.change_padding({ axis = "omni", value = "p-4" })

        -- 1st round
        local selected_nodes = catalyst.selected_nodes()
        assert.equals(#selected_nodes, 2)

        tcm.change_padding({ axis = "omni", value = "p-4" })
        helpers.assert_node_has_text(selected_nodes[1], '<li className="p-4">Contacts</li>')
        helpers.assert_node_has_text(selected_nodes[2], '<li className="p-4">FAQ</li>')

        -- 2nd round
        selected_nodes = catalyst.selected_nodes()
        assert.equals(#selected_nodes, 2)

        tcm.change_padding({ axis = "omni", value = "p-20" })
        helpers.assert_node_has_text(selected_nodes[1], '<li className="p-20">Contacts</li>')
        helpers.assert_node_has_text(selected_nodes[2], '<li className="p-20">FAQ</li>')
    end)
end)

describe("change_margin() & change_spacing()", function()
    before_each(function() helpers.set_buffer_content_as_multiple_react_components() end)
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)

    it("adds margin and spacing classes correctly", function()
        vim.cmd("norm! 22gg^") -- cursor to <li>Contacts</li>
        catalyst.initiate({ win = 0, buf = 0 })

        tcm.change_margin({ axis = "omni", value = "m-4" })
        helpers.assert_catalyst_node_has_text('<li className="m-4">Contacts</li>')

        tcm.change_spacing({ axis = "x", value = "space-x-4" })
        helpers.assert_catalyst_node_has_text('<li className="m-4 space-x-4">Contacts</li>')
    end)
end)

describe("change_text_color() & change_background_color()", function()
    before_each(function() helpers.set_buffer_content_as_multiple_react_components() end)
    after_each(function() clean_up() end)

    it("adds text-color and background-color classes correctly", function()
        vim.cmd("norm! 22gg^") -- cursor to <li>Contacts</li>
        catalyst.initiate({ win = 0, buf = 0 })

        tcm.change_text_color({ value = "text-zinc-400" })
        helpers.assert_catalyst_node_has_text('<li className="text-zinc-400">Contacts</li>')

        tcm.change_background_color({ value = "bg-black" })
        helpers.assert_catalyst_node_has_text(
            '<li className="text-zinc-400 bg-black">Contacts</li>'
        )

        tcm.change_text_color({ value = "text-[#000]" })
        helpers.assert_catalyst_node_has_text('<li className="text-[#000] bg-black">Contacts</li>')

        tcm.change_background_color({ value = "bg-[rgb(0,12,24)]" })
        helpers.assert_catalyst_node_has_text(
            '<li className="text-[#000] bg-[rgb(0,12,24)]">Contacts</li>'
        )

        tcm.change_text_color({ value = "" })
        helpers.assert_catalyst_node_has_text('<li className="bg-[rgb(0,12,24)]">Contacts</li>')

        tcm.change_background_color({ value = "" })
        helpers.assert_catalyst_node_has_text('<li className="">Contacts</li>')
    end)
end)

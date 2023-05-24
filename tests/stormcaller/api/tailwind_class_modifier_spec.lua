require("tests.editor_config")

local tcm = require("stormcaller.api.tailwind_class_modifier")
local catalyst = require("stormcaller.lib.catalyst")
local navigator = require("stormcaller.lib.navigator")
local helpers = require("stormcaller.helpers")

describe("change_padding()", function()
    before_each(function() helpers.set_buffer_content_as_multiple_react_components() end)
    after_each(function() helpers.clean_up() end)

    it("adds className property and specified class for tag with no classNames", function()
        vim.cmd("norm! 22gg^") -- cursor to <li>Contacts</li>

        catalyst.initiate({ win = 0, buf = 0 })
        helpers.assert_catalyst_node_has_text("<li>Contacts</li>")

        tcm.change_padding({ axis = "omni", value = "p-4" })
        helpers.assert_catalyst_node_has_text('<li className="p-4">Contacts</li>')
    end)

    it(
        "adds className property and specified class for tag with no classNames, then move to different tags and do the same",
        function()
            vim.cmd("norm! 22gg^") -- cursor to <li>Contacts</li>

            catalyst.initiate({ win = 0, buf = 0 })
            helpers.assert_catalyst_node_has_text("<li>Contacts</li>")

            -- 1st padding change
            tcm.change_padding({ axis = "omni", value = "p-4" })
            helpers.assert_catalyst_node_has_text('<li className="p-4">Contacts</li>')

            -- 2nd padding change
            navigator.move({ destination = "next" })
            helpers.assert_catalyst_node_has_text("<li>FAQ</li>")

            tcm.change_padding({ axis = "omni", value = "p-8" })
            helpers.assert_catalyst_node_has_text('<li className="p-8">FAQ</li>')

            -- 3rd padding change
            navigator.move({ destination = "previous" })
            navigator.move({ destination = "previous" })
            navigator.move({ destination = "previous" })
            helpers.assert_catalyst_node_has_text("<li>Home</li>")

            tcm.change_padding({ axis = "omni", value = "p-6" })
            helpers.assert_catalyst_node_has_text('<li className="p-6">Home</li>')
        end
    )

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
    after_each(function() helpers.clean_up() end)

    it("works", function()
        vim.cmd("norm! 22gg^") -- cursor to <li>Contacts</li>

        -- initiate and move twice with `track_selection`
        catalyst.initiate({ win = 0, buf = 0 })
        helpers.assert_catalyst_node_has_text("<li>Contacts</li>")

        navigator.move({ destination = "next", track_selection = true })
        navigator.move({ destination = "next", track_selection = true })

        local selected_nodes = catalyst.selected_nodes()
        assert.equals(#selected_nodes, 2)
        helpers.assert_node_has_text(selected_nodes[1], "<li>Contacts</li>")
        helpers.assert_node_has_text(selected_nodes[2], "<li>FAQ</li>")

        -- 1st round, add classes for tags with no classes
        tcm.change_padding({ axis = "omni", value = "p-4" })

        selected_nodes = catalyst.selected_nodes()
        assert.equals(#selected_nodes, 2)

        tcm.change_padding({ axis = "omni", value = "p-4" })
        helpers.assert_node_has_text(selected_nodes[1], '<li className="p-4">Contacts</li>')
        helpers.assert_node_has_text(selected_nodes[2], '<li className="p-4">FAQ</li>')

        -- 2nd round, modifying already exist omni axis
        selected_nodes = catalyst.selected_nodes()
        assert.equals(#selected_nodes, 2)

        tcm.change_padding({ axis = "omni", value = "p-20" })
        helpers.assert_node_has_text(selected_nodes[1], '<li className="p-20">Contacts</li>')
        helpers.assert_node_has_text(selected_nodes[2], '<li className="p-20">FAQ</li>')

        -- 3rd round, adding extra y axis
        selected_nodes = catalyst.selected_nodes()
        assert.equals(#selected_nodes, 2)

        tcm.change_padding({ axis = "y", value = "py-4" })
        helpers.assert_node_has_text(selected_nodes[1], '<li className="p-20 py-4">Contacts</li>')
        helpers.assert_node_has_text(selected_nodes[2], '<li className="p-20 py-4">FAQ</li>')
    end)
end)

describe("change_margin() & change_spacing()", function()
    before_each(function() helpers.set_buffer_content_as_multiple_react_components() end)
    after_each(function() helpers.clean_up() end)

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
    after_each(function() helpers.clean_up() end)

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

    it("adds text-color to all selected elements correctly", function()
        vim.cmd("norm! 22gg^") -- cursor to <li>Contacts</li>
        catalyst.initiate({ win = 0, buf = 0 })

        -- 1st text color change
        tcm.change_text_color({ value = "text-zinc-400" })
        helpers.assert_catalyst_node_has_text('<li className="text-zinc-400">Contacts</li>')

        -- 2nd text color change
        navigator.move({ destination = "next" })
        helpers.assert_catalyst_node_has_text("<li>FAQ</li>")

        tcm.change_text_color({ value = "text-zinc-400" })
        helpers.assert_catalyst_node_has_text('<li className="text-zinc-400">FAQ</li>')

        -- move then select multiple tags for the 3rd text color change
        navigator.move({ destination = "previous" })
        navigator.move({ destination = "previous", track_selection = true })
        navigator.move({ destination = "previous" })
        navigator.move({ destination = "previous", track_selection = true })

        tcm.change_text_color({ value = "text-red-200" })

        local selected_nodes = catalyst.selected_nodes()
        assert.equals(#selected_nodes, 2)

        helpers.assert_node_has_text(
            selected_nodes[1],
            '<li className="text-red-200">Contacts</li>'
        )
        helpers.assert_node_has_text(selected_nodes[2], '<li className="text-red-200">Home</li>')
    end)
end)

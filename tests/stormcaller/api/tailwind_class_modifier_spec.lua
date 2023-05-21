local tcm = require("stormcaller.api.tailwind_class_modifier")
local catalyst = require("stormcaller.lib.catalyst")
local helpers = require("stormcaller.helpers")

describe("change_padding()", function()
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)
    before_each(function() helpers.set_buffer_content_as_multiple_react_components() end)

    it("adds className property and specified class for tag with no classNames", function()
        vim.cmd("norm! 22gg^") -- cursor to <li>Contacts</li>

        catalyst.initiate({ win = 0, buf = 0 })
        helpers.assert_catalyst_node_has_text("<li>Contacts</li>")

        tcm.change_padding({ axis = "omni", change_to = "p-4" })
        helpers.assert_catalyst_node_has_text('<li className="p-4">Contacts</li>')
    end)

    it("appends specified class for tag that already has classNames", function()
        vim.cmd("norm! 90gg^")

        catalyst.initiate({ win = 0, buf = 0 })
        helpers.assert_catalyst_node_has_text(
            '<h3 className="mt-4 text-sm text-gray-700">{image.name}</h3>'
        )

        tcm.change_padding({ axis = "omni", change_to = "p-4" })
        helpers.assert_catalyst_node_has_text(
            '<h3 className="mt-4 text-sm text-gray-700 p-4">{image.name}</h3>'
        )
    end)

    it("replaces equivalent padding omni axis using arbitrary value", function()
        vim.cmd("norm! 22gg^") -- cursor to <li>Contacts</li>
        catalyst.initiate({ win = 0, buf = 0 })

        tcm.change_padding({ axis = "omni", change_to = "p-[20px]" })
        helpers.assert_catalyst_node_has_text('<li className="p-[20px]">Contacts</li>')

        tcm.change_padding({ axis = "omni", change_to = "p-8" })
        helpers.assert_catalyst_node_has_text('<li className="p-8">Contacts</li>')
    end)

    it("replaces equivalent padding axis in-place", function()
        vim.cmd("norm! 60gg^") -- cursor to <div className="mx-auto max-w-2xl px-4 py-16 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">
        catalyst.initiate({ win = 0, buf = 0 })

        tcm.change_padding({ axis = "x", change_to = "px-7" })
        helpers.assert_first_line_of_catalyst_node_has_text(
            '<div className="mx-auto max-w-2xl px-7 py-16 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">'
        )

        tcm.change_padding({ axis = "y", change_to = "py-7" })
        helpers.assert_first_line_of_catalyst_node_has_text(
            '<div className="mx-auto max-w-2xl px-7 py-7 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">'
        )
    end)
end)

describe("change_margin() & change_spacing()", function()
    after_each(function() vim.api.nvim_buf_delete(0, { force = true }) end)
    before_each(function() helpers.set_buffer_content_as_multiple_react_components() end)

    it("adds className property and specified class for tag with no classNames", function()
        vim.cmd("norm! 22gg^") -- cursor to <li>Contacts</li>

        catalyst.initiate({ win = 0, buf = 0 })
        helpers.assert_catalyst_node_has_text("<li>Contacts</li>")

        tcm.change_margin({ axis = "omni", change_to = "m-4" })
        helpers.assert_catalyst_node_has_text('<li className="m-4">Contacts</li>')

        tcm.change_spacing({ axis = "x", change_to = "space-x-4" })
        helpers.assert_catalyst_node_has_text('<li className="m-4 space-x-4">Contacts</li>')
    end)
end)

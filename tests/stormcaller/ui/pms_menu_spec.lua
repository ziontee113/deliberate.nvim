local pms = require("stormcaller.ui.pms_menu")

local utils = require("stormcaller.lib.utils")
local h = require("stormcaller.helpers")
local initiate = h.initiate_for_ui

describe("...", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("...", function()
        initiate("22gg^", "<li>Contacts</li>")

        pms.change_padding({ axis = "" })

        local popup_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local want = {
            "p-10",
            "p-11",
            "p-12",
            "p-14",
            "",
            "p-16",
            "p-20",
            "p-24",
            "p-28",
            "p-32",
            "",
            "p-36",
            "p-40",
            "p-44",
            "p-48",
            "p-52",
            "",
            "p-56",
            "p-60",
            "p-64",
            "p-72",
            "p-80",
            "p-96",
            "p-0",
        }
        assert.same(want, popup_lines)

        utils.feed_keys("r")

        h.catalyst_last('<li className="p-12">Contacts</li>')
    end)
end)

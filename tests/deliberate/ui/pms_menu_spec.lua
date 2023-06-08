require("tests.editor_config")

local pms = require("deliberate.ui.pms_menu")
local utils = require("deliberate.lib.utils")
local h = require("deliberate.helpers")
local initiate = h.initiate_for_ui

describe("...", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("...", function()
        initiate("22gg^", "<li>Contacts</li>")

        pms.change_padding({ axis = "" })

        local popup_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local want = {
            "w p-10",
            "e p-11",
            "r p-12",
            "t p-14",
            "",
            "y p-16",
            "u p-20",
            "i p-24",
            "o p-28",
            "p p-32",
            "",
            "a p-36",
            "s p-40",
            "d p-44",
            "f p-48",
            "g p-52",
            "",
            "z p-56",
            "x p-60",
            "c p-64",
            "v p-72",
            "b p-80",
            "n p-96",
            "/ p-0",
        }
        assert.same(want, popup_lines)

        utils.feed_keys("r")

        h.catalyst_has('<li className="p-12">Contacts</li>')

        -- 2nd try
        pms.change_padding({ axis = "" })
        utils.feed_keys("1")
        h.catalyst_has('<li className="p-1">Contacts</li>')

        -- 3rd try
        pms.change_padding({ axis = "y" })
        utils.feed_keys("4")
        h.catalyst_has('<li className="p-1 py-4">Contacts</li>')
    end)
end)

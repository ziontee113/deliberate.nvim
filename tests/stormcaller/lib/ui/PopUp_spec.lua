local PopUp = require("stormcaller.lib.ui.PopUp")
local h = require("stormcaller.helpers")

local u = require("stormcaller.lib.utils")
local input = u.feed_keys

describe("PopUp", function()
    it("returns correct callback result", function()
        h.set_buffer_content_as_multiple_react_components()

        local myvar -- dummy variable to test callback result
        local popup = PopUp:new({
            title = "PopUp",
            items = {
                { keymaps = { "l" }, text = "LE SSERAFIM" },
                "",
                { keymaps = { "u" }, text = "UNFORGIVEN" },
            },
            keymaps = {
                hide = { "z", "q", "<Esc>" },
            },
            callback = function(result)
                print(result)
                myvar = result
            end,
        })

        --------------------- check if PopUp has correct content

        popup:show()

        local popup_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local want = {
            "l LE SSERAFIM",
            "",
            "u UNFORGIVEN",
        }
        assert.same(want, popup_lines)

        --------------------- check if myvar gets assigned new result value from callback

        input("u")
        assert.equals("UNFORGIVEN", myvar)
        ---> popup should be altomatically hidden after accepting a choice. No need to manually call `popup:hide()`

        --------------------- 2nd time

        popup:show()
        input("<CR>")
        assert.equals("LE SSERAFIM", myvar)
    end)
end)

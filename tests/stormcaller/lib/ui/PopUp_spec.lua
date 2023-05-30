local PopUp = require("stormcaller.lib.ui.PopUp")
local Input = require("stormcaller.lib.ui.Input")
local helpers = require("stormcaller.helpers")
local utils = require("stormcaller.lib.utils")

describe("PopUp", function()
    it("returns correct callback result", function()
        helpers.set_buffer_content_as_multiple_react_components()

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
                print(string.format("result from PopUp keymap == %s", result))
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

        utils.feed_keys("u")
        assert.equals("UNFORGIVEN", myvar)
        ---> popup should be altomatically hidden after accepting a choice. No need to manually call `popup:hide()`

        --------------------- 2nd time

        popup:show()
        utils.feed_keys("<CR>")
        assert.equals("LE SSERAFIM", myvar)
    end)
end)

describe("PopUp combined with Input", function()
    it("returns correct callback result", function()
        local myvar

        local input = Input:new({
            callback = function(result)
                myvar = result
                print(string.format("result from input == %s", result))
            end,
        })

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
                input:show()
                helpers.insert_chars_for_Input(input.buf, result)
                utils.feed_keys("<CR>")
            end,
        })

        popup:show()

        utils.feed_keys("u")
        assert.equals("UNFORGIVEN", myvar)
    end)
end)

local PopUp = require("stormcaller.api.unforgiven")
local h = require("stormcaller.helpers")

describe("...", function()
    it("...", function()
        h.set_buffer_content_as_multiple_react_components()

        -- local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        -- print(table.concat(lines, "\n"))

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
                --
                print(result)
            end,
        })

        popup:show()

        local popup_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local want = {
            "l LE SSERAFIM",
            "",
            "u UNFORGIVEN",
        }
        assert.same(want, popup_lines)
    end)
end)

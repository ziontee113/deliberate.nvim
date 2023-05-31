local DynamicPopUp = require("stormcaller.lib.ui.DynamicPopUp")
local utils = require("stormcaller.lib.utils")

describe("DynamicPopUp", function()
    it("works", function()
        local final_result

        local popup = DynamicPopUp:new({
            steps = {
                {
                    items = {
                        { keymaps = { "1" }, text = "1st - " },
                        "",
                        { keymaps = { "2" }, text = "2nd - " },
                    },
                    format = function(results, current_item)
                        return string.format("%s - %s", results[1], current_item.text)
                    end,
                },
                {
                    items = {
                        { keymaps = { "l" }, text = "LE SSERAFIM" },
                        "",
                        { keymaps = { "u" }, text = "UNFORGIVEN" },
                    },
                    callback = function(results) final_result = table.concat(results, "") end,
                },
            },
        })

        popup:show()
        utils.feed_keys("1")
        utils.feed_keys("l")

        assert.equals("1st - LE SSERAFIM", final_result)
    end)
end)

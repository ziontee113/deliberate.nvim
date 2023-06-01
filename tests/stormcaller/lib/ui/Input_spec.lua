local Input = require("stormcaller.lib.ui.Input")
local utils = require("stormcaller.lib.utils")
local helpers = require("stormcaller.helpers")
local feed = utils.feed_keys
local insert = helpers.insert_chars_for_Input

describe("Input", function()
    it("...", function()
        local myvar

        local input = Input:new({
            callback = function(result) myvar = result end,
        })

        input:show()

        insert(input.buf, "okman")
        feed("<CR>")

        assert.equals("okman", myvar)
    end)
end)

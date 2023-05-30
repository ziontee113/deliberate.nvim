local Input = require("stormcaller.lib.ui.Input")
local u = require("stormcaller.lib.utils")
local feed = u.feed_keys
local h = require("stormcaller.helpers")
local insert = h.insert_chars_for_Input

describe("Input", function()
    it("...", function()
        local myvar

        local input = Input:new({
            callback = function(result)
                myvar = result
                print(result)
            end,
        })

        input:show()

        insert(input.buf, "okman")
        feed("<CR>")

        assert.equals("okman", myvar)
    end)
end)

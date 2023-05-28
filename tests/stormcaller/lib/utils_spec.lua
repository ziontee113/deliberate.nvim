local utils = require("stormcaller.lib.utils")

describe("utils.get_count() & utils.reset_count()", function()
    it("works", function()
        vim.cmd("norm! 4")
        assert.equals(4, utils.get_count())

        utils.reset_count()
        assert.equals(1, utils.get_count())
    end)
end)

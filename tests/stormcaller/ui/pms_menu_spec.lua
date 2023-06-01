local pms = require("stormcaller.ui.pms")

local utils = require("stormcaller.lib.utils")
local h = require("stormcaller.helpers")
local initiate = h.initiate

-- describe("...", function()
--     before_each(function() h.set_buffer_content_as_multiple_react_components() end)
--     after_each(function() h.clean_up() end)
--
--     it("...", function()
--         initiate("22gg^", "<li>Contacts</li>")
--
--         pms.change_padding()
--
--         assert.same({
--             "",
--         }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
--     end)
-- end)

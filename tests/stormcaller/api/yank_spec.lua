require("tests.editor_config")

local yank = require("stormcaller.api.yank")
local h = require("stormcaller.helpers")
local mova = h.move_then_assert_selection

describe("paste()", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("works for catalyst selection", function()
        h.initiate("22gg^", "<li>Contacts</li>")
        yank.call()
        assert.same({ { "        <li>Contacts</li>" } }, yank.contents())
    end)

    it("works for multi selection", function()
        h.initiate("22gg^", "<li>Contacts</li>")
        mova({ "previous", true }, 1, "<li>Contacts</li>")
        mova({ "previous", true }, 2, { "<li>Contacts</li>", h.long_li_tag })
        yank.call()
        assert.same({
            { "        <li>Contacts</li>" },
            {
                "        <li>",
                "          A new study found that coffee drinkers have a lower risk of liver",
                "          cancer. So, drink up!",
                "        </li>",
            },
        }, yank.contents())
    end)
end)

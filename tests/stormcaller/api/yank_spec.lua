require("tests.editor_config")

local yank = require("stormcaller.api.yank")
local h = require("stormcaller.helpers")
local mova = h.move_then_assert_selection

describe("yank.call()", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("works for catalyst selection", function()
        h.initiate("22gg^", "<li>Contacts</li>")
        yank.call()
        assert.same({ { "        <li>Contacts</li>" } }, yank.contents())
    end)

    it("works for multi selection, clear selection after yank", function()
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
        h.selection_is(1, "<li>Home</li>")
    end)
end)

describe("yank.call({keep_selection = true})", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("keeps selection after yank", function()
        h.initiate("22gg^", "<li>Contacts</li>")
        mova({ "previous", true }, 1, "<li>Contacts</li>")
        mova({ "previous", true }, 2, { "<li>Contacts</li>", h.long_li_tag })
        yank.call({ keep_selection = true })
        assert.same({
            { "        <li>Contacts</li>" },
            {
                "        <li>",
                "          A new study found that coffee drinkers have a lower risk of liver",
                "          cancer. So, drink up!",
                "        </li>",
            },
        }, yank.contents())
        h.selection_is(2, { "<li>Contacts</li>", h.long_li_tag })
    end)
end)

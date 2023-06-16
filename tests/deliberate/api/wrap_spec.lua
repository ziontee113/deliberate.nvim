require("tests.editor_config")
local selection = require("deliberate.lib.selection")

local wrap = require("deliberate.api.wrap")
local h = require("deliberate.helpers")
local movA = h.move_then_assert_selection

describe("wrap.call()", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("works", function()
        h.initiate("22gg^", "<li>Contacts</li>")
        movA({ "next", true }, 1, "<li>Contacts</li>")
        movA({ "next", true }, 2, { "<li>Contacts</li>", "<li>FAQ</li>" })

        wrap.call({ tag = "div" })
        h.catalyst_has([[<div>
          <li>Contacts</li>
          <li>FAQ</li>
        </div>]])
        h.node_has_text(
            selection.nodes()[1]:parent(),
            [[<div className="h-screen w-screen bg-zinc-900">
        <li>Home</li>
        <li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>
        <div>
          <li>Contacts</li>
          <li>FAQ</li>
        </div>
        <OtherComponent />
      </div>]]
        )
    end)
end)

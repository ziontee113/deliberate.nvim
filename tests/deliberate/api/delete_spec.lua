require("tests.editor_config")

local selection = require("deliberate.lib.selection")
local delete = require("deliberate.api.delete")
local h = require("deliberate.helpers")

describe("delete.call()", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("works", function()
        h.initiate("22gg^", "<li>Contacts</li>")

        delete.call()

        h.catalyst_has("<li>FAQ</li>", { 22, 8 })
        h.node_has_text(
            selection.nodes()[1]:parent(),
            [[<div className="h-screen w-screen bg-zinc-900">
        <li>Home</li>
        <li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>
        <li>FAQ</li>
        <OtherComponent />
      </div>]]
        )
    end)
end)

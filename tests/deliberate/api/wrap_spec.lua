require("tests.editor_config")
local selection = require("deliberate.lib.selection")

local wrap = require("deliberate.api.wrap")
local h = require("deliberate.helpers")
local movA = h.move_then_assert_selection

describe("wrap.call()", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("works for <div> tag", function()
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

    it("works for React Fragment", function()
        h.initiate("22gg^", "<li>Contacts</li>")
        movA({ "next", true }, 1, "<li>Contacts</li>")
        movA({ "next", true }, 2, { "<li>Contacts</li>", "<li>FAQ</li>" })
        wrap.call({ tag = "" })
        h.catalyst_has([[<>
          <li>Contacts</li>
          <li>FAQ</li>
        </>]])
    end)
end)

describe("wrap.call()", function()
    before_each(function()
        vim.bo.ft = "typescriptreact"
        h.set_buf_content([[
export default function Home() {
  return (
    <div className="h-screen w-screen bg-zinc-900 text-white">
      <li>Home</li>
      <li>Contacts</li>
      <li className="absolute bottom-56 bg-top text-9xl">FAQ</li>
    </div>
  )
}]])
    end)
    after_each(function() h.clean_up() end)

    it("works if the tag we wrap is the only html node in the document", function()
        h.initiate(
            "3gg^",
            '<div className="h-screen w-screen bg-zinc-900 text-white">',
            h.catalyst_first
        )

        wrap.call({ tag = "div" })

        h.catalyst_has([[<div>
      <div className="h-screen w-screen bg-zinc-900 text-white">
        <li>Home</li>
        <li>Contacts</li>
        <li className="absolute bottom-56 bg-top text-9xl">FAQ</li>
      </div>
    </div>]])
    end)
end)

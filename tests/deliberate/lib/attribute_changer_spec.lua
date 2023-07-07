require("tests.editor_config")

local attr_changer = require("deliberate.lib.attribute_changer")
local navigator = require("deliberate.api.navigator")
local h = require("deliberate.helpers")

describe("attr_changer", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it(".change() adds attribute correctly", function()
        h.initiate("22gg^", "<li>Contacts</li>")
        attr_changer.change({ attribute = "onClick", content = "{}" })
        h.catalyst_has("<li onClick={}>Contacts</li>")
    end)

    it(".change() replaces attribute correctly", function()
        h.initiate(
            "76gg^",
            [[<Image
          alt=""
          src={image.imageSrc}
          fill
          style={{ objectFit: 'cover' }}
          className={cn(
            'duration-700 ease-in-out group-hover:opacity-75',
            isLoading
              ? 'scale-110 blur-2xl grayscale'
              : 'scale-100 blur-0 grayscale-0'
          )}
          onLoadingComplete={() => setLoading(false)}
        />]]
        )

        attr_changer.change({ attribute = "className", content = '"p-4"' })

        h.catalyst_has([[<Image
          alt=""
          src={image.imageSrc}
          fill
          style={{ objectFit: 'cover' }}
          className="p-4"
          onLoadingComplete={() => setLoading(false)}
        />]])
    end)

    it(".remove() removes attribute correctly for single selection", function()
        h.initiate("16gg^", '<div className="h-screen w-screen bg-zinc-900">', h.catalyst_first)
        attr_changer.remove("className")
        h.catalyst_first("<div>")
    end)

    it(".remove() removes attribute correctly for multiple selection", function()
        h.initiate(
            "90gg^",
            '<h3 className="mt-4 text-sm text-gray-700">{image.name}</h3>',
            h.catalyst_first
        )
        navigator.move({ destination = "next", select_move = true })
        navigator.move({ destination = "next", select_move = true })
        attr_changer.remove("className")
        h.selection_is(2, {
            "<h3>{image.name}</h3>",
            "<p>{image.username}</p>",
        })
    end)
end)

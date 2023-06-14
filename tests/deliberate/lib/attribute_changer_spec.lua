require("tests.editor_config")

local attr_changer = require("deliberate.lib.attribute_changer")
local h = require("deliberate.helpers")

describe("attr_changer.change()", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("works", function()
        h.initiate("22gg^", "<li>Contacts</li>")
        attr_changer.change({ attribute = "onClick", content = "{}" })
        h.catalyst_has("<li onClick={}>Contacts</li>")
    end)

    it("works", function()
        h.initiate("76gg^", [[<Image
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
        />]])

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
end)

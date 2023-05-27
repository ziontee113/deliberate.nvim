require("tests.editor_config")

local h = require("stormcaller.helpers")
local initiate = h.initiate_and_check_cursor_positon

describe("catalyst.initiate() for tsx", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it(
        "puts cursor at start of closest tag, with initial cursor inside html_element",
        function() initiate("19gg0ff", "<li>", h.catalyst_first, { 18, 8 }) end
    )
    it(
        "puts cursor at start of closest tag, with initial cursor outside and above html_element",
        function() initiate("gg0", "<p>", h.catalyst_first, { 3, 4 }) end
    )
    it(
        "puts cursor at end of closest tag, with initial cursor outside and below html_element",
        function() initiate("28gg0", "    </>", h.catalyst_last, { 26, 6 }) end
    )
    it(
        [[puts cursor at end of closest html_element
because initial cursor was sandwiched between html_elements and was below closest html_element ]],
        function() initiate("8gg0", "    </p>", h.catalyst_last, { 6, 7 }) end
    )
    it(
        [[puts cursor at start of closest html_element
because initial cursor was sandwiched between html_elements and was above closest html_element ]],
        function() initiate("12gg0", "<>", h.catalyst_first, { 15, 4 }) end
    )
end)

describe("catalyst.initiate() for svelte()", function()
    before_each(function() h.set_buffer_content_as_svelte_file() end)
    after_each(function() h.clean_up() end)

    it(
        "puts cursor at start of closest tag, initial cursor inside html_element",
        function() initiate("32ggfm", "<h1>Ligma</h1>", h.catalyst_has, { 32, 4 }) end
    )
    it(
        "puts cursor at start of closest tag, initial cursor outside and above html_element",
        function()
            initiate(
                "30gg",
                [[<section>
    <h1>Ligma</h1>
    <h3>is a made-up term</h3>
    <p>that gained popularity as part of an Internet prank or meme.</p>
</section>]],
                h.catalyst_has,
                { 31, 0 }
            )
        end
    )
    it(
        "puts cursor at end of closest tag, with initial cursor outside and below html_element",
        function()
            initiate(
                "43gg",
                [[<section>
    <h1>Ligma</h1>
    <h3>is a made-up term</h3>
    <p>that gained popularity as part of an Internet prank or meme.</p>
</section>]],
                h.catalyst_has,
                { 35, 9 }
            )
        end
    )
end)

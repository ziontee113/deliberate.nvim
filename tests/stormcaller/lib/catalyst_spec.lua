require("tests.editor_config")

local catalyst = require("stormcaller.lib.catalyst")
local helpers = require("stormcaller.helpers")

local initiate = helpers.initiate_and_check_cursor_positon

describe("catalyst.initiate() for tsx", function()
    before_each(function() helpers.set_buffer_content_as_multiple_react_components() end)
    after_each(function() helpers.clean_up() end)

    it(
        "puts cursor at start of closest tag, with initial cursor inside html_element",
        function()
            initiate(
                "19gg0ff",
                "<li>",
                helpers.assert_first_line_of_catalyst_node_has_text,
                { 18, 8 }
            )
        end
    )
    it(
        "puts cursor at start of closest tag, with initial cursor outside and above html_element",
        function()
            initiate("gg0", "<p>", helpers.assert_first_line_of_catalyst_node_has_text, { 3, 4 })
        end
    )
    it(
        "puts cursor at end of closest tag, with initial cursor outside and below html_element",
        function()
            initiate(
                "28gg0",
                "    </>",
                helpers.assert_last_line_of_catalyst_node_has_text,
                { 26, 6 }
            )
        end
    )
    it(
        [[puts cursor at end of closest html_element
because initial cursor was sandwiched between html_elements and was below closest html_element ]],
        function()
            initiate(
                "8gg0",
                "    </p>",
                helpers.assert_last_line_of_catalyst_node_has_text,
                { 6, 7 }
            )
        end
    )
    it(
        [[puts cursor at start of closest html_element
because initial cursor was sandwiched between html_elements and was above closest html_element ]],
        function()
            initiate("12gg0", "<>", helpers.assert_first_line_of_catalyst_node_has_text, { 15, 4 })
        end
    )
end)

describe("catalyst.initiate() for svelte()", function()
    before_each(function() helpers.set_buffer_content_as_svelte_file() end)
    after_each(function() helpers.clean_up() end)

    it("puts cursor at start of closest tag, initial cursor inside html_element", function()
        vim.cmd("norm! 32ggfm")
        catalyst.initiate({ win = 0, buf = 0 })

        helpers.assert_catalyst_node_has_text("<h1>Ligma</h1>")
        assert.same({ 32, 4 }, vim.api.nvim_win_get_cursor(0))
    end)

    it(
        "puts cursor at start of closest tag, initial cursor outside and above html_element",
        function()
            vim.cmd("norm! 30gg")
            catalyst.initiate({ win = 0, buf = 0 })

            helpers.assert_catalyst_node_has_text([[<section>
    <h1>Ligma</h1>
    <h3>is a made-up term</h3>
    <p>that gained popularity as part of an Internet prank or meme.</p>
</section>]])
            assert.same({ 31, 0 }, vim.api.nvim_win_get_cursor(0))
        end
    )

    it(
        "puts cursor at end of closest tag, with initial cursor outside and below html_element",
        function()
            vim.cmd("norm! 43gg")
            catalyst.initiate({ win = 0, buf = 0 })

            helpers.assert_catalyst_node_has_text([[<section>
    <h1>Ligma</h1>
    <h3>is a made-up term</h3>
    <p>that gained popularity as part of an Internet prank or meme.</p>
</section>]])
            assert.same({ 35, 9 }, vim.api.nvim_win_get_cursor(0))
        end
    )
end)

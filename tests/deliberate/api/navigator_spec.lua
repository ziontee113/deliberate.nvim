require("tests.editor_config")

local utils = require("deliberate.lib.utils")
local navigator = require("deliberate.api.navigator")

local h = require("deliberate.helpers")
local initiate = h.initiate
local move = h.move
local move_then_assert_selection = h.move_then_assert_selection
local first_line = h.catalyst_first
local last_line = h.catalyst_last

-------------------------------------------- Typescriptreact

describe("typescriptreact navigator.move()", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("direction = next-sibling", function()
        initiate("17gg^", "<li>Home</li>")
        move("next-sibling", h.long_li_tag, { 18, 8 })
        move("next-sibling", "<li>Contacts</li>", { 22, 8 })
        move("next-sibling", "<li>FAQ</li>", { 23, 8 })
        move("next-sibling", "<OtherComponent />", { 24, 8 })
        move("next-sibling", "<OtherComponent />", { 24, 8 }) -- stays in place since no next siblings
    end)

    it("direction = previous-sibling", function()
        initiate("23gg^", "<li>FAQ</li>")
        move("previous-sibling", "<li>Contacts</li>", { 22, 8 })
        move("previous-sibling", h.long_li_tag, { 18, 8 }) -- put cursor at start of tag since destination has "sibling" in it
        move("previous-sibling", "<li>Home</li>", { 17, 8 })
        move("previous-sibling", "<li>Home</li>", { 17, 8 }) -- stays in place since no more prevous sibling
    end)

    it("direction = next", function()
        initiate("16gg", '<div className="h-screen w-screen bg-zinc-900">', first_line)
        move("next", "<li>Home</li>", { 17, 8 })
        move("next", h.long_li_tag, { 18, 8 })
        move("next", "<li>Contacts</li>", { 22, 8 })
        move("next", "<li>FAQ</li>", { 23, 8 })
        move("next", "<OtherComponent />", { 24, 8 })
        move("next", "      </div>", { 25, 11 }, last_line)
        move("next", "    </>", { 26, 6 }, last_line)
        move("next", "<div>", { 34, 4 }, first_line) --> should jump to next html Component
        move("next", "<ul>", { 35, 6 }, first_line)
    end)

    it("direction = previous", function()
        initiate("22gg^", "<li>Contacts</li>")
        move("previous", h.long_li_tag, { 21, 12 })
        move("previous", "<li>Home</li>", { 17, 8 })
        move("previous", '<div className="h-screen w-screen bg-zinc-900">', { 16, 6 }, first_line)
        move("previous", "<>", { 15, 4 }, first_line)
        move("previous", "    </p>", { 6, 7 }, last_line)
    end)

    it("direction = next & previous", function()
        initiate("3gg^", "<p>", first_line)
        move("next", "<>", { 15, 4 }, first_line)
        move("next", '<div className="h-screen w-screen bg-zinc-900">', { 16, 6 }, first_line)
        move("next", "<li>Home</li>", { 17, 8 })
        move("next", h.long_li_tag, { 18, 8 })
        move("next", "<li>Contacts</li>", { 22, 8 })
        move("next", "<li>FAQ</li>", { 23, 8 })
        move("next", "<OtherComponent />", { 24, 8 })
        move("next", "      </div>", { 25, 11 }, last_line)
        move("next", "    </>", { 26, 6 }, last_line)
        move("previous", "      </div>", { 25, 11 }, last_line)
    end)

    it("direction = parent", function()
        initiate("22gg^", "<li>Contacts</li>")
        move("parent", '<div className="h-screen w-screen bg-zinc-900">', { 16, 6 }, first_line)
        move("parent", "<>", { 15, 4 }, first_line)
        move("parent", "<>", { 15, 4 }, first_line) -- stands still since no more html parent from here
    end)

    it("direction = next / previous, children inside jsx_expression", function()
        local div_content =
            [[<div className="grid grid-cols-1 gap-x-6 gap-y-10 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 xl:gap-x-8">
        {images.map((image) => (
          <BlurImage key={image.id} image={image}></BlurImage>
        ))}
      </div>]]
        initiate("61gg^", div_content)
        move("next", "<BlurImage key={image.id} image={image}></BlurImage>", { 63, 10 })
        move("next", div_content, { 65, 11 })
        move("previous", "<BlurImage key={image.id} image={image}></BlurImage>", { 63, 10 })
        move("previous", div_content, { 61, 6 })
    end)
end)

-- Trying out `navigator.move()` interaction with vim count.
describe("typescriptreact navigator.move() with count", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("direction = next", function()
        initiate("17gg^", "<li>Home</li>")

        vim.cmd("norm! 2")
        utils.execute_with_count(navigator.move, { destination = "next" })
        h.catalyst_has("<li>Contacts</li>")

        vim.cmd("norm! 2")
        utils.execute_with_count(navigator.move, { destination = "previous" })
        h.catalyst_has("<li>Home</li>")

        vim.cmd("norm! 4")
        utils.execute_with_count(navigator.move, { destination = "next" })
        h.catalyst_has("<OtherComponent />")
    end)
end)

-------------------------------------------- Svelte

describe("navigator.move() with `select_move` option", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("update `selected_nodes` correctly without using `select_move` option", function()
        initiate("17gg^", "<li>Home</li>")
        move_then_assert_selection("next", 1, h.long_li_tag, h.long_li_tag)
        move_then_assert_selection("next", 1, "<li>Contacts</li>", "<li>Contacts</li>")
        move_then_assert_selection("next", 1, "<li>FAQ</li>", "<li>FAQ</li>")
    end)

    it("update `selection.nodes()` correctly with `select_move` option used", function()
        initiate("17gg^", "<li>Home</li>")
        -- next with `select_move`, selection set to <li>Home</li>, then catalyst moves to long_li_tag
        move_then_assert_selection({ "next", true }, 1, { "<li>Home</li>" }, h.long_li_tag)
        -- next MOVE ONLY, catalyst moves, selection stays the same
        move_then_assert_selection("next", 1, { "<li>Home</li>" }, "<li>Contacts</li>")
        -- next with `select_move`, adding <li>Contacts</li> to selection, then catalyst moves to <li>FAQ</li>
        move_then_assert_selection({ "next", true }, 2, {
            "<li>Home</li>",
            "<li>Contacts</li>",
        }, "<li>FAQ</li>")
        -- next with `select_move`, adding <li>FAQ</li> to selection, then catalyst moves to <OtherComponent />
        move_then_assert_selection({ "next", true }, 3, {
            "<li>Home</li>",
            "<li>Contacts</li>",
            "<li>FAQ</li>",
        }, "<OtherComponent />")
    end)
end)

describe("navigator.move() with in-line HTML elements", function()
    local h2_tag = [[<h2>
    try editing <strong>src/<i>routes</i>/+page.svelte</strong>
</h2>]]

    before_each(function()
        vim.bo.ft = "svelte"
        h.set_buf_content(h2_tag)
    end)
    after_each(function() h.clean_up() end)

    it("works", function()
        h.initiate("0gg^", h2_tag)
        move("next", "<strong>src/<i>routes</i>/+page.svelte</strong>", { 2, 16 })
        move("next", "<i>routes</i>", { 2, 28 })
        move("next", "<strong>src/<i>routes</i>/+page.svelte</strong>", { 2, 62 })
        move("next", h2_tag, { 3, 4 })
    end)
end)

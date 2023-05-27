require("tests.editor_config")

local selection = require("stormcaller.lib.selection")
local navigator = require("stormcaller.api.navigator")
local helpers = require("stormcaller.helpers")

local initiate = helpers.initiate

local move = function(destination, wanted_text, position, assert_fn)
    navigator.move({ destination = destination })
    assert_fn = assert_fn or helpers.catalyst_has
    assert_fn(wanted_text)
    assert.are.same(position, vim.api.nvim_win_get_cursor(0))
end

local long_li_tag = [[<li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>]]
local first_line = helpers.catalyst_first
local last_line = helpers.catalyst_last

describe("typescriptreact navigator.move()", function()
    before_each(function() helpers.set_buffer_content_as_multiple_react_components() end)
    after_each(function() helpers.clean_up() end)

    it("direction = next-sibling", function()
        initiate("17gg^", "<li>Home</li>")
        move("next-sibling", long_li_tag, { 18, 8 })
        move("next-sibling", "<li>Contacts</li>", { 22, 8 })
        move("next-sibling", "<li>FAQ</li>", { 23, 8 })
        move("next-sibling", "<OtherComponent />", { 24, 8 })
        move("next-sibling", "<OtherComponent />", { 24, 8 }) -- stays in place since no next siblings
    end)

    it("direction = previous-sibling", function()
        initiate("23gg^", "<li>FAQ</li>")
        move("previous-sibling", "<li>Contacts</li>", { 22, 8 })
        move("previous-sibling", long_li_tag, { 21, 12 }) -- put cursor at end of tag since we're moving up and target start and end not on same line
        move("previous-sibling", "<li>Home</li>", { 17, 8 })
        move("previous-sibling", "<li>Home</li>", { 17, 8 }) -- stays in place since no more prevous sibling
    end)

    it("direction = next", function()
        initiate("16gg", '<div className="h-screen w-screen bg-zinc-900">', first_line)
        move("next", "<li>Home</li>", { 17, 8 })
        move("next", long_li_tag, { 18, 8 })
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
        move("previous", long_li_tag, { 21, 12 })
        move("previous", "<li>Home</li>", { 17, 8 })
        move("previous", '<div className="h-screen w-screen bg-zinc-900">', { 16, 6 }, first_line)
        move("previous", "<>", { 15, 4 }, first_line)
        move("previous", "    </p>", { 6, 7 }, last_line)
    end)

    it("direction = parent", function()
        initiate("22gg^", "<li>Contacts</li>")
        move("parent", '<div className="h-screen w-screen bg-zinc-900">', { 16, 6 }, first_line)
        move("parent", "<>", { 15, 4 }, first_line)
        move("parent", "<>", { 15, 4 }, first_line) -- stands still since no more html parent from here
    end)
end)

local move_then_assert_selection = function(opts, quantity, text_tbl, catalyst_text)
    if type(opts) == "string" then
        opts = { destination = opts }
    elseif type(opts) == "table" then
        opts = { destination = opts[1], select_move = opts[2] }
    end
    navigator.move(opts)

    assert.equals(#selection.nodes(), quantity)

    if type(text_tbl) == "string" then text_tbl = { text_tbl } end
    for i, item in ipairs(text_tbl) do
        if type(item) == "string" then
            helpers.node_has_text(selection.nodes()[i], item)
        else
            local text, assert_fn = unpack(item)
            assert_fn(selection.nodes()[i], text)
        end
    end

    helpers.catalyst_has(catalyst_text)
end

describe("navigator.move() with `select_move` option", function()
    before_each(function() helpers.set_buffer_content_as_multiple_react_components() end)
    after_each(function() helpers.clean_up() end)

    it("update `selected_nodes` correctly without using `select_move` option", function()
        initiate("17gg^", "<li>Home</li>")
        move_then_assert_selection("next", 1, long_li_tag, long_li_tag)
        move_then_assert_selection("next", 1, "<li>Contacts</li>", "<li>Contacts</li>")
        move_then_assert_selection("next", 1, "<li>FAQ</li>", "<li>FAQ</li>")
    end)

    it("update `selection.nodes()` correctly with `select_move` option used", function()
        initiate("17gg^", "<li>Home</li>")
        -- next with `select_move`, selection set to <li>Home</li>, then catalyst moves to long_li_tag
        move_then_assert_selection({ "next", true }, 1, { "<li>Home</li>" }, long_li_tag)
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

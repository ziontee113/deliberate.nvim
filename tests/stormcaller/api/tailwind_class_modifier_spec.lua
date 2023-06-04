require("tests.editor_config")

local tcm = require("stormcaller.api.tailwind_class_modifier")
local h = require("stormcaller.helpers")
local initiate = h.initiate
local move = h.move
local mova = h.move_then_assert_selection
local selection_is = h.selection_is

--------------------------------------------

local change_class = function(fn, args, node_text, assert_fn)
    if type(args) == "string" then
        fn({ value = args })
    elseif type(args) == "table" then
        fn({ axis = args[1], value = args[2] })
    end
    assert_fn = assert_fn or h.catalyst_has
    assert_fn(node_text)
end
local cp = function(a, t, f) change_class(tcm.change_padding, a, t, f) end
local cm = function(a, t, f) change_class(tcm.change_margin, a, t, f) end
local cs = function(a, t, f) change_class(tcm.change_spacing, a, t, f) end
local tc = function(a, t, f) change_class(tcm.change_text_color, a, t, f) end
local bc = function(a, t, f) change_class(tcm.change_background_color, a, t, f) end

-------------------------------------------- Typescriptreact

describe("change_padding()", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("adds className property and specified class for tag with no classNames", function()
        initiate("22gg^", "<li>Contacts</li>")
        cp({ "", "p-4" }, '<li className="p-4">Contacts</li>')
    end)

    it("adds className property and specified class for tag with no classNames", function()
        initiate("22gg^", "<li>Contacts</li>")
        cp({ "", "p-4" }, '<li className="p-4">Contacts</li>')
        move("next", "<li>FAQ</li>")
        cp({ "", "p-8" }, '<li className="p-8">FAQ</li>')
        move("previous", '<li className="p-4">Contacts</li>')
        move("previous", "<li>", nil, h.catalyst_first)
        move("previous", "<li>Home</li>")
        cp({ "", "p-6" }, '<li className="p-6">Home</li>')
    end)

    it("appends specified class for tag that already has classNames", function()
        initiate("90gg^", '<h3 className="mt-4 text-sm text-gray-700">{image.name}</h3>')
        cp({ "", "p-4" }, '<h3 className="mt-4 text-sm text-gray-700 p-4">{image.name}</h3>')
    end)

    it("replaces equivalent padding omni axis using arbitrary value", function()
        initiate("22gg^", "<li>Contacts</li>")
        cp({ "", "p-[20px]" }, '<li className="p-[20px]">Contacts</li>')
        cp({ "", "p-8" }, '<li className="p-8">Contacts</li>')
    end)

    it("replaces equivalent padding axis in-place", function()
        initiate(
            "60gg^",
            '<div className="mx-auto max-w-2xl px-4 py-16 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">',
            h.catalyst_first
        )
        cp(
            { "x", "px-7" },
            '<div className="mx-auto max-w-2xl px-7 py-16 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">',
            h.catalyst_first
        )
        cp(
            { "y", "py-7" },
            '<div className="mx-auto max-w-2xl px-7 py-7 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">',
            h.catalyst_first
        )
    end)

    it("removes equivalent padding axis if value passed in is empty string", function()
        initiate(
            "60gg^",
            '<div className="mx-auto max-w-2xl px-4 py-16 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">',
            h.catalyst_first
        )
        cp(
            { "x", "" },
            '<div className="mx-auto max-w-2xl py-16 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">',
            h.catalyst_first
        )
        cp(
            { "y", "" },
            '<div className="mx-auto max-w-2xl sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">',
            h.catalyst_first
        )
    end)
end)

describe("change_padding() for all `selected_nodes`", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("works", function()
        initiate("22gg^", "<li>Contacts</li>")
        mova({ "next", true }, 1, "<li>Contacts</li>")
        mova({ "next", true }, 2, { "<li>Contacts</li>", "<li>FAQ</li>" })

        tcm.change_padding({ axis = "", value = "p-4" })
        selection_is(2, {
            '<li className="p-4">Contacts</li>',
            '<li className="p-4">FAQ</li>',
        })
        tcm.change_padding({ axis = "", value = "p-20" })
        selection_is(2, {
            '<li className="p-20">Contacts</li>',
            '<li className="p-20">FAQ</li>',
        })
        tcm.change_padding({ axis = "y", value = "py-4" })
        selection_is(2, {
            '<li className="p-20 py-4">Contacts</li>',
            '<li className="p-20 py-4">FAQ</li>',
        })
    end)
end)

describe("change_margin() & change_spacing()", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("adds margin and spacing classes correctly", function()
        initiate("22gg^", "<li>Contacts</li>")
        cm({ "", "m-4" }, '<li className="m-4">Contacts</li>')
        cs({ "x", "space-x-4" }, '<li className="m-4 space-x-4">Contacts</li>')
    end)
end)

describe("change_text_color() & change_background_color()", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("adds text-color and background-color classes correctly", function()
        initiate("22gg^", "<li>Contacts</li>")
        tc("text-zinc-400", '<li className="text-zinc-400">Contacts</li>')
        bc("bg-black", '<li className="text-zinc-400 bg-black">Contacts</li>')
        tc("text-[#000]", '<li className="text-[#000] bg-black">Contacts</li>')
        bc("bg-[rgb(0,12,24)]", '<li className="text-[#000] bg-[rgb(0,12,24)]">Contacts</li>')
        tc("", '<li className="bg-[rgb(0,12,24)]">Contacts</li>')
        bc("", '<li className="">Contacts</li>')
    end)

    it("adds text-color to all selected elements correctly", function()
        initiate("17gg^", "<li>Home</li>")
        mova({ "next", true }, 1, "<li>Home</li>")
        mova("next", 1, "<li>Home</li>")
        mova({ "next", true }, 2, { "<li>Home</li>", "<li>Contacts</li>" })

        tcm.change_text_color({ value = "text-red-200" })
        selection_is(2, {
            '<li className="text-red-200">Home</li>',
            '<li className="text-red-200">Contacts</li>',
        })
    end)
end)

describe("change Classes Groups", function()
    before_each(function() h.set_buffer_content_as_multiple_react_components() end)
    after_each(function() h.clean_up() end)

    it("works on current catalyst", function()
        initiate("17gg^", "<li>Home</li>")
        tcm.change_classes_groups({ classes_groups = { "flex", "flex row" }, value = "flex" })
        h.catalyst_has('<li className="flex">Home</li>')
    end)
end)

-------------------------------------------- Svelte

describe("change_padding()", function()
    before_each(function() h.set_buffer_content_as_svelte_file() end)
    after_each(function() h.clean_up() end)

    it("adds class property and specified class for tag with no classNames", function()
        initiate("32gg^", "<h1>Ligma</h1>")
        cp({ "", "p-4" }, '<h1 class="p-4">Ligma</h1>')
    end)

    it("append / replace specified class for tag that already has classNames", function()
        initiate("14gg^", '<span class="welcome">', h.catalyst_first)
        cp({ "", "p-4" }, '<span class="welcome p-4">', h.catalyst_first)
        cp({ "", "p-8" }, '<span class="welcome p-8">', h.catalyst_first)
        cp({ "x", "px-16" }, '<span class="welcome p-8 px-16">', h.catalyst_first)
        cp({ "", "p-4" }, '<span class="welcome p-4 px-16">', h.catalyst_first)
    end)

    it("removes equivalent padding axis if value passed in is empty string", function()
        initiate("14gg^", '<span class="welcome">', h.catalyst_first)
        cp({ "", "p-4" }, '<span class="welcome p-4">', h.catalyst_first)
        cp({ "", "" }, '<span class="welcome">', h.catalyst_first)
    end)
end)

describe("change_margin() & change_spacing()", function()
    before_each(function() h.set_buffer_content_as_svelte_file() end)
    after_each(function() h.clean_up() end)

    it("adds / replace margin and spacing classes correctly", function()
        initiate("14gg^", '<span class="welcome">', h.catalyst_first)
        cm({ "", "m-4" }, '<span class="welcome m-4">', h.catalyst_first)
        cm({ "y", "my-40" }, '<span class="welcome m-4 my-40">', h.catalyst_first)
        cp({ "y", "py-20" }, '<span class="welcome m-4 my-40 py-20">', h.catalyst_first)
    end)
end)

describe("change_text_color() & change_background_color()", function()
    before_each(function() h.set_buffer_content_as_svelte_file() end)
    after_each(function() h.clean_up() end)

    it("adds / replace margin and spacing classes correctly", function()
        initiate("14gg^", '<span class="welcome">', h.catalyst_first)
        tc("text-white", '<span class="welcome text-white">', h.catalyst_first)
        bc("bg-gray-400", '<span class="welcome text-white bg-gray-400">', h.catalyst_first)
    end)
end)

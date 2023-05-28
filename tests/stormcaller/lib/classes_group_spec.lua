local classes_group = require("stormcaller.lib.classes_group")

local test = function(current_str, choice, tbl, want)
    local new_str = classes_group.apply(current_str, tbl, choice)
    assert.equals(want, new_str)
end

describe("classes_group.apply()", function()
    local tbl = { "flex", "flex row" }
    it("works", function()
        test("", "flex", tbl, "flex")
        test("flex", "flex row", tbl, "flex row")
        test("py-4", "flex row", tbl, "py-4 flex row")
        test("py-4", "flex    row", tbl, "py-4 flex row")
    end)
end)

local transformer = require("deliberate.lib.arbitrary_transformer")

describe("input_to_color()", function()
    it("returns raw input if it matches css colors", function()
        assert.equals("red", transformer.input_to_color("red"))
        assert.equals("blue", transformer.input_to_color("blue"))
    end)
    it("transforms input with 2 comma separated numbers to rgb()", function()
        local input = "222,11,0"
        local want = "rgb(222,11,0)"
        assert.equals(want, transformer.input_to_color(input))
    end)
    it("transforms input with 3 comma separated numbers to rgba()", function()
        local input = "222,11,0,10"
        local want = "rgba(222,11,0,10%)"
        assert.equals(want, transformer.input_to_color(input))
    end)

    it("transforms input with 2 dots separated numbers to hsl()", function()
        local input = "222.11.10"
        local want = "hsl(222,11%,10%)"
        assert.equals(want, transformer.input_to_color(input))
    end)
    it("transforms input with 3 dots separated numbers to hsla()", function()
        local input = "222.11.10.10"
        local want = "hsla(222,11%,10%,10%)"
        assert.equals(want, transformer.input_to_color(input))
    end)

    it("transforms input with no comma or dot to hex color", function()
        local input = "000"
        local want = "#000"
        assert.equals(want, transformer.input_to_color(input))
    end)
end)

describe("input_to_pms_value()", function()
    it("given only numbers, return input value with px unit", function()
        local input = "99"
        local want = "99px"
        assert.equals(want, transformer.input_to_pms_value(input))
    end)
    it("given numbers input and x as last character, return input value with px unit", function()
        local input = "99x"
        local want = "99px"
        assert.equals(want, transformer.input_to_pms_value(input))
    end)
    it("given numbers input and r as last characters, return input value with rem unit", function()
        local input = "10r"
        local want = "10rem"
        assert.equals(want, transformer.input_to_pms_value(input))
    end)
    it("given numbers input and w as last character, return input value with vw unit", function()
        local input = "99w"
        local want = "99vw"
        assert.equals(want, transformer.input_to_pms_value(input))
    end)
end)

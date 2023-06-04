local mixer = require("deliberate.lib.pseudo_classes.mixer")

describe("translate_alias_string", function()
    it("returns empty string if input is empty", function()
        local input = ""
        local want = ""
        local got = mixer.translate_alias_string(input)
        assert.equals(want, got)
    end)
    it("works with 1 alias", function()
        local input = "h"
        local want = "hover:"
        local got = mixer.translate_alias_string(input)
        assert.equals(want, got)
    end)
    it("works with 2 aliases", function()
        local input = "sh"
        local want = "sm:hover:"
        local got = mixer.translate_alias_string(input)
        assert.equals(want, got)
    end)
    it("works with 3 aliases", function()
        local input = "shfl"
        local want = "sm:hover:first-letter:"
        local got = mixer.translate_alias_string(input)
        assert.equals(want, got)
    end)
    it("works with 5 aliases", function()
        local input = "hfoacvt"
        local want = "hover:focus:active:visited:target:"
        local got = mixer.translate_alias_string(input)
        assert.equals(want, got)
    end)
end)

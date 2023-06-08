require("tests.editor_config")

local lua_patterns = require("deliberate.lib.lua_patterns")

local patterns_matches_inputs = function(patterns, inputs)
    for _, input in ipairs(inputs) do
        local result = false
        for _, pattern in ipairs(patterns) do
            if string.match(input, pattern) then
                result = true
                break
            end
        end
        assert.equals(true, result)
    end
end

describe("padding pattern", function()
    it("matches omni axis correctly", function()
        local inputs = { "p-4", "p-69", "p-[20px]", "p-[4rem]", "p-[4pt]", "p-[10vh]" }
        patterns_matches_inputs(lua_patterns.padding[""], inputs)
    end)
    it("matches y axis correctly", function()
        local inputs = { "py-4", "py-69", "py-[20px]", "py-[4rem]", "py-[4pt]", "py-[10vh]" }
        patterns_matches_inputs(lua_patterns.padding["y"], inputs)
    end)
    it("matches all axies correctly", function()
        local inputs = { "py-4", "p-69", "pt-[20px]", "pb-[4rem]", "py-[4pt]", "pl-[10vh]" }
        patterns_matches_inputs(lua_patterns.padding["all"], inputs)
    end)
    it("matches values float values", function()
        local inputs = { "py-1.5", "p-0.6", "pt-[12.5em]", "pb-[4rem]", "py-[4.5pt]", "p-[10.2vh]" }
        patterns_matches_inputs(lua_patterns.padding["all"], inputs)
    end)
end)

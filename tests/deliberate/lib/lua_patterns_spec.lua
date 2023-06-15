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
        assert.equals(true, result, string.format("failed at: %s", input))
    end
end

describe("padding pattern", function()
    it("matches omni axis correctly", function()
        local inputs = { "p-4", "p-69", "p-[20px]", "p-[4rem]", "p-[4pt]", "p-[10vh]" }
        patterns_matches_inputs(lua_patterns.p[""], inputs)
    end)
    it("matches y axis correctly", function()
        local inputs = { "py-4", "py-69", "py-[20px]", "py-[4rem]", "py-[4pt]", "py-[10vh]" }
        patterns_matches_inputs(lua_patterns.p["y"], inputs)
    end)
    it("matches values float values", function()
        local inputs = { "py-1.5", "py-0.6", "py-[12.5em]", "py-[4.5pt]", "py-[10.2vh]" }
        patterns_matches_inputs(lua_patterns.p["y"], inputs)
    end)
end)

describe("divide pattern", function()
    it("matches x axis correctly", function()
        local inputs = { "divide-x-2", "divide-x-0" }
        patterns_matches_inputs(lua_patterns.divide["x"], inputs)
    end)
end)

describe("rounded pattern", function()
    it("matches omni axis correctly", function()
        local inputs = { "rounded-[22px]", "rounded", "rounded-xl" }
        patterns_matches_inputs(lua_patterns.rounded[""], inputs)
    end)
end)

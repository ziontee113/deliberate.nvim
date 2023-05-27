require("tests.editor_config")

local lua_patterns = require("stormcaller.lib.lua_patterns")

local patterns_matches_inputs = function(patterns, inputs)
    local result = false
    for _, pattern in ipairs(patterns) do
        for _, input in ipairs(inputs) do
            if string.match(input, pattern) then result = true end
        end
    end
    assert.equals(true, result)
end

describe("Lua patterns for Tailwind PMS classes", function()
    it("padding pattern for omni axis works correctly", function()
        local inputs = { "p-4", "p-69", "p-[20px]", "p-[4rem]", "p-[4pt]", "p-[10vh]" }
        patterns_matches_inputs(lua_patterns.padding["omni"], inputs)
    end)
    it("padding pattern for y axis works correctly", function()
        local inputs = { "py-4", "py-69", "py-[20px]", "py-[4rem]", "py-[4pt]", "py-[10vh]" }
        patterns_matches_inputs(lua_patterns.padding["y"], inputs)
    end)
    it("padding pattern for all axies works correctly", function()
        local inputs = { "py-4", "p-69", "pt-[20px]", "pb-[4rem]", "py-[4pt]", "pl-[10vh]" }
        patterns_matches_inputs(lua_patterns.padding["y"], inputs)
    end)
end)

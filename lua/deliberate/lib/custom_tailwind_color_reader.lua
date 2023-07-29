local Job = require("plenary.job")

local M = {}

M.get_json_data_from_tailwind_config = function()
    local json_result = Job:new({
        command = "node",
        args = { "/home/ziontee113/.config/dev-nvim/deliberate.nvim/read_tailwind_config.js" },
    }):sync()

    local concat = table.concat(json_result, "\n")
    local parsed = vim.json.decode(concat)

    return parsed
end

return M

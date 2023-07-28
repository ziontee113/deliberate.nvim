local reader = require("deliberate.lib.custom_tailwind_color_reader")

describe("reader", function()
    it("can turn tailwind config to lua table", function()
        local parsed_data = reader.get_json_data_from_tailwind_config()
        print(parsed_data)
        print(vim.inspect(parsed_data))
    end)
end)

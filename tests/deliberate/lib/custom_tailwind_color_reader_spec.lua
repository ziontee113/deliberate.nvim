local reader = require("deliberate.lib.custom_tailwind_color_reader")

describe("reader", function()
    it("can read file", function()
        local file_path = "tailwind.config.js"
        local query = [[ ;query
(pair 
  (property_identifier) @theme (#eq? @theme "theme")
  (object
    (pair
      (property_identifier) @extend (#eq? @extend "extend")
      (object
        (pair
          (property_identifier) @colors (#eq? @colors "colors")
          (object) @colors_object
        )
      )
    )
  )
)
        ]]

        local lines = reader.read_lines_from_file(file_path)
        local file_content = table.concat(lines, "\n")
        local root = reader.get_root_from_str(file_content, "javascript")

        local matches = reader.query(table.concat(lines, "\n"), "javascript", root, query)

        for _, e in ipairs(matches) do
            local text = vim.treesitter.get_node_text(e, file_content)
            print(text)
        end
    end)
end)

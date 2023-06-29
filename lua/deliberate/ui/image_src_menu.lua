local PopUp = require("deliberate.lib.ui.PopUp")
local menu_repeater = require("deliberate.api.menu_repeater")
local attribute_changer = require("deliberate.lib.attribute_changer")
local M = {}

-------------------------------------------- Local Functions

local trim_pattern_from_strings = function(paths, pattern)
    local results = {}
    for _, path in ipairs(paths) do
        local trimmed_path = string.gsub(path, pattern, "")
        table.insert(results, trimmed_path)
    end
    return results
end

local find_image_paths = function(callback)
    local cmd = { "fd" }
    local extensions = { "jpg", "png", "svg" }

    for _, extension in ipairs(extensions) do
        table.insert(cmd, "-e")
        table.insert(cmd, extension)
    end

    vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            local paths = {}
            for _, path in ipairs(data) do
                if path ~= "" then table.insert(paths, path) end
            end

            paths = trim_pattern_from_strings(paths, "^public")

            callback(paths)
        end,
    })
end

M._image_src_changer_menu = function(paths)
    menu_repeater.register(M._image_src_changer_menu, paths)

    local items = {}
    for _, path in ipairs(paths) do
        table.insert(items, { text = path })
    end

    local popup = PopUp:new({
        steps = {
            {
                items = items,
                callback = function(_, current_item)
                    attribute_changer.change({
                        attribute = "src",
                        content = string.format('"%s"', current_item.text),
                    })
                end,
            },
        },
    })
    popup:show()
end

-------------------------------------------- Public API

M.change_image_src = function() find_image_paths(M._image_src_changer_menu) end

return M

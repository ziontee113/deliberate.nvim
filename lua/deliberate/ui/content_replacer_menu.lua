local PopUp = require("deliberate.lib.ui.PopUp")
local Input = require("deliberate.lib.ui.Input")
local replacer = require("deliberate.lib.content_replacer")
local menu_repeater = require("deliberate.api.menu_repeater")
local utils = require("deliberate.lib.utils")

local M = {}

-------------------------------------------- Locals

local get_content_groups_from_file = function(file_path)
    local ok, file_lines = pcall(vim.fn.readfile, file_path)
    if not ok then return { { name = "Hello", "World" } } end

    local groups = {}

    for _, line in ipairs(file_lines) do
        if line ~= "" then
            if string.match(line, "^%s+") then
                if #groups > 0 then
                    local trimmed_line = string.gsub(line, "^%s+", "")
                    table.insert(groups[#groups], trimmed_line)
                end
            else
                table.insert(groups, { name = line })
            end
        elseif #groups > 0 then
            table.insert(groups[#groups], "")
        end
    end

    return groups
end

local find_valid_hint = function(content, hint_pool, occupied_hints)
    local first_char = string.sub(content, 1, 1)
    local lowercase_candidate = string.lower(first_char)
    local uppercase_candidate = string.upper(first_char)

    if
        not vim.tbl_contains(occupied_hints, lowercase_candidate)
        and vim.tbl_contains(hint_pool, lowercase_candidate)
    then
        return lowercase_candidate
    elseif
        not vim.tbl_contains(occupied_hints, uppercase_candidate)
        and vim.tbl_contains(hint_pool, uppercase_candidate)
    then
        return uppercase_candidate
    else
        for _, hint in ipairs(hint_pool) do
            if not vim.tbl_contains(occupied_hints, hint) then return hint end
        end
    end
end

-------------------------------------------- PopUps

--stylua: ignore
local valid_hints = {
    "q", "w", "e", "r", "t",
    "a", "s", "d", "f", "g",
    "z", "x", "c", "v", "y",
    "u", "i", "o", "p", "h", "l",
    "n", "m", ",", ".",

    "Q", "W", "E", "R", "T",
    "A", "S", "D", "F", "G",
    "Z", "X", "C", "V", "Y",
    "U", "I", "O", "P",
    "H", "J", "K", "L",
    "N", "M", "<", ">", "?",
}

local get_first_step_items = function(content_groups)
    local items = {}
    local occupied_keymaps = {}

    for _, group in ipairs(content_groups) do
        local text = group.name
        local keymap = find_valid_hint(text, valid_hints, occupied_keymaps)
        table.insert(occupied_keymaps, keymap)
        table.insert(items, { text = text, keymaps = { keymap } })
    end

    table.insert(items, { text = "", clear = true, keymaps = { "0" }, hidden = true })
    table.insert(items, { text = "", keymaps = { "," }, hidden = true, arbitrary = true })

    return items
end

local get_second_step_items = function(content_groups, results)
    local items = {}
    local occupied_keymaps = {}

    local selected_group = {}
    for _, group in ipairs(content_groups) do
        if group.name == results[1] then
            selected_group = group
            break
        end
    end

    for i, text in ipairs(selected_group) do
        if text == "" and i ~= #selected_group then table.insert(items, "") end
        if text ~= "" then
            local keymap = find_valid_hint(text, valid_hints, occupied_keymaps)
            table.insert(occupied_keymaps, keymap)
            table.insert(items, { text = text, keymaps = { keymap } })
        end
    end

    return items
end

local show_arbitrary_input = function(metadata)
    local input = Input:new({
        title = " Content: ",
        width = 20,
        on_change = function(result) replacer.replace(result, false, true) end,
    })

    local row, col = unpack(vim.api.nvim_win_get_position(0))
    input:show(metadata, row, col)
end

M._show_content_replacer_menu = function(file_path)
    menu_repeater.register(M._show_content_replacer_menu, file_path)

    local content_groups = get_content_groups_from_file(file_path)

    local popup = PopUp:new({
        title = "Replace",
        steps = {
            {
                items = get_first_step_items,
                arguments = { content_groups },
                callback = function(_, current_item, metadata)
                    if current_item.arbitrary == true then
                        require("deliberate.lib.selection").archive_for_undo()
                        show_arbitrary_input(metadata)
                        return true
                    end

                    if current_item.clear == true then
                        replacer.replace("")
                        return true
                    end
                end,
            },
            {
                items = get_second_step_items,
                arguments = { content_groups },
                callback = function(_, current_item) replacer.replace(current_item.text) end,
            },
        },
    })

    popup:show()
end

M.replace = function(file_path) M._show_content_replacer_menu(file_path) end

-------------------------------------------- Group Replace

M._show_content_group_replacer_menu = function(file_path, disable_auto_sort)
    menu_repeater.register(M._show_content_group_replacer_menu, file_path)

    local title = disable_auto_sort and "User Order" or "Auto Sorted"
    local content_groups = get_content_groups_from_file(file_path)

    local popup = PopUp:new({
        title = title,
        steps = {
            {
                items = get_first_step_items,
                arguments = { content_groups },
                callback = function(_, current_item)
                    if current_item.clear == true then
                        replacer.replace(utils.remove_empty_strings({}))
                    else
                        for _, group in ipairs(content_groups) do
                            if group.name == current_item.text then
                                replacer.replace(
                                    utils.remove_empty_strings(group),
                                    disable_auto_sort
                                )
                                break
                            end
                        end
                    end
                end,
            },
        },
    })

    popup:show()
end

M.replace_with_group = function(file_path, disable_auto_sort)
    M._show_content_group_replacer_menu(file_path, disable_auto_sort)
end

return M

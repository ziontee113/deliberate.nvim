-------------------------------------------- Local Helpers

local find_longest_line = function(lines)
    local longest = 1
    for _, line in ipairs(lines) do
        if #line > longest then longest = #line end
    end
    return longest
end

local sanitize_items_keymaps = function(steps)
    for _, current_step in ipairs(steps) do
        if type(current_step.items) == "table" then
            for _, item in ipairs(current_step.items) do
                if type(item.keymaps) == "string" then item.keymaps = { item.keymaps } end
            end
        end
    end
    return steps
end

local function align_keymap(keymap, longest_keymap_hint_length)
    if not keymap then return end
    if #keymap < longest_keymap_hint_length then
        keymap = string.rep(" ", longest_keymap_hint_length - #keymap) .. keymap
    end
    return keymap
end

local function find_keymap_prefix(item, longest_keymap_hint_length)
    local keymap_prefix = ""
    if item.keymaps then
        local keys_to_show = {}
        if not item.visible_keymaps then item.visible_keymaps = 1 end
        for i = 1, item.visible_keymaps do
            local keymap = align_keymap(item.keymaps[i], longest_keymap_hint_length)
            table.insert(keys_to_show, keymap)
            keymap_prefix = table.concat(keys_to_show, " ") .. " "
        end
    end
    return keymap_prefix
end

local function find_line_content(item, format_fn, results)
    local line_content = item.text
    if format_fn then line_content = format_fn(results, item) or line_content end
    return line_content
end

local find_visible_item_index_from_linenr = function(items, linenr)
    local visible_items = {}
    for i, item in ipairs(items) do
        if not item.hidden then table.insert(visible_items, { true_index = i, item = item }) end
    end

    return visible_items[linenr].true_index
end

-------------------------------------------- PopUp

local PopUp = {
    step_index = 0,
    steps = {},
    results = {},
}
PopUp.__index = PopUp

-- Private

function PopUp:_find_number_of_jumps(direction)
    local cursor_linenr = unpack(vim.api.nvim_win_get_cursor(self.win))
    local number_of_jumps = direction
    while self.lines[cursor_linenr + number_of_jumps] == "" do
        number_of_jumps = number_of_jumps + direction
    end
    return math.abs(number_of_jumps)
end

function PopUp:_execute_callback(item_index)
    local current_item = self.current_step.items[item_index]
    if not current_item or type(current_item) == "string" then return end

    table.insert(self.results, current_item.text)

    local callback = self.current_step.callback
    if callback then
        local callback_result = callback(self.results, current_item, {
            target_win = self.target_win,
            target_buf = self.target_buf,
            current_step_items = self.current_step.items,
        })
        if callback_result == true then self.step_index = #self.steps end
        if type(callback_result) == "table" then
            if callback_result.updated_items then
                self.steps[self.step_index].items = callback_result.updated_items
            end
            if callback_result.increment_step_index_by then
                self.step_index = self.step_index + callback_result.increment_step_index_by
            end
        end
    end

    self:_advance()
end

function PopUp:_set_navigation_keymaps()
    if not self.keymaps then self.keymaps = {} end
    if not self.keymaps.next then self.keymaps.next = { "j" } end
    if not self.keymaps.previous then self.keymaps.previous = { "k" } end

    for _, mapping in ipairs(self.keymaps.next) do
        vim.keymap.set("n", mapping, function()
            local cmd = string.format("norm! %sj", self:_find_number_of_jumps(1))
            vim.cmd(cmd)
        end, { buffer = self.buf, nowait = true })
    end

    for _, mapping in ipairs(self.keymaps.previous) do
        vim.keymap.set("n", mapping, function()
            local cmd = string.format("norm! %sk", self:_find_number_of_jumps(-1))
            vim.cmd(cmd)
        end, { buffer = self.buf, nowait = true })
    end
end

function PopUp:_set_hide_keymaps()
    if not self.keymaps.hide then self.keymaps.hide = { "<Esc>", "q" } end

    for _, mapping in ipairs(self.keymaps.hide) do
        vim.keymap.set(
            "n",
            mapping,
            function() vim.api.nvim_win_hide(self.win) end,
            { buffer = self.buf, nowait = true }
        )
    end
end

function PopUp:_set_confirm_keymaps()
    if not self.keymaps.confirm then self.keymaps.confirm = { "<CR>" } end

    for _, mapping in ipairs(self.keymaps.confirm) do
        vim.keymap.set("n", mapping, function()
            local cursor_line = unpack(vim.api.nvim_win_get_cursor(0))
            local index = find_visible_item_index_from_linenr(self.current_step.items, cursor_line)
            self:_execute_callback(index)
        end, { buffer = self.buf, nowait = true })
    end
end

function PopUp:_set_user_keymaps()
    for item_index, item in ipairs(self.current_step.items) do
        if item.keymaps then
            for _, keymap in ipairs(item.keymaps) do
                vim.keymap.set(
                    "n",
                    keymap,
                    function() self:_execute_callback(item_index) end,
                    { buffer = self.buf, nowait = true }
                )
            end
        end
    end
end

function PopUp:_get_lines()
    local longest_keymap_hint_length = 0
    for _, item in ipairs(self.current_step.items) do
        if not item.hidden and item.keymaps then
            for _, keymap in ipairs(item.keymaps) do
                if #keymap > longest_keymap_hint_length then
                    longest_keymap_hint_length = #keymap
                end
            end
        end
    end

    local lines = {}
    for _, item in ipairs(self.current_step.items) do
        if type(item) == "string" then
            table.insert(lines, item)
        elseif not item.hidden then
            local keymap_prefix = find_keymap_prefix(item, longest_keymap_hint_length)
            local line_content = find_line_content(item, self.current_step.format_fn, self.results)
            table.insert(lines, keymap_prefix .. line_content)
        end
    end
    return lines
end

function PopUp:_set_all_keymaps()
    self:_set_navigation_keymaps()
    self:_set_confirm_keymaps()
    self:_set_hide_keymaps()
    self:_set_user_keymaps()
end

function PopUp:_set_window_size(lines)
    self.width = find_longest_line(lines)
    self.height = #lines

    if self.step_index > 1 then
        vim.api.nvim_win_set_width(self.win, self.width)
        vim.api.nvim_win_set_height(self.win, self.height)
    end
end

function PopUp:_advance()
    self.step_index = self.step_index + 1
    if self.step_index > #self.steps then
        self:hide()
        return
    end

    self.current_step = self.steps[self.step_index]

    if self.step_index == 1 and not self.buf then
        self.buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_option(self.buf, "filetype", self.filetype or "")
    end

    if type(self.current_step.items) == "function" then
        local arguments = self.current_step.arguments or {}
        table.insert(arguments, self.results)

        self.steps[self.step_index].items = self.current_step.items(unpack(arguments))

        self.current_step.items = self.steps[self.step_index].items
    end

    self.lines = self:_get_lines()
    vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, self.lines)

    vim.api.nvim_buf_call(self.buf, function() vim.cmd("norm! gg") end)

    self:_set_window_size(self.lines)
    self:_set_all_keymaps()
end

function PopUp:_reset_state()
    self.step_index = 0
    self.results = {}
end

function PopUp:_mount()
    self.win = vim.api.nvim_open_win(self.buf, true, {
        relative = "cursor",
        row = 1,
        col = 1,
        width = self.width,
        height = self.height,
        style = "minimal",
        border = "single",
        title = self.title or "",
        title_pos = self.title_position or "center",
        noautocmd = true,
    })

    vim.api.nvim_win_set_option(
        self.win,
        "winhl",
        self.winhl or "Normal:Normal,FloatBorder:@function"
    )
    vim.api.nvim_win_set_option(self.win, "cursorline", true)
end

-- Public

function PopUp:new(opts)
    opts.steps = sanitize_items_keymaps(opts.steps)
    local popup = setmetatable(vim.deepcopy(opts), vim.deepcopy(PopUp))
    return popup
end

function PopUp:show()
    self:_reset_state()
    self:_advance()

    self.target_win = vim.api.nvim_get_current_win()
    self.target_buf = vim.api.nvim_get_current_buf()

    self:_mount()
end

function PopUp:hide()
    pcall(vim.api.nvim_win_close, self.win, true)
    pcall(vim.api.nvim_buf_del, self.buf)

    if self.defer_fn then
        vim.defer_fn(function() self.defer_fn(self.results) end, 50)
    else
        vim.defer_fn(function() vim.cmd("norm! ^") end, 50)
    end
end

return PopUp

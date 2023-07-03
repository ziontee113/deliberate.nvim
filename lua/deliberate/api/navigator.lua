local lib_ts = require("deliberate.lib.tree-sitter")
local aggregator = require("deliberate.lib.tree-sitter.language_aggregator")
local catalyst = require("deliberate.lib.catalyst")

local M = {}

---@class navigator_move_Args
---@field destination "next-sibling" | "previous-sibling" | "next" | "previous" | "parent"
---@field select_move boolean

---@param o navigator_move_Args
---@return "start" | "end"
local function find_cursor_node_point_for_sibling(o)
    local destination_on_node = "start"
    if
        string.find(o.destination, "previous")
        and not lib_ts.node_start_and_end_on_same_line(catalyst.node())
    then
        destination_on_node = "end"
    end
    return destination_on_node
end

---@param o navigator_move_Args
---@return "start" | "end"
local function find_node_point_for_parent(o)
    local destination_on_node = "end"
    if
        string.find(o.destination, "previous")
        -- and not lib_ts.node_start_and_end_on_same_line(catalyst.node())
    then
        destination_on_node = "start"
    end
    return destination_on_node
end

---@param o navigator_move_Args
local function change_catalyst_node_to_its_sibling(o)
    local sibling_direction = string.find(o.destination, "next") and "next" or "previous"
    local next_siblings = aggregator.get_html_siblings(catalyst.node(), sibling_direction)

    if next_siblings[1] then
        catalyst.set_node(next_siblings[1])
        if string.find(o.destination, "sibling") then
            catalyst.set_node_point("start")
        else
            catalyst.set_node_point(find_cursor_node_point_for_sibling(o))
        end
        return next_siblings[1]
    end
end

---@param o navigator_move_Args
local function change_catalyst_node_to_its_parent(o)
    local parent_node = aggregator.get_html_node(catalyst.node():parent())
    if parent_node then
        catalyst.set_node(parent_node)
        catalyst.set_node_point(find_node_point_for_parent(o))
    end

    return parent_node
end

-------------------------------------------- Forbidden West

local get_first_child_candidate = function()
    local html_children = aggregator.get_html_children(catalyst.node())
    if
        #html_children > 0 and lib_ts.cursor_is_at_start_of_node(catalyst.win(), catalyst.node())
    then
        return { html_children[1], "start" }
    end
end

local get_first_descendant_candidate = function()
    local descendants = aggregator.get_html_descendants(catalyst.buf(), catalyst.node())
    if
        #descendants > 0
        and descendants[1] ~= catalyst.node()
        and lib_ts.cursor_is_at_start_of_node(catalyst.win(), catalyst.node())
    then
        return { descendants[1], "start" }
    end
end

local get_next_sibling_candidate = function()
    local next_siblings = aggregator.get_html_siblings(catalyst.node(), "next")
    if next_siblings and next_siblings[1] then return { next_siblings[1], "start" } end
end

local get_parent_end_candidate = function()
    local parent_node = aggregator.get_html_node(catalyst.node():parent())
    if parent_node then return { parent_node, "end" } end
end

local get_absolute_next_element = function()
    local html_nodes = aggregator.get_all_html_nodes_in_buffer(catalyst.buf())
    local _, _, catalyst_end_row, _ = catalyst.node():range()
    local target
    for _, node in ipairs(html_nodes) do
        local start_row, _, _, _ = node:range()
        if start_row > catalyst_end_row then
            target = node
            break
        end
    end
    if target then return { target, "start" } end
end

local get_absolute_next_closing_tag = function()
    local closing_nodes = aggregator.get_all_html_closing_elements(catalyst.buf())
    local _, _, catalyst_end_row, _ = catalyst.node():range()
    local target
    for _, node in ipairs(closing_nodes) do
        local start_row, _, _, _ = node:range()
        if start_row > catalyst_end_row then
            target = node
            break
        end
    end
    if target then return { target, "start" } end
end

-------------------------------------------- Forbidden East

local get_last_child_candidate = function()
    local html_children = aggregator.get_html_children(catalyst.node())
    if #html_children > 0 and lib_ts.cursor_is_at_end_of_node(catalyst.win(), catalyst.node()) then
        return { html_children[#html_children], "end" }
    end
end

local get_last_descendant_candidate = function()
    local descendants = aggregator.get_html_descendants(catalyst.buf(), catalyst.node())
    if
        #descendants > 0
        and descendants[#descendants] ~= catalyst.node()
        and lib_ts.cursor_is_at_end_of_node(catalyst.win(), catalyst.node())
    then
        return { descendants[#descendants], "end" }
    end
end

local get_prev_sibling_candidate = function()
    local prev_siblings = aggregator.get_html_siblings(catalyst.node(), "previous")
    if prev_siblings and prev_siblings[1] then return { prev_siblings[1], "end" } end
end

local get_parent_start_candidate = function()
    local parent_node = aggregator.get_html_node(catalyst.node():parent())
    if parent_node then return { parent_node, "start" } end
end

local get_absolute_prev_element = function()
    local html_nodes = aggregator.get_all_html_nodes_in_buffer(catalyst.buf())
    local catalyst_start_row, _, _, _ = catalyst.node():range()
    local target
    for _, node in ipairs(html_nodes) do
        local _, _, end_row, _ = node:range()
        if end_row < catalyst_start_row then
            target = node
        else
            break
        end
    end
    if target then return { target, "end" } end
end

local get_absolute_prev_closing_tag = function()
    local closing_nodes = aggregator.get_all_html_closing_elements(catalyst.buf())
    local catalyst_start_row, _, _, _ = catalyst.node():range()
    local target
    for _, node in ipairs(closing_nodes) do
        local _, _, end_row, _ = node:range()
        if end_row < catalyst_start_row then
            target = node
        else
            break
        end
    end

    if target then return { target, "end" } end
end

--------------------------------------------

---@param o navigator_move_Args
M.move = function(o)
    if not catalyst.is_active() then return end

    if o.destination == "next" then
        local candidates = {
            get_first_child_candidate(),
            get_first_descendant_candidate(),
            get_next_sibling_candidate(),
            get_parent_end_candidate(),
            get_absolute_next_element(),
            get_absolute_next_closing_tag(),
        }

        if #candidates > 0 then
            local closest_line = math.huge
            local chosen_target, chosen_node_point

            for _, candidate in pairs(candidates) do
                local target_node, target_node_point = unpack(candidate)

                local start_row, _, end_row, _ = target_node:range()
                if target_node_point == "start" then
                    if start_row < closest_line then
                        closest_line = start_row
                        chosen_target = target_node
                        chosen_node_point = target_node_point
                    end
                elseif target_node_point == "end" then
                    if end_row < closest_line then
                        closest_line = end_row
                        chosen_target = target_node
                        chosen_node_point = target_node_point
                    end
                end
            end

            if chosen_target then
                catalyst.set_node(chosen_target)
                catalyst.set_node_point(chosen_node_point)
            end
        end
    elseif o.destination == "previous" then
        local candidates = {
            get_last_child_candidate(),
            get_last_descendant_candidate(),
            get_prev_sibling_candidate(),
            get_parent_start_candidate(),
            get_absolute_prev_element(),
            get_absolute_prev_closing_tag(),
        }

        local closest_line = -1
        local chosen_target, chosen_node_point

        for i, candidate in pairs(candidates) do
            local target_node, target_node_point = unpack(candidate)

            if i == 6 then target_node = target_node:parent() end
            if i < 6 then
                local start_row, _, end_row, _ = target_node:range()
                if start_row == end_row then target_node_point = "start" end
            end

            local start_row, _, end_row, _ = target_node:range()
            if target_node_point == "start" then
                if start_row > closest_line then
                    closest_line = start_row
                    chosen_target = target_node
                    chosen_node_point = target_node_point
                end
            elseif target_node_point == "end" then
                if end_row > closest_line then
                    closest_line = end_row
                    chosen_target = target_node
                    chosen_node_point = target_node_point
                end
            end
        end

        if chosen_target then
            catalyst.set_node(chosen_target)
            catalyst.set_node_point(chosen_node_point)
        end
    end

    if o.destination == "next-sibling" or o.destination == "previous-sibling" then
        change_catalyst_node_to_its_sibling(o)
    elseif o.destination == "parent" then
        change_catalyst_node_to_its_parent(o)
        catalyst.set_node_point("start")
    end

    catalyst.move_to(o.select_move)
end

return M

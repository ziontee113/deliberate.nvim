local M = {}

local tsx = require("deliberate.lib.tree-sitter.tsx")
local svelte = require("deliberate.lib.tree-sitter.svelte")

local m = {
    ["typescriptreact"] = tsx,
    ["svelte"] = svelte,
}

local ft = function()
    local catalyst = require("deliberate.lib.catalyst")
    if not catalyst.buf() then
        error("aggregator module was called when catalyst is not initiated")
    end
    return vim.api.nvim_buf_get_option(catalyst.buf(), "ft")
end

M.should_exit = function()
    local filetype = vim.bo.ft
    local module = m[filetype]
    return not module
end

local invoke = function(method_name, ...)
    local filetype = ft()
    local module = m[filetype]
    if not module then error(filetype .. "filetype not supported") end
    if not module[method_name] then
        error(
            string.format(
                'responsible module for %s filetype did not implement "%s()" method',
                filetype,
                method_name
            )
        )
    end
    return module[method_name](...)
end

M.get_all_html_closing_elements = function(...) return invoke("get_all_html_closing_elements", ...) end
M.get_html_descendants = function(...) return invoke("get_html_descendants", ...) end
M.get_all_html_nodes_in_buffer = function(...) return invoke("get_all_html_nodes_in_buffer", ...) end
M.get_tag_identifier_node = function(...) return invoke("get_tag_identifier_node", ...) end
M.get_className_property_string_node = function(...)
    return invoke("get_className_property_string_node", ...)
end
M.get_clsx_string_node = function(...) return invoke("get_clsx_string_node", ...) end
M.get_clsx_expression = function(...) return invoke("get_clsx_expression", ...) end
M.extract_class_names = function(...) return invoke("extract_class_names", ...) end
M.get_updated_root = function(...) return invoke("get_updated_root", ...) end
M.get_html_node = function(...) return invoke("get_html_node", ...) end
M.get_first_closing_bracket = function(...) return invoke("get_first_closing_bracket", ...) end
M.get_html_children = function(...) return invoke("get_html_children", ...) end
M.get_html_siblings = function(...) return invoke("get_html_siblings", ...) end
M.get_text_nodes = function(...) return invoke("get_text_nodes", ...) end
M.node_is_self_closing = function(...) return invoke("node_is_self_closing", ...) end
M.get_opening_and_closing_tags = function(...) return invoke("get_opening_and_closing_tags", ...) end
M.get_src_property_string_node = function(...) return invoke("get_src_property_string_node", ...) end
M.get_attribute_value = function(...) return invoke("get_attribute_value", ...) end

--------------------------------------------

local filetype_to_className_template = {
    ["typescriptreact"] = ' className=""',
    ["svelte"] = ' class=""',
}
M.get_className_property_template = function() return filetype_to_className_template[ft()] end

return M

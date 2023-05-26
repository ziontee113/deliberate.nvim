local M = {}

local lib_ts_tsx = require("stormcaller.lib.tree-sitter.tsx")
local lib_ts_svelte = require("stormcaller.lib.tree-sitter.svelte")

local m = {
    ["typescriptreact"] = lib_ts_tsx,
    ["svelte"] = lib_ts_svelte,
}

local ft = function()
    local catalyst = require("stormcaller.lib.catalyst")
    if not catalyst.buf() then
        error("aggregator module was called when catalyst is not initiated")
    end
    return vim.api.nvim_buf_get_option(catalyst.buf(), "ft")
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

M.get_all_html_nodes_in_buffer = function(...) return invoke("get_all_html_nodes_in_buffer", ...) end
M.get_tag_identifier_node = function(...) return invoke("get_tag_identifier_node", ...) end
M.get_className_property_string_node = function(...)
    return invoke("get_className_property_string_node", ...)
end
M.extract_class_names = function(...) return invoke("extract_class_names", ...) end
M.get_updated_root = function(...) return invoke("get_updated_root", ...) end
M.get_html_node = function(...) return invoke("get_html_node", ...) end
M.get_first_closing_bracket = function(...) return invoke("get_first_closing_bracket", ...) end
M.get_html_children = function(...) return invoke("get_html_children", ...) end
M.get_html_siblings = function(...) return invoke("get_html_siblings", ...) end

return M
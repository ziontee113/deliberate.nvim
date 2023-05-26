local M = {}

local lib_ts_tsx = require("stormcaller.lib.tree-sitter.tsx")
local lib_ts_svelte = require("stormcaller.lib.tree-sitter.svelte")

local m = {
    ["typescriptreact"] = lib_ts_tsx,
    ["svelte"] = lib_ts_svelte,
}

local ft = function()
    local catalyst = require("stormcaller.lib.catalyst")
    if not catalyst.buf() then return end
    return vim.api.nvim_buf_get_option(catalyst.buf(), "ft")
end

M.get_all_html_nodes_in_buffer = function(...) return m[ft()].get_all_html_nodes_in_buffer(...) end
M.get_tag_identifier_node = function(...) return m[ft()].get_tag_identifier_node(...) end
M.get_className_property_string_node = function(...)
    return m[ft()].get_className_property_string_node(...)
end
M.extract_class_names = function(...) return m[ft()].extract_class_names(...) end
M.get_updated_root = function(...) return m[ft()].get_updated_root(...) end
M.get_html_node = function(...) return m[ft()].get_html_node(...) end
M.get_first_closing_bracket = function(...) return m[ft()].get_first_closing_bracket(...) end
M.get_html_children = function(...) return m[ft()].get_html_children(...) end
M.get_html_siblings = function(...) return m[ft()].get_html_siblings(...) end

return M

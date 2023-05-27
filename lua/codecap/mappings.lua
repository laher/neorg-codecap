local M = {}

local api = vim.api

local function set_keymap(mode, keys, opts, mapping_opts)
    mapping_opts = vim.tbl_extend("force", { noremap = true, silent = true }, mapping_opts or {})
    local mapping = "<cmd>lua require'codecap'.cap('" .. mode .. "', " .. vim.inspect(opts) .. ")<cr>"
    vim.notify(mapping)
    api.nvim_set_keymap(mode, keys, mapping, mapping_opts)
end

function M.set(mappings)
    mappings = mappings or "<leader>cc"
    set_keymap("n", mappings, { ui = "popup" })
    set_keymap("v", mappings, { ui = "vsplit" }, { silent = false })
end

return M

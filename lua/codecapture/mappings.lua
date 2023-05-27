local M = {}

local api = vim.api

local function set_keymap(mode, keys, mapping_opts)
  mapping_opts = vim.tbl_extend(
    "force",
    { noremap = true, silent = true },
    mapping_opts or {}
  )
  api.nvim_set_keymap(
    mode,
    keys,
    "<cmd>lua require'codecapture'.cap('" .. mode .. "')<cr>",
    mapping_opts
  )
end

function M.set(mappings)
  mappings = mappings or "<leader>cc"
  set_keymap("n", mappings)
  set_keymap("v", mappings, { silent = false })
end

return M

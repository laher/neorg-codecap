local M = {}

local api = vim.api

local function set_keymap(mode, keys, inbox, mapping_opts)
    mapping_opts = vim.tbl_extend("force", { noremap = true, silent = true }, mapping_opts or {})
    local mappingf = "<cmd>lua require'codecap'.cap('%s', { inbox = '%s' })<cr>"
    local mapping = string.format(mappingf, mode, inbox)
--    vim.notify(mapping)
    api.nvim_set_keymap(mode, keys, mapping, mapping_opts)
end

function M.set(mappings)
    if not mappings then
      mappings = {
        ['<leader>ccv'] = 'vsplit',
        ['<leader>ccs'] = 'split',
        ['<leader>cce'] = 'edit',
        ['<leader>ccn'] = 'noshow',
        ['<leader>ccc'] = 'inbox',
      }
    end
    for k, v in pairs(mappings) do
      if v == 'inbox' then
        api.nvim_set_keymap('n', k, '<cmd>Neorg codecap inbox<cr>', {})
      else
        set_keymap("n", k, v)
        set_keymap("v", k, v, { silent = false })
      end
    end
end

return M

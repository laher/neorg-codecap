local M = {}

local api = vim.api

local function set_keymap(mode, func, keys, inbox, mapping_opts)
    mapping_opts = vim.tbl_extend("force", { noremap = true, silent = true }, mapping_opts or {})
    local mappingf = "<cmd>lua require'codecap'.%s('%s', { inbox = '%s' })<cr>"
    local mapping = string.format(mappingf, func, mode, inbox)
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
        ['<leader>ccd'] = 'diff',
      }
    end
    for k, v in pairs(mappings) do
      if v == 'inbox' then
        api.nvim_set_keymap('n', k, '<cmd>Neorg codecap inbox<cr>', {})
      elseif v == 'diff' then
        set_keymap("n", 'diffcap', k, v)
      else
        set_keymap("n", 'cap', k, v)
        set_keymap("v", 'cap', k, v, { silent = false })
      end
    end
end

return M

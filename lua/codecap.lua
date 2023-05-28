local M = {}
local mappings = require("codecap.mappings")

function M.setup(config)
    -- note: using external mappings instead .. for now
    if config then
        -- any config?
        mappings.set(config.mappings)
    else
        mappings.set()
    end
end



function M.get_range(mode, add_current_line_on_normal_mode)
  local lstart
  local lend
  if mode == "v" then
    local pos1 = vim.fn.getpos("v")[2]
    local pos2 = vim.fn.getcurpos()[2]
    lstart = math.min(pos1, pos2)
    lend = math.max(pos1, pos2)
  elseif add_current_line_on_normal_mode == true then
    lstart = vim.api.nvim_win_get_cursor(0)[1]
  end
  return { lstart = lstart, lend = lend }
end

function M.cap(mode, opts)
    -- vim.notify(mode .. " - " .. vim.inspect(opts))
    local inbox
    if opts and opts.inbox then
        inbox = opts.inbox
    else
        inbox = "vsplit"
    end
    -- if gitlinker then call neorg-codecap via a callback
    local url = require("gitlinker").get_buf_range_url(mode, {
        action_callback = function(url)
            local cmd = string.format("Neorg codecap %s %s %s", inbox, mode, url)
            vim.cmd(cmd)
        end,
    })
    if not url then
        -- otherwise just use neorg-codecap
        local cmd = string.format("Neorg codecap %s %s", inbox, mode)
        vim.cmd(cmd)
    end
end

return M

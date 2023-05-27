local M = {}
local mappings = require("codecap.mappings")

function M.setup(config)
    if config then
      -- any config?
      mappings.set(config.mappings)
    else
      mappings.set()
    end
end

function M.cap(mode)
    require"gitlinker".get_buf_range_url(mode, {action_callback = function(url)
        vim.cmd("Neorg codecap popup_with_url " .. url)
    end})
end

return M


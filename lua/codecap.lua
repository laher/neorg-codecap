local M = {}
local mappings = require("codecap.mappings")

function M.setup(config)
    -- note: using external mappings instead .. for now
    if config then
        -- any config?
        --     mappings.set(config.mappings)
    else
        --     mappings.set()
    end
end

function M.cap(mode, opts)
    vim.notify(mode .. " - " .. vim.inspect(opts))
    local ui
    if opts and opts.ui then
        ui = opts.ui
    else
        ui = "vsplit"
    end
    -- if gitlinker then call neorg-codecap via a callback
    local url = require("gitlinker").get_buf_range_url(mode, {
        action_callback = function(url)
            vim.cmd(string.format("Neorg codecap %s %s", ui, url))
        end,
    })
    if not url then
        -- otherwise just use neorg-codecap
        vim.cmd(string.format("Neorg codecap %s", ui))
    end
end

return M

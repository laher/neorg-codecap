---@diagnostic disable: undefined-global
require("neorg.modules.base")

local title = "codecap"
local module = neorg.modules.create("external.codecap")
module.setup = function()
    return { success = true, requires = { "core.neorgcmd", "core.ui", "core.dirman" } }
end

module.load = function()
    module.required["core.neorgcmd"].add_commands_from_table({
        codecap = {
            args = 1,
            subcommands = {
                popup = { args = 0, name = "codecap.popup" },
                popup_with_url = { args = 1, name = "codecap.popup_with_url" },
                inbox = { args = 0, name = "codecap.inbox" },
            },
        },
    })

 --   local cmd = 'lua require"gitlinker".get_buf_range_url("%s", {action_callback = function(url) vim.cmd("Neorg capture popup_with_url " .. url) end})<cr>'
    -- vim.api.nvim_create_user_command("GitCapture", cmd, {range = true})
--    vim.api.nvim_set_keymap('v', '<leader>cc', '<cmd>' .. string.format(cmd, 'v'), {})
--    vim.api.nvim_set_keymap('n', '<leader>cc', '<cmd>' .. string.format(cmd, 'n'), {})
end

module.private = {
    inbox_filename = function()
        local workspace = module.required["core.dirman"].get_current_workspace()[2]
        return workspace .. "/inbox.norg"
    end,
}



local function basename(path)
  return path:sub(path:find("/[^/]*$") + 1)
end

module.public = {
    open_inbox = function()
        vim.cmd.e(module.private.inbox_filename())
    end,
    show_capture_popup = function()
      local url
      local mode = vim.api.nvim_get_mode()
      if mode.mode == 'v' then
        url = require'gitlinker'.get_buf_range_url('v')
      else
        url = require'gitlinker'.get_buf_range_url('n')
      end
      module.public.show_capture_popup_with_url(url)
    end,

    show_capture_popup_with_url = function(url)
      -- if opts then
      --   vim.notify(vim.inspect(opts), 'info', {title='cap'})
      -- end
        --vim.notify(vim.inspect(mode), 'info', {title='cap'})
        -- local url
        -- local short
        -- -- if mode.mode == 'v' then
        -- if opts.range then
        --   url = require'gitlinker'.get_buf_range_url('v')
        -- else
        --   url = require'gitlinker'.get_buf_range_url('n')
        -- end
        if not url then -- oops not a git repo. use a file
          url = vim.api.nvim_buf_get_name(0)
          local line = vim.api.nvim_win_get_cursor(0)
          url = url .. ":" .. line[1]
        end
        local short
        if #url > 20 then
          short = url:sub(0,15) .. "..." .. url:sub(-10, #url)
        else
          short = url
        end
        module.required["core.ui"].create_prompt("NeorgCapture", short .. " : ", function(text)
            local inbox = module.private.inbox_filename()

            local file = io.open(inbox, "r")
            if file == nil then
                -- create a file heading
                text = [[* Inbox
- ( ) ]] .. text
            else
                io.close(file) -- close then re-open in append mode
                -- new TODO with a link
                local fname = basename(url)
                text = string.format([[- ( ) %s
{%s}[%s]
]], text, url, fname)
            end
            file = io.open(inbox, "a")
            io.output(file)
            io.write(text .. "\n")
            io.close(file)

            vim.cmd("bd!") -- close this prompt
            vim.notify('Todo item added to ' .. inbox, 'info',{ title = title })
        end, {
            center_x = true,
            center_y = true,
        }, {
            title = 'Capture a Todo with a git link',
            width = 100,
            height = 1,
            row = 1,
            col = 0,
        })
    end,
}

module.on_event = function(event)
    if event.split_type[2] == "codecap.popup" then
        vim.schedule(module.public.show_capture_popup)
    elseif event.split_type[2] == "codecap.popup_with_url" then
        --vim.notify(vim.inspect(event))
        vim.schedule(function()
          module.public.show_capture_popup_with_url(event.content[1])
        end)
    elseif event.split_type[2] == "codecap.inbox" then
        vim.schedule(module.public.open_inbox)
    end
end

module.events.subscribed = {
    ["core.neorgcmd"] = {
        ["codecap.popup"] = true,
        ["codecap.popup_with_url"] = true,
        ["codecap.inbox"] = true,
    },
}

return module

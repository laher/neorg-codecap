---@diagnostic disable: undefined-global
require("neorg.modules.base")

local title = "external.capture"
local module = neorg.modules.create("external.capture")
module.setup = function()
    return { success = true, requires = { "core.neorgcmd", "core.ui", "core.dirman" } }
end

module.load = function()
    module.required["core.neorgcmd"].add_commands_from_table({
        capture = {
            args = 1,
            subcommands = {
                popup = { args = 0, name = "capture.popup" },
                popup_with = { args = 1, name = "capture.popup_with" },
                inbox = { args = 0, name = "capture.inbox" },
            },
        },
    })

    local cmd = 'lua require"gitlinker".get_buf_range_url("v", {action_callback = function(url) vim.cmd("Neorg capture popup_with " .. url) end})<cr>'
    vim.api.nvim_create_user_command("GitCapture", cmd, {range = true})
    vim.api.nvim_set_keymap('v', '<leader>z', '<cmd>' .. cmd, {})
    -- vim.api.nvim_set_keymap('v', '<localleader>z', function() end, {})
    -- vim.api.nvim_set_keymap('v', '<localleader>z', function()
    --   require"gitlinker".get_buf_range_url("v", { action_callback = function(url)
    --     vim.notify(url)
    --   end })
    -- end, {})
    -- huh?
    -- vim.api.nvim_create_user_command("GitCapture", function(opts)
    --       vim.notify(vim.inspect(opts))
    --       require'gitlinker'.get_buf_range_url('v',
    --       { action_callback = module.public.show_capture_popup_with_url })
    --   -- module.public.show_capture_popup(opts)
    -- end, {desc = 'capture git link to inbox', range = 2})
end

module.private = {
    inbox_filename = function()
        local workspace = module.required["core.dirman"].get_current_workspace()[2]
        return workspace .. "/inbox.norg"
    end,
}

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
                io.close(file) -- need to re-open in append mode
                text = "- ( ) " .. url .. " : " .. text
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
    if event.split_type[2] == "capture.popup" then
        vim.schedule(module.public.show_capture_popup)
    elseif event.split_type[2] == "capture.popup_with" then
        --vim.notify(vim.inspect(event))
        vim.schedule(function()
          module.public.show_capture_popup_with_url(event.content[1])
        end)
    elseif event.split_type[2] == "capture.inbox" then
        vim.schedule(module.public.open_inbox)
    end
end

module.events.subscribed = {
    ["core.neorgcmd"] = {
        ["capture.popup"] = true,
        ["capture.popup_with"] = true,
        ["capture.inbox"] = true,
    },
}

return module

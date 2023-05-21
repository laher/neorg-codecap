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
                inbox = { args = 0, name = "capture.inbox" },
            },
        },
    })
end

module.private = {
    inbox_filename = function()
        local workspace = module.required["core.dirman"].get_current_workspace()[2]
        return workspace .. "/inbox.norg"
    end,
}

module.public = {
    open_inbox = function()
        vim.cmd("e " .. module.private.inbox_filename())
    end,

    show_capture_popup = function()
        -- TODO get cursor position
        -- Generate views selection popup
        module.required["core.ui"].create_prompt("NeorgCapture", "Add a todo to the inbox: ", function(text)
            local inbox = module.private.inbox_filename()

            local file = io.open(inbox, "r")
            if file == nil then
                -- create a file heading
                text = [[* Inbox
- ( ) ]] .. text
            else
                io.close(file)
                text = "- ( ) " .. text
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
            width = 80,
            height = 1,
            row = 10,
            col = 0,
        })
    end,
}

module.on_event = function(event)
    if event.split_type[2] == "capture.popup" then
        vim.schedule(module.public.show_capture_popup)
    elseif event.split_type[2] == "capture.inbox" then
        vim.schedule(module.public.open_inbox)
    end
end

module.events.subscribed = {
    ["core.neorgcmd"] = {
        ["capture.popup"] = true,
        ["capture.inbox"] = true,
    },
}

return module

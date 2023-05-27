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
                popup = { max_args = 1, name = "codecap.popup" },
                vsplit = { max_args = 1, name = "codecap.vsplit" },
                inbox = { args = 0, name = "codecap.inbox" },
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

local function basename(path)
    return path:sub(path:find("/[^/]*$") + 1)
end

local function get_url_and_short(url)
    if not url then
        -- oops not a git repo. use a file
        url = vim.api.nvim_buf_get_name(0)
        local line = vim.api.nvim_win_get_cursor(0)
        url = string.format("/ %s:%d", url, line[1])
    end
    local short
    if #url > 30 then
        short = string.format("%s...%s", url:sub(0, 15), url:sub(-15, #url))
    else
        short = url
    end
    return { url, short }
end

local function write_to_inbox(url, text)
    local inbox = module.private.inbox_filename()

    local preamble
    local inbox_file = io.open(inbox, "r")
    if inbox_file == nil then
        -- create a file heading
        preamble = [[* Inbox
]]
    else
        io.close(inbox_file) -- close then re-open in append mode
        preamble = ''
    end
        -- new TODO with a link
    local fname = basename(url)
    text = preamble .. string.format(
            [[- ( ) %s
{%s}[%s]
]],
            text,
            url,
            fname
        )
    inbox_file = io.open(inbox, "a")
    io.output(inbox_file)
    io.write(text)
    io.close(inbox_file)
end

module.public = {
    open_inbox = function()
        vim.cmd.e(module.private.inbox_filename())
        -- move cursor?
    end,

    show_capture_vsplit = function(url)
        url, _ = unpack(get_url_and_short(url))
        vim.notify(url)
        write_to_inbox(url, " ")
        vim.cmd.vs(module.private.inbox_filename())
        -- move to penultimate line and insert-mode
        vim.cmd("$-1")
        vim.cmd('norm! $')
        vim.cmd('startinsert')
    end,

    -- url already supplied
    show_capture_popup = function(url)
        local short
        url, short = unpack(get_url_and_short(url))
        module.required["core.ui"].create_prompt("NeorgCapture", short .. " : ", function(text)
            write_to_inbox(url, text)
            vim.cmd("bd!") -- close this prompt
            vim.notify("Todo item added to " .. module.private.inbox_filename(), "info", { title = title })
        end, {
            center_x = true,
            center_y = true,
        }, {
            title = "Capture a Todo with a git link",
            width = 100,
            height = 1,
            row = 1,
            col = 0,
        })
    end,
}

module.on_event = function(event)
    local url
    if #event.content > 0 then
      url = event.content[1]
    end
    if event.split_type[2] == "codecap.vsplit" then
        vim.schedule(function()
            module.public.show_capture_vsplit(url)
        end)
    elseif event.split_type[2] == "codecap.popup" then
        --vim.notify(vim.inspect(event))

        vim.schedule(function()
            module.public.show_capture_popup(url)
        end)
    elseif event.split_type[2] == "codecap.inbox" then
        vim.schedule(module.public.open_inbox)
    end
end

module.events.subscribed = {
    ["core.neorgcmd"] = {
        ["codecap.popup"] = true,
        ["codecap.vsplit"] = true,
        ["codecap.inbox"] = true,
    },
}

return module

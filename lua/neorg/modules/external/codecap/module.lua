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
                noshow = { min_args = 1, max_args = 2, name = "codecap.noshow" },
                vsplit = { min_args = 1, max_args = 2, name = "codecap.vsplit" },
                split = { min_args = 1, max_args = 2, name = "codecap.split" },
                edit = { min_args = 1, max_args = 2, name = "codecap.edit" },
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

    get_range = function(mode, add_current_line_on_normal_mode)
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
      if lstart and not lend then
        lend = lstart
      end
      return { lstart = lstart, lend = lend }
    end,

    basename = function(path)
        return path:sub(path:find("/[^/]*$") + 1)
    end,

    get_url_and_range = function(mode, url)
        local range = module.private.get_range(mode, true)
        if not url or url == '' or url == '-' then
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
        -- vim.notify(vim.inspect(range))
        local codeblock
        if range.lstart then
          local lines = vim.api.nvim_buf_get_lines(0, range.lstart, range.lend, false)
          if lines and #lines then
            local ft = vim.bo.filetype
            codeblock = table.concat(lines, "\n")
            codeblock = string.format('@code %s\n%s\n@end\n', ft, codeblock)
          end
        end
        -- empty string won't force a linebreak before url
        if not codeblock then codeblock= '' end
        return { url, short, codeblock }
    end,

    write_to_inbox = function(url, codeblock, description)
        local inbox = module.private.inbox_filename()

        local preamble
        local inbox_file = io.open(inbox, "r")
        if inbox_file == nil then
        -- create a file heading
        preamble = [[* Inbox
]]
        else
            io.close(inbox_file) -- close then re-open in append mode
            preamble = ""
        end
        -- new TODO with a link
        local fname = module.private.basename(url)
        local text = preamble .. string.format(
        [[- ( ) %s
%sSee {%s}[%s]
]],
            description,
            codeblock,
            url,
            fname
        )
        inbox_file = io.open(inbox, "a")
        io.output(inbox_file)
        io.write(text)
        io.close(inbox_file)
    end
}

module.public = {
    open_inbox = function()
        vim.cmd.e(module.private.inbox_filename())
        -- move cursor?
    end,

    show_capture_edit = function(mode, url, edit_type)
        module.public.show_capture(mode, url, function(codeblock)

          -- local codeblock
          -- url, _, codeblock = unpack(module.private.get_url_and_range(mode, url))
          -- vim.notify(url, 'info', {title = title})
          -- module.private.write_to_inbox(url, codeblock, "")
          if edit_type == 'vsplit' then
            vim.cmd.vs(module.private.inbox_filename())
          elseif edit_type == 'split' then
            vim.cmd.sp(module.private.inbox_filename())
          else
            vim.cmd.edit(module.private.inbox_filename())
          end
          -- move to todo line and (ideally) insert-mode
          local _, count = codeblock:gsub('\n', '\n')
          vim.cmd(string.format("$-%d", count+1))
          vim.cmd("norm! $")
          vim.cmd("startinsert") -- doesn't seem to work.
      end)
    end,

    -- url already supplied
    show_capture = function(mode, url, callback)
        local short, codeblock
        url, short, codeblock = unpack(module.private.get_url_and_range(mode, url))
        -- vim.notify(codeblock)
        module.required["core.ui"].create_prompt("NeorgCapture", short .. " : ", function(description)
            vim.cmd("bd!") -- close this prompt
            module.private.write_to_inbox(url, codeblock, description)
            vim.notify("Todo item added to " .. module.private.inbox_filename(), "info", { title = title })
            if callback then
              callback(codeblock)
            end
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
    local mode, url
    if #event.content > 0 then
      mode = event.content[1]
      if #event.content > 1 then
        url = event.content[2]
      end
    end
    if event.split_type[2] == "codecap.vsplit" then
        vim.schedule(function()
            module.public.show_capture_edit(mode, url, 'vsplit')
        end)
    elseif event.split_type[2] == "codecap.split" then
        vim.schedule(function()
            module.public.show_capture_edit(mode, url, 'split')
        end)
    elseif event.split_type[2] == "codecap.edit" then
        vim.schedule(function()
            module.public.show_capture_edit(mode, url, 'edit')
        end)
    elseif event.split_type[2] == "codecap.noshow" then
        --vim.notify(vim.inspect(event))

        vim.schedule(function()
            module.public.show_capture(mode, url)
        end)
    elseif event.split_type[2] == "codecap.inbox" then
        vim.schedule(module.public.open_inbox)
    end
end

module.events.subscribed = {
    ["core.neorgcmd"] = {
        ["codecap.noshow"] = true,
        ["codecap.vsplit"] = true,
        ["codecap.split"] = true,
        ["codecap.edit"] = true,
        ["codecap.inbox"] = true,
    },
}

return module

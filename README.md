# neorg-codecap

    **PRE-ALPHA** - breaking changes incoming soon.

Super basic capture module for neorg, for capturing notes referring to code.

I just wanted to capture a TODO with a popup, which captures the file/line, and its
associated git URL.

It's a little neorg module, but it's also a little vim plugin which does the capturing
(typically, outside of neorg) & then invokes the module.

NOTE: this began just as a quick hack while the neorg-gtd feature is unavailable.
Maybe this will be superceded or eventually be reworked on top of GTD.

## Example usage

Given a file `neorg/lua/neorg.lua` with the following content in your git repo,
selected in visual mode:

```lua
--- Returns whether or not Neorg is loaded
---@return boolean
function neorg.is_loaded()
    return configuration.started
end
```

With a mapping to `require'codecap'.cap('n', { inbox = 'vsplit' })`, you would first
See a single-line popup, where you might enter "investigate is_loaded",
and press `<cr>`.

You'd see a new vsplit showing `$workspace/inbox.norg`, with the following content:

```norg
* Inbox
- ( ) Investigate is_loaded.
@code lua
--- Returns whether or not Neorg is loaded
---@return boolean
function neorg.is_loaded()
    return configuration.started
end
@end
See {https://github.com/nvim-neorg/neorg/blob/main/lua/neorg.lua#L130-L134}[neorg.lua#L130-L134]
```

The git link is produced by gitlinker.nvim. If it weren't in git, then you'd see
a file link instead.

## Config

So far, you can just override keymappings.

Defaults mappings are as follows:

| mapping       | description    |
|---------------|----------------|
| `<leader>ccv` | capture then open inbox in a visual split |
| `<leader>ccs` | capture then open inbox in a horizontal split |
| `<leader>cce` | capture then open inbox into current pane |
| `<leader>ccc` | open inbox |

_See lazy.nvim config to ensure that neorg is loaded when you invoke your mappings._

You can override these with a map in your config (`mappings = {}` to remove them
all).

### Manually adding mappings

You can define a mapping like: `require'codecap'.cap('n', { inbox = 'vsplit' })`

- `'n'` or `'v'` for normal/visual mode.
- `{ inbox = 'vsplit' }`, to dictate whether to display
the inbox.

The `codecap.cap()` function invokes `gitlinker` and then uses the result [or no
result] to invoke neorg commands.

## Neorg commands

- `:Neorg codecap inbox` - opens your inbox file. It's just for convenience.
I recommend linking to the inbox from your `index.norg`.

### Capturing todos

By themselves, the neorg module's capturing commands don't have gitlinker support.
(You need to invoke `codecap.cap()` as above for the gitlinker support).

- First parameter is the vim mode (`n` or `v`).
- If a URL is passed in as an additional parameter,
(which `require'codecap'.cap(...)` would do for you), then that is transformed
into a link.
- If no URL is passed to these `edit`/`vsplit`/`split`/`noshow` commands, they create
a link with a file reference instead. The link refers to the file & line number
of the current buffer.

- `:Neorg codecap [vplit|edit|split|noshow]` - open a small popup where you enter
a todo. The todo ends up in a workspace file called `inbox.norg`. The different
subcommands dictate whether & how to show the todo in the inbox.

## Known issues/limitations

- ~~Neorg can't currently open a file link with a line number `{/ file.txt:23}`.
See [PR](https://github.com/nvim-neorg/neorg/pull/903) - hopefully soon.~~
- The norg spec for file links doesn't support line number ranges, yet. So
file links will just show the first line.

## Plans

- [x] key mappings (visual, normal modes).
- Maybe variants on the same cap func.
  - [x] copying actual code blocks, not just gitlinks / file links.
  - [x] opening the inbox as you capture. Split,etc.
  - [ ] Tagging with a date.
- [x] Hopefully I'll add a visual mode command to enter the selected filename+linenums
into the todo entry.
- [ ] capture git-diffs?
- Maybe a separate module for refiling/organising. Depends on GTD progress.

## 🔧 Installation

First, you need a recent neovim, neorg and gitlinker.

- [Neorg](https://github.com/nvim-neorg/neorg).
- [Gitlinker](https://github.com/ruifm/gitlinker.nvim).

You can install them all through your favorite vim plugin manager.

Something like this but this is WIP
(I use lazy.nvim so other samples might not actually work)

- <details>
  <summary><a href="https://github.com/folke/lazy.nvim">lazy.nvim</a></summary>

  ```lua
  require("lazy").setup({
      {
          "nvim-neorg/neorg",
          opts = {
              load = {
                  ["core.defaults"] = {},
                  ...
                  ["external.codecap"] = {},
              },
          },

          requires = {
            "nvim-lua/plenary.nvim",
            "ruifm/gitlinker.nvim",
            {
                "laher/neorg-codecap",
                keys = {
                    -- indicates to lazy to load the plugin
                    -- the mappings themselves are defined/overridden by codecap iteslf
                    { '<leader>cce', desc = 'capture a thing. open with :edit',  mode = { 'v', 'n' } },
                    { '<leader>ccv', desc = 'capture a thing. open inbox with :vsplit',  mode = { 'v', 'n' } },
                    { '<leader>ccs', desc = 'capture a thing. open inbox with :split',  mode = { 'v', 'n' } },
                    { '<leader>ccn', desc = 'capture a thing. do not open inbox',  mode = { 'v', 'n' } },
                    { '<leader>cci', desc = 'open inbox',  mode = { 'v', 'n' } },
                },
                config = function()
                    require'codecap'.setup({})
                end
            },
         },
      },
  })
  ```

  </details>


- <details>
  <summary><a href="https://github.com/junegunn/vim-plug">vim-plug</a></summary>

  ```vim
  Plug 'nvim-neorg/neorg' | Plug 'nvim-lua/plenary.nvim' | Plug 'ruifm/gitlinker.nvim' | Plug 'laher/neorg-codecap'
  ```

  You can then put this initial configuration in your `init.vim` file.

  TODO test the setup, add override key mappings. (Please see lazy config for now, for clues)

  ```vim
  lua << EOF
  require('neorg').setup {
    load = {
        ["core.defaults"] = {},
        ...
        ["external.codecap"] = {},
    },
  }
  require('codecap').setup {

  }
  EOF
  ```

  </details>

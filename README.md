# neorg-codecap

    **PRE-ALPHA** - breaking changes incoming soon.

Super basic capture module for neorg, for capturing notes referring to code.

I just wanted to capture a TODO with a popup, which captures the file/line, and its
associated git URL.

It's a little neorg module, but it's also a little vim plugin which does the capturing
(typically, outside of neorg) & then invokes the module.

NOTE: this began just as a quick hack while the neorg-gtd feature is unavailable.
Maybe this will be superceded or eventually be reworked on top of GTD.

## Config

So far, just keymappings to `require'codecap'.cap('n', { ui = 'vsplit' })` ('n' or
'v' for normal/visual mode), `{ ui = 'vsplit' }` or `{ ui = 'popup' }` to change
the capture UI.

The `cap()` function invokes neorg commands ...

## Neorg commands

### Capturing todos

By themselves, these commands don't have gitlinker support.
(You need to invoke `codecap.cap()` as above for gitlinker support).

- If a URL is passed in as an additional parameter
(which `require'codecap'.cap(...)` would do for you), then that is transformed
into a link.
- If no URL is passed to the `popup`/`vsplit` commands, they create a link with
a file reference instead. The link refers to the file & line number of the
current buffer.

- `:Neorg codecap popup` - opens a small popup where you enter a todo.
The todo ends up in a workspace file called `inbox.norg`.
- `:Neorg codecap vsplit` - opens `inbox.norg` in a split, where you enter a todo.

### Navigate to the inbox

- `:Neorg codecap inbox` - opens your inbox file

## Known issues/limitations

- Neorg can't currently open a file link with a line number `{/ file.txt:23}`.
See [PR](https://github.com/nvim-neorg/neorg/pull/903) - hopefully soon.

- The norg spec for file links doesn't support line number ranges.

## Plans

- [x] key mappings (visual, normal modes)
- Maybe variants on the same cap func.
  - [ ] Tagging with a date.
  - [ ] copying actual code blocks, not just gitlinks / file links.
  - [ ] opening the inbox as you capture. Split,etc.
- [x] Hopefully I'll add a visual mode command to enter the selected filename+linenums
into the todo entry.
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
                    { '<leader>cc', function()
                            require'codecap'.cap('v', { ui = 'vsplit' })
                        end, desc = 'capture a thing', mode = 'v'
                    },
                    { '<leader>cc', function()
                            require'codecap'.cap('n', { ui = 'popup' })
                        end, desc = 'capture a thing', mode = 'n'
                    },
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

  TODO test the setup, add key mappings. (Please see lazy config for now, for clues)

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

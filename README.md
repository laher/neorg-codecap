# neorg-codecap

    **PRE-ALPHA** - breaking changes incoming soon.

Super basic capture module for neorg, for capturing notes referring to code.

I just want to capture a TODO with a popup, which captures the file/line, and its
associated git URL.

NOTE: this is just a quick hack while the neorg-gtd feature is unavailable.
Maybe this will be superceded or eventually be reworked on top of GTD.

## Commands

- `:Neorg codecap popup` - opens a small popup where you enter a todo.
The todo ends up in a workspace file called `inbox.norg`
- `:Neorg codecap inbox` - opens your inbox file

## Config

So far, just keymappings to `require'codecap'.cap('n')` ('n' or 'v' for normal/visual mode).

## Plans

- [x] key mappings (visual, normal modes)
- Maybe variants on the same cap func.
  - [ ] Tagging with a date.
  - [ ] copying actual code blocks, not jus gitlinks.
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
                            require'codecap'.cap('v')
                        end, desc = 'capture a thing', mode = 'v'
                    },
                    { '<leader>cc', function()
                            require'codecap'.cap('n')
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

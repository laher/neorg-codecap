# neorg-codecapture

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

Nah.

## Plans

Tagging with a date .. key mappings.

Hopefully I'll add a visual mode command to enter the selected filename+linenums
into the todo entry.

Maybe a separate module for refiling.

## 🔧 Installation

First, make sure to pull this plugin down.
This plugin does not run any code in of itself.

It requires Neorg to load it first:

You can install it through your favorite plugin manager:

-
  <details>
  <summary><a href="https://github.com/wbthomason/packer.nvim">packer.nvim</a></summary>

  ```lua
  use {
      "nvim-neorg/neorg",
      config = function()
          require('neorg').setup {
              load = {
                  ["core.defaults"] = {},
                  ...
                  ["external.codecapture"] = {},
              },
          }
      end,
      requires = { "nvim-lua/plenary.nvim", "laher/neorg-codecapture" },
  }
  ```

- <details>
  <summary><a href="https://github.com/junegunn/vim-plug">vim-plug</a></summary>

  ```vim
  Plug 'nvim-neorg/neorg' | Plug 'nvim-lua/plenary.nvim' | Plug 'laher/neorg-codecapture'
  ```

  You can then put this initial configuration in your `init.vim` file:

  ```vim
  lua << EOF
  require('neorg').setup {
    load = {
        ["core.defaults"] = {},
        ...
        ["external.codecapture"] = {},
    },
  }
  EOF
  ```

  </details>
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
                  ["external.codecapture"] = {},
              },
          },
          dependencies = { { "nvim-lua/plenary.nvim" }, { "laher/neorg-codecapture" } },
      }
  })
  ```

  </details>


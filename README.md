# stackgen.nvim

## Table of Contents

- [Background](#background)
- [Getting Started](#getting-started)
- [Usage](#usage)

## Background

### What is StackGen?

[StackGen](https://stackgen.com) is the Generative Infrastructure Platform.
You can use StackGen to build, manage, and deploy your infrastructure using Terraform.

Try StackGen for free at [StackGen Cloud Console](https://cloud.stackgen.com).

### StackGen Neovim Plugin

This plugin provides a Neovim interface to StackGen, allowing you to interact with StackGen directly from neovim.

#### Features

- Browse, manage, and publish available terraform modules in StackGen

## Getting Started

### Required dependencies

- [Neovim](https://neovim.io) 0.9 or later
- [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

### Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'stackgenhq/stackgen.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
  },
  opts = {
    url = 'https://cloud.stackgen.com', -- StackGen Cloud Console URL
  },
  config = function(_, opts)
    require("stackgen").setup(opts)

    vim.keymap.set("n", "<leader>sgl", "<cmd>StackGenModuleList<CR>")
    vim.keymap.set("n", "<leader>sgs", "<cmd>StackGenModuleSync<CR>")
  end
}
```

### Setting up StackGen token

You need to set up your StackGen token to authenticate with the StackGen API.
You can do this by running the following command in Neovim:

```vim
:StackGen set_token <your_token>
```

> Note: You can generate a personal access token in the StackGen Cloud Console in [settings](https://cloud.stackgen.com/account-settings/pat).

### checkhealth

Make sure to run `:checkhealth stackgen` to verify that the plugin is set up correctly.

> Note: You must set up url and token before running `:checkhealth stackgen`.

## Usage

### Vim Commands

All `stackgen.nvim` functions are wrapped in `vim` commands for easy access, tab completion, and key mappings.

- `:StackGen set_token <token>`: Set the StackGen personal access token for authentication.
- `:StackGen module_list` List available terraform modules in StackGen and open them in Telescope.
- `:StackGen module_get <module_uuid>`: Search for terraform modules in StackGen and open the module files in Telescope.
- `:StackGen module_sync` Sync the local module cache with StackGen.
- `:StackGen module_publish <version-name>`: Publish a terraform module to StackGen.
- `:StackGen show_config`: Show the current StackGen configuration.

#### How to use the commands

```viml
" Show all commands
:StackGen

" Tab completion
:StackGen |<tab>
:StackGen module_list

" Setting options
:StackGen module_get <module_uuid>
```

### Key Mappings

You can set up key mappings for the commands in your Neovim configuration. For example:

```lua
vim.keymap.set("n", "<leader>sgl", "<cmd>StackGen module_list<CR>")
vim.keymap.set("n", "<leader>sgs", "<cmd>StackGen module_sync<CR>")
```

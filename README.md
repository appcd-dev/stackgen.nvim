# stackgen.nvim

## Table of Contents

- [Background](#background)
- [Getting Started](#getting-started)]
- [Usage](#usage)
- [Examples](#examples)

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
  'appcd-dev/stackgen.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
  },
  opts = {
    url = 'https://cloud.stackgen.com', -- StackGen Cloud Console URL
  },
  config = function(_, opts)
    require('stackgen').setup({
      require("stackgen").setup(opts)

      vim.keymap.set("n", "<leader>sgl", "<cmd>StackGenModuleList<CR>")
      vim.keymap.set("n", "<leader>sgs", "<cmd>StackGenModuleSync<CR>")
    })
  end
}
```

### Setting up StackGen token

You need to set up your StackGen token to authenticate with the StackGen API.
You can do this by running the following command in Neovim:

```vim
:StackGenSetToken <your_token>
```

> Note: You can generate a personal access token in the StackGen Cloud Console in [settings](https://cloud.stackgen.com/account-settings/pat).

### checkhealth

Make sure to run `:checkhealth stackgen` to verify that the plugin is set up correctly.

> Note: You must set up url and token before running `:checkhealth stackgen`.

## Usage

### Commands

- `:StackGenSetToken <token>`: Set the StackGen personal access token for authentication.
- `:StackGenModuleList`: List available terraform modules in StackGen and open them in Telescope.
- `:StackGenModuleGet <module_uuid>`: Search for terraform modules in StackGen and open the module files in Telescope.
- `:StackGenModuleSync`: Sync the local module cache with StackGen.
- `:StackGenModulePublish <version-name>`: Publish a terraform module to StackGen.

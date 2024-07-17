# lint.nvim

This Neovim plugin provides an asynchronous interface to run project-wide linting checking using the "yarn lint" command.
The output can be shown inside a quickfix list or used to be shown in a custom way.

## Features

- Project-wide linting
- Asynchronous execution of "yarn lint" on start and/or file save
- Quickfix list for navigating errors
- Automatic opening of the quickfix list if there are errors

## Installation

To install the plugin, use your preferred plugin manager.

### Packer

```
use {
    'ceceppa/lint.nvim',
    required = {
        'ceceppa/execAsync.nvim'
    },
    config = function()
        require('lint').setup()
    end
}
```

## Setup

To set up the plugin, add the following line to your init.vim or init.lua file:

```
require('lint').setup()
```

## Usage

To run lint checking, execute the `:Lint` command in Neovim. The plugin will display a progress notification when the linting is complete.
When the checking is complete, it will show a notification with the results and open a quickfix list if there are any errors.

Use the `:Lint stop` command in Neovim to stop the running.

## Configuration

The default configuration is:

```
{
    watch = true,
    auto_start = true,
    lint_command = 'lint',
    auto_open_qflist = false,
    watch_pattern = "*.{ts,tsx,js,jsx}",
    use_diagnostics = true
}
```

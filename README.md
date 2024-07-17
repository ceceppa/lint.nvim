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
    use_diagnostic = false,
    package_manager = 'yarn'
}
```

### Commands

#### is_running

```
require('lint').is_running()
```

Returns true while its running the `[package manager] lint` command

#### get_output

```
require('lint').get_output()
```

Returns the lint output in the format:

```
{
    col,
    filename,
    lnum,
    severity,
    source,
    text,
    type
}
```

#### print_output

```
require('lint').print_output()
```

Prints the `get_output` content for debug purpose

#### show_qflist

Use the command `:Lint show` to manually shows the quickfix list

## Diagnostic

NOTE: When using `use_diagnostic = true`, Neovim will only show errors and warnings for the open buffers!
If you want to see all errors or warnings, you can either use `auto_open_qflist = true` or the `get_output` content with a custom diagnostic:
https://github.com/ceceppa/neovim/blob/main/lua/ceceppa/diagnostics.lua

## Contributing

Feel free to open issues or submit pull requests if you encounter any bugs or have suggestions for improvements. Your contributions are welcome!

## License

This plugin is released under the MIT License. See the LICENSE file for details.

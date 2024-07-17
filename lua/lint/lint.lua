local exec_async = require('execAsync').exec_async
local parser = require('lint.parser')
local config = require('lint.config').config

local M = {}

local _is_running = false
local _should_stop = false
local _lint_output = {}

M.check = function(is_silent)
    if _is_running or _should_stop then
        if not is_silent then
            vim.notify('Lint is already running', 'warn', {
                title = 'Lint'
            })
        end

        return
    end

    if vim.fn.filereadable('package.json') ~= 1 then
        if not is_silent then
            vim.notify('No package.json found', 'warn', {
                title = 'Lint'
            })
        end

        return
    end

    _is_running = true

    exec_async(config.package_manager .. ' ' .. config.lint_command, function(data)
        _lint_output = parser.parse(config, data)

        _is_running = false
    end, is_silent)
end

M.stop = function()
    _should_stop = true
end

M.run = function()
    _should_stop = false

    M.check()
end

M.get_output = function()
    return _lint_output
end

M.print_output = function()
    print(vim.inspect(M.get_output()))
end

M.is_running = function()
    return _is_running
end

M.show_quickfix = function()
    parser.show_qflist(M.get_output(), true)
end

return M

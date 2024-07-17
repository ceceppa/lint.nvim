local exec_async = require('execAsync').exec_async
local parser = require('lint.parser')

local M = {}

local _is_running = false
local _should_stop = false
local _lint_output = {}

local config = {}

local DEFAULT_CONFIG = {
    watch = true,
    auto_start = true,
    lint_command = 'lint',
    auto_open_qflist = false,
    watch_pattern = "*.{ts,tsx,js,jsx}",
    package_manager = 'yarn'
}

M.check = function(is_silent)
    if vim.fn.filereadable('package.json') ~= 1 or _is_running or _should_stop then
        return
    end

    _is_running = true

    exec_async(config.package_manager .. ' ' .. config.lint_command, function(data)
        _lint_output = parser.parse(config, data)

        _is_running = false
    end, is_silent)
end

M.init = function(notification_interval)
    if vim.fn.filereadable('package.json') == 1 then
        local scripts = vim.fn.json_decode(vim.fn.readfile('package.json'))['scripts']

        if scripts == nil then
            return
        end

        -- Check if there is a "lint" command in the package.json
        local lint_command = vim.fn.json_decode(vim.fn.readfile('package.json'))['scripts'][config.lint_command]

        if lint_command == nil then
            vim.notify('No lint command (' .. config.lint_command .. ') found in package.json', 'warn', {
                title = 'Lint'
            })
            return
        end


        local manager = vim.fn.json_decode(vim.fn.readfile('package.json'))['packageManager']

        if manager ~= nil then
            -- retrieve the name of the package manager from the format "name@version"
            config.package_manager = manager:match("([^@]+)")
        end

        vim.api.nvim_create_autocmd("BufWritePost", {
            pattern = config.watch_pattern,
            desc = "Run lint on save",
            callback = function()
                M.check(true)
            end,
        })

        vim.defer_fn(function()
            vim.notify('Linting started', 'info', {
                title = 'Lint'
            })
        end, notification_interval or 0)
    else
        vim.notify('No package.json found', 'warn', {
            title = 'Lint'
        })
    end
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
    for _, output in ipairs(_lint_output) do
        print(output)
    end
end

M.is_running = function()
    return _is_running
end

M.setup = function(opts)
    config = vim.tbl_deep_extend("force", config, DEFAULT_CONFIG, opts or {})

    if config.auto_start then
        M.init(1000)
    end
end

return M

local exec_async = require('execAsync').exec_async
local parser = require('lint.parser')
local package_manager = 'yarn'

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
    watch_pattern = "*.{ts,tsx,js,jsx}"
}

M.check = function(is_silent)
    if vim.fn.filereadable('package.json') ~= 1 or _is_running or _should_stop then
        return
    end

    _is_running = true

    exec_async(package_manager .. ' ' .. config.lint_command, function(data)
        _lint_output = parser.parse(config, data)

        _is_running = false
    end, is_silent)
end

M.init = function()
    if vim.fn.filereadable('package.json') == 1 then
        local scripts = vim.fn.json_decode(vim.fn.readfile('package.json'))['scripts']

        if scripts == nil then
            return
        end

        -- Check if there is a "lint" command in the package.json
        local lint_command = vim.fn.json_decode(vim.fn.readfile('package.json'))['scripts'][config.lint_command]

        if lint_command == nil then
            return
        end


        local manager = vim.fn.json_decode(vim.fn.readfile('package.json'))['packageManager']

        if manager ~= nil then
            -- retrieve the name of the package manager from the format "name@version"
            package_manager = manager:match("([^@]+)")
        end

        vim.api.nvim_create_autocmd("BufWritePost", {
            pattern = config.watch_pattern,
            desc = "Run lint on save",
            callback = function()
                M.check(true)
            end,
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

M.is_running = function()
    return _is_running
end

M.setup = function(opts)
    config = vim.tbl_deep_extend("force", config, DEFAULT_CONFIG, opts or {})

    if config.auto_start then
        M.init()
    end
end

return M

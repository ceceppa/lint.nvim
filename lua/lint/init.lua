local config = require('lint.config')
local lint = require('lint.lint')

local _is_active = false

local function init(notification_interval)
    if vim.fn.filereadable('package.json') == 1 then
        local scripts = vim.fn.json_decode(vim.fn.readfile('package.json'))['scripts']

        if scripts == nil then
            return false
        end

        -- Check if there is a "lint" command in the package.json
        local lint_command = vim.fn.json_decode(vim.fn.readfile('package.json'))['scripts'][config.get().lint_command]

        if lint_command == nil then
            -- vim.notify('No lint command (' .. config.get().lint_command .. ') found in package.json', 'warn', {
            --     title = 'Lint'
            -- })
            return false
        end


        local manager = vim.fn.json_decode(vim.fn.readfile('package.json'))['packageManager']

        if manager ~= nil then
            -- retrieve the name of the package manager from the format "name@version"
            config.set({
                package_manager = manager:match("([^@]+)")
            })
        end

        vim.api.nvim_create_autocmd("BufWritePost", {
            pattern = config.get().watch_pattern,
            desc = "Run lint on save",
            callback = function()
                lint.check(true)
            end,
        })

        vim.defer_fn(function()
            lint.check(true)

            vim.notify('Linting started', 'info', {
                title = 'Lint'
            })
        end, notification_interval or 0)

        return true
    end

    return false
end

local function setup(opts)
    config.set(opts)

    if config.get().auto_start then
        _is_active = init(1000)
    end
end

local function is_active()
    return _is_active
end

vim.api.nvim_create_user_command("Lint", function(arguments)
    local args = arguments.fargs

    if args[1] == 'stop' then
        if _is_active then
            vim.notify('Linting stopped', 'info', {
                title = 'Lint'
            })

            _is_active = false
        else
            vim.notify('Linting is not active', 'warn', {
                title = 'Lint'
            })
        end

        lint.stop()
    elseif args[1] == 'show' then
        lint.show_quickfix()
    elseif args[1] == nil then
        vim.notify('Linting...', 'info', {
            title = 'Lint'
        })

        _is_active = lint.run()
    else
        vim.notify('Invalid argument', vim.log.levels.ERROR)
    end
end, { desc = 'Run Linting', nargs = '*' })


return {
    setup = setup,
    get_output = lint.get_output,
    print_output = lint.print_output,
    is_running = lint.is_running,
    is_active = is_active,
    init = init
}

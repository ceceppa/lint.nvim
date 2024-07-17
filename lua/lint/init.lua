local package = require('lint.lint')

vim.api.nvim_create_user_command("Lint", function(arguments)
    local args = arguments.fargs

    if args[1] == 'stop' then
        package.stop()
    elseif args[1] == 'show' then
        package.show_quickfix()
    elseif args[1] == nil then
        package.run()
    else
        vim.notify('Invalid argument', vim.log.levels.ERROR)
    end
end, { desc = 'Run Linting', nargs = '*' })


return package

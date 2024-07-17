local package = require('lint.lint')

vim.api.nvim_create_user_command("Lint", function(args)
    if args[1] == 'stop' then
        package.stop()
    else
        package.run()
    end
end, { desc = 'Run Linting', nargs = '*' })


return package

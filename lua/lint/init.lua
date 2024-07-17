local package = require('lint.lint')

return {
    setup = package.setup,
    init = package.init,
	check = package.check,
    get_output = package.get_output,
    is_running = package.is_running,
}


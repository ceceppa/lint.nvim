local config = {}

--- @class Opts
--- @field watch boolean - (true) When true runs the `[package_manager] [lint]` command on file save
--- @field auto_start boolean - (true) When true the `lint` process will be started when neovim starts
--- @field lint_command string - ('lint') The command to run when linting
--- @field watch_pattern string - ('*.{ts,tsx,js,jsx}') The pattern to watch for when running the lint command on file save
--- @field package_manager string - ('yarn') The package manager to use when running the lint command
--- @field use_diagnostic boolean - (false) When true the errors will be set as diagnostics

local DEFAULT_CONFIG = {
    watch = true,
    auto_start = true,
    lint_command = 'lint',
    auto_open_qflist = false,
    watch_pattern = "*.{ts,tsx,js,jsx}",
    package_manager = 'yarn',
    use_diagnostic = false
}

local function set(opts)
    config = vim.tbl_deep_extend("force", config, DEFAULT_CONFIG, opts or {})
end

local function get()
    return config
end

return {
    set = set,
    get = get
}

local config = {}

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

return {
    set = set,
    config = config
}

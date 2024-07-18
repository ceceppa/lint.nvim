local config = require("lint.config")

local function add_diagnostics(errors)
    local namespace_id = vim.api.nvim_create_namespace("lint_diagnostics")
    vim.diagnostic.reset(namespace_id)

    for _, error in ipairs(errors) do
        local buffer_number = vim.fn.bufnr(error.filename)

        if buffer_number == -1 then
            return
        end

        local diagnostic = {
            bufnr = buffer_number,
            filename = error.filename,
            lnum = error.lnum - 1,
            col = error.col - 1,
            severity = error.severity,
            message = error.text,
            source = "lint",
        }

        vim.diagnostic.set(namespace_id, buffer_number, { diagnostic }, {})
    end
end

local function show_quickfix_list(output, autofocus)
    vim.fn.setqflist({}, "r", { title = "Lint", items = output })

    local win = vim.api.nvim_get_current_win()

    vim.cmd("copen")

    if autofocus then
        return
    end

    pcall(vim.api.nvim_set_current_win, win)
end

local function parse_eslint_output(output)
    local errors = {}

    if output == nil then
        output = {}
    end

    local previous_line = ""
    for _, line in ipairs(output) do
        local line_number, col_number, type, message = line:match("%s?(%d+):(%d+)%s+(%w+)%s?(.*)$")

        if line_number ~= nil and col_number ~= nil then
            local severity = vim.diagnostic.severity.ERROR

            type = type:upper()

            if type ~= "ERROR" then
                severity = vim.diagnostic.severity.WARN
                type = "WARN"
            end

            table.insert(errors, {
                filename = previous_line,
                lnum = tonumber(line_number),
                col = tonumber(col_number),
                text = message,
                severity = severity,
                type = type,
                source = "eslint"
            })
        else
            previous_line = line
        end
    end

    if config.get().use_diagnostic then
        add_diagnostics(errors)
    end

    if config.get().auto_open_qflist then
        show_quickfix_list(errors)
    end

    return errors
end

return {
    parse = parse_eslint_output,
    show_quickfix_list = show_quickfix_list
}

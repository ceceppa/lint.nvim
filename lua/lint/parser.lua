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

local function diagnostic_exists(diagnostic, diagnostics)
    for _, d in ipairs(diagnostics) do
        if d.filename == diagnostic.filename and d.lnum == diagnostic.lnum and d.col == diagnostic.col then
            return true
        end
    end

    return false
end

local function get_vim_diagnostic_list()
    local diagnostics = {}
    local buffer_names = {}

    for _, buffer_number in ipairs(vim.api.nvim_list_bufs()) do
        local buffer_diagnostics = vim.diagnostic.get(buffer_number)

        if buffer_names[buffer_number] == nil then
            buffer_names[buffer_number] = vim.api.nvim_buf_get_name(buffer_number)
        end

        for _, diagnostic in ipairs(buffer_diagnostics) do
            table.insert(diagnostics, {
                filename = buffer_names[buffer_number],
                lnum = diagnostic.lnum,
                col = diagnostic.col,
            })
        end
    end

    return diagnostics
end

local function parse_eslint_output(output)
    local errors = {}

    if output == nil then
        output = {}
    end

    local previous_line = ""
    local vim_diagnostics = get_vim_diagnostic_list()
    for _, line in ipairs(output) do
        local line_number, col_number, type, message = line:match("%s?(%d+):(%d+)%s+(%w+)%s?(.*)$")

        if line_number ~= nil and col_number ~= nil then
            local severity = vim.diagnostic.severity.ERROR

            type = type:upper()

            if type ~= "ERROR" then
                severity = vim.diagnostic.severity.WARN
                type = "WARN"
            end

            local lnum = tonumber(line_number)
            local col = tonumber(col_number)

            -- Prevent duplicate diagnostics
            if not diagnostic_exists({
                    filename = previous_line,
                    lnum = lnum,
                    col = col
                }, vim_diagnostics) then
                table.insert(errors, {
                    filename = previous_line,
                    lnum = lnum,
                    col = col,
                    text = message,
                    severity = severity,
                    type = type,
                    source = "lint"
                })
            end
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

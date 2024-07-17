local function add_diagnostics(errors)
    local namespace_id = vim.api.nvim_create_namespace("tsc_diagnostics")
    vim.diagnostic.reset(namespace_id)

    for _, error in ipairs(errors) do
        local buffer_number = vim.fn.bufnr(error.filename)

        local diagnostic = {
            bufnr = buffer_number,
            filename = error.filename,
            lnum = error.lnum - 1,
            col = error.col - 1,
            severity = error.severity,
            message = error.message,
            source = "eslint",
        }

        vim.diagnostic.set(namespace_id, buffer_number, { diagnostic }, {})
    end
end

local function parse_eslint_output(opts, output)
    local errors = {}

    if output == nil then
        return errors
    end

    local previous_line = ""
    for _, line in ipairs(output) do
        local line_number, col_number, type, message = line:match("%s?(%d+):(%d+)%s+(%w+)%s?(.*)$")

        if line_number ~= nil and col_number ~= nil then
            local severity = vim.diagnostic.severity.ERROR

            type = type:upper()

            if type ~= "ERROR" then
                severity = vim.diagnostic.severity.WARN
            end

            table.insert(errors, {
                filename = previous_line,
                lnum = tonumber(line_number),
                col = tonumber(col_number),
                message = message,
                severity = severity,
                source = "eslint"
            })
        end

        previous_line = line
    end

    if opts.use_diagnostics then
        add_diagnostics(errors)
    end


    return errors
end

return {
    parse = parse_eslint_output
}

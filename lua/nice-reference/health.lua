local health = {}

local vim = vim

local optional_plugins = {
	'nvim-web-devicons',
	'goto-preview'
}

local report = {
	start = vim.fn['health#report_start'],
    ok = vim.fn['health#report_ok'],
    warn = vim.fn['health#report_warn'],
    error = vim.fn['health#report_error'],
    info = vim.fn['health#report_info'],
}

local function is_plugin_installed(plugin_name)
	return pcall(require, plugin_name)
end

health.check = function()
	report.start("Checking optional plugins")

    for _, plugin in pairs(optional_plugins) do
        if is_plugin_installed(plugin) then
			report.ok(string.format("%s installed", plugin))
        elseif plugin == 'goto-preview' then
            report.warn("goto-preview not installed, previews won't work")
		elseif plugin == 'nvim-web-devicons' then
            report.info("nvim-web-devicons not installed, icons won't be showed")
        end
    end

	local lsp_clients = vim.lsp.buf_get_clients(0)

    if lsp_clients == nil or #lsp_clients < 1 then
		report.warn("No LSP client found for the current file, nice-reference won't work")
    end

end

return health

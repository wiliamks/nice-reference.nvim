vim.api.nvim_create_user_command('NiceReference', function()
	require('nice-reference').references()
end, {})

vim.api.nvim_create_user_command('NiceDefinition', function()
	require('nice-reference').definition()
end, {})

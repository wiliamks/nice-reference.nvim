local M = {}

local vim = vim
local util = require 'vim.lsp.util'

M.on_choice = function(item, encoding)
	if item == nil then
		return
	end

	local location = {
		uri = "file://" .. item.filename,
		range = {
			start = {
				line = item.lnum - 1,
				character = item.col - 1
			}
		}
	}

	util.jump_to_location(location, encoding)
end

M.close = function(item, _)
	print(vim.inspect(item))
	vim.api.nvim_win_close(0, true)
end

M.choose = function(item, encoding)
	M.close()
	M.on_choice(item, encoding)
end

M.preview = function(item, _)
	local ok, lib = pcall(require, 'goto-preview.lib')
	if ok then
		M.cancel()
		lib.open_floating_win('file://' .. item.filename, { item.lnum, item.col - 1 })
	else
		vim.notify("goto-preview not installed")
	end
end

return M

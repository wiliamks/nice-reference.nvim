local M = {}

local vim = vim
local api = vim.api
local util = require 'vim.lsp.util'

M.jump = function(item, encoding)
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

M.close = function(_, _, _)
	vim.api.nvim_win_close(0, true)
end

M.choose = function(_, item, encoding)
	M.close()
	M.jump(item, encoding)
end

M.preview = function(_, item, _)
	local ok, lib = pcall(require, 'goto-preview.lib')
	if ok then
		M.cancel()
		lib.open_floating_win('file://' .. item.filename, { item.lnum, item.col - 1 })
	else
		vim.notify("goto-preview not installed")
	end
end

M.move_to_quick_fix = function(items, _, _)
	M.close()
	local title = 'References'
	vim.fn.setloclist(0, {}, ' ', { title = title, items = items })
    api.nvim_command('lopen')
end

M.open_on_new_tab = function(_, item, encoding)
	M.close()
	vim.cmd('tabedit')
	M.jump(item, encoding)
end

M.open_vsplit = function(_, item, encoding)
	M.close()
	vim.cmd('vsplit')
	M.jump(item, encoding)
end

M.open_split = function(_, item, encoding)
	M.close()
	vim.cmd('split')
	M.jump(item, encoding)
end

M.next = function(_, _, _)
	vim.cmd('normal! j')
end

M.previous = function(_, _, _)
	vim.cmd('normal! k')
end

return M

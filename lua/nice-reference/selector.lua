local M = {}

local vim = vim

local format_item = function(item, maxFilenameWidth, useIcons)
	local fileName = item.filename:match("([^/]+)$")
	while fileName:len() < maxFilenameWidth do
		fileName = fileName .. " "
	end
	local line = item.lnum
	if line < 10 then
		line = line .. "  "
	elseif line < 100 then
		line = line .. " "
	end
	local icon = ""
	if useIcons then
		icon = require 'nvim-web-devicons'.get_icon(item.filename, item.filename:match([[/(\w+)$/]])) .. " "
	end
	return icon .. fileName .. " | " .. line .. " " .. item.text:gsub("^%s*(.-)%s*$", "%1")
end


M.select = function(config, items, encoding)
	if config.auto_choose and #items == 1 then
		vim.notify("Only one reference found")
		require 'nice-reference.actions'.on_choice(items[1], encoding)
		return
	end

	local cword = vim.fn.expand('<cword>')

	local bufer = vim.api.nvim_create_buf(false, true)

	vim.api.nvim_buf_set_option(bufer, "swapfile", false)
	vim.api.nvim_buf_set_option(bufer, "bufhidden", "wipe")
	vim.api.nvim_buf_set_option(bufer, "filetype", "NiceReferenceBuffer")

	local lines = {}
	local max_width = 1
	local max_filename_width = 0
	for _, item in pairs(items) do
		local croppedName = item.filename:match("([^/]+)$")
		max_filename_width = math.max(max_filename_width, croppedName:len())
	end
	for _, item in ipairs(items) do
		local line = format_item(item, max_filename_width, config.use_icons)
		max_width = math.max(max_width, vim.api.nvim_strwidth(line))
		table.insert(lines, line)
	end
	local winopt = {
		relative = config.relative,
		anchor = config.anchor,
		row = config.row,
		col = config.col,
		border = config.border,
		width = math.min(max_width, config.max_width),
		height = math.min(#lines, config.max_height),
		zindex = 150,
		style = "minimal",
	}

	vim.api.nvim_buf_set_lines(bufer, 0, -1, true, lines)
	vim.api.nvim_buf_set_option(bufer, "modifiable", false)

	local winnr = vim.api.nvim_open_win(bufer, true, winopt)
	vim.api.nvim_win_set_option(winnr, "winblend", config.winblend)
	vim.api.nvim_win_set_option(winnr, "cursorline", true)

	local function getSelectedItem()
		local cursor = vim.api.nvim_win_get_cursor(0)
		local id = cursor[1]
		return items[id]
	end

	local function map(key, command)
		vim.keymap.set(
			"n",
			key,
			function()
				if type(command) == "function" then
					command(items, getSelectedItem(), encoding)
				elseif type(command) == "string" then
					vim.cmd(command)
				else
					vim.notify("Invalid keybinding: use a function or a string")
				end
			end,
			{ silent = true, noremap = true, buffer = bufer }
		)
	end

	for key, action in pairs(config.mapping) do
		map(key, action)
	end

	if config.use_icons then
		local icon, color = require 'nvim-web-devicons'.get_icon_color(items[1].filename, items[1].filename:match([[/(\w+)$/]]))
		vim.cmd("hi def NiceReferenceIcon guifg=" .. color)
		vim.cmd([[syn match NiceReferenceIcon "]] .. icon .. [["]])
	end

	vim.cmd("hi def NiceReferenceItemName gui=bold")
	vim.cmd([[syn match NiceReferenceItemName "]] .. cword .. [["]])
end

return M

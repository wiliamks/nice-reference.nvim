local vim = vim
local util = require 'vim.lsp.util'

local M = {}

local config = {
    anchor = "NW",
    relative = "cursor",
    row = 1,
    col = 0,
    border = "rounded",
    winblend = 0,
    max_width = 120,
    max_height = 10,
	auto_choose = false,
	use_icons = pcall(require, 'nvim-web-devicons')
}

M.setup = function(opts)
	config.anchor = opts.anchor or config.anchor
	config.relative = opts.relative or config.relative
	config.row = opts.row or config.row
	config.col = opts.col or config.col
	config.border = opts.border or config.border
	config.winblend = opts.winblend or config.winblend
	config.max_width = opts.max_width or config.max_width
	config.max_height = opts.max_height or config.max_height
	config.auto_choose = opts.auto_choose or config.auto_choose

	local ok = pcall(require, 'nvim-web-devicons')
	config.use_icons = ok
end

M.references = function (context)
	local params = util.make_position_params()
  	params.context = context or {
    	includeDeclaration = true;
  	}
	vim.lsp.buf_request(0, 'textDocument/references', params, M.reference_handler)
end

M.reference_handler = function(err, result, ctx, _)
	if err then
		vim.notify('Error looking for references')
		return
	end
	if not result or vim.tbl_isempty(result) then
      	vim.notify('No reference found')
		return
	end

	local encoding = vim.lsp.get_client_by_id(ctx.client_id).offset_encoding

	local items = util.locations_to_items(result, encoding)

	require 'nice-reference.selector'.select(config, items, encoding)
end


return M

local M = {}

local modules = {
	"markdown.detab",
	"markdown.join",
	"markdown.movements",
	"markdown.renumber",
	"markdown.switch",
}

for _, module in ipairs(modules) do
	M = vim.tbl_extend("force", M, require(module))
end

function M.setup()
	if vim.b.markdown_nvim_loaded then
		return
	end


	local augroup = vim.api.nvim_create_augroup("markdown.nvim-augroup", {})

	-- Cache the current block, in case that calculation is slow:
	vim.b.markdown_nvim_current_block = { -1, -1 }
	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
		buffer = 0,
		group = augroup,
		callback = function()
			local row = require("markdown.utils").get_current_row()
			local start, stop = require("markdown.utils").detect_block(row)
			vim.b.markdown_nvim_current_block = {
				start,
				stop,
			}
		end,
	})

	vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
		buffer = 0,
		group = augroup,
		callback = function()
			require("markdown.renumber").renumber_ordered_list()
		end,
	})

	-- Create <Plug> bindings for each module
	M.maps = {}
	for _, module in ipairs(modules) do
		for _, map in ipairs(require(module).maps) do
			table.insert(M.maps, map)
			require("markdown.utils").set_plug_binding(map)
		end
	end

	vim.b.markdown_nvim_loaded = true
end

--selene: allow(unused_variable, unscoped_variables)
MarkdownNvim = M

return M

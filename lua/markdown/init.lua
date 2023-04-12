local M = {}

local modules = {
	"markdown.detab",
	"markdown.join",
	"markdown.movements",
	"markdown.newline",
	"markdown.renumber",
	"markdown.switch",
}

for _, module in ipairs(modules) do
	M = vim.tbl_extend("force", M, require(module))
end

M.maps = {}

function M.setup()
	-- Create <Plug> bindings for each module
	if #M.maps == 0 then
		for _, module in ipairs(modules) do
			for _, map in ipairs(require(module).maps) do
				table.insert(M.maps, map)
				require("markdown.utils").set_plug_binding(map)
			end
		end
	end

	if vim.b.markdown_nvim_loaded then
		return
	end

	local augroup = vim.api.nvim_create_augroup("markdown.nvim-augroup", {})

	-- Cache the current block, in case that calculation is slow:
	vim.b.markdown_nvim_current_block = { -1, -1 }
	vim.b.markdown_nvim_current_row = -1
	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
		buffer = 0,
		group = augroup,
		callback = function()
			local row = require("markdown.utils").get_current_row()
			if vim.b.markdown_nvim_current_row == row then
				return
			end
			vim.b.markdown_nvim_current_row = row
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

	-- If we are setting default mappings, set them here:
	if vim.b.markdown_nvim_do_not_set_default_maps ~= 1 or vim.g.markdown_nvim_do_not_set_default_maps ~= 1 then
		for _, map in pairs(require("markdown").maps) do
			require("markdown.utils").set_binding(map)
		end
	end
	-- If bindings aren't set, <Plug> bindings for all functionality are still defined by .setup()

	vim.b.markdown_nvim_loaded = true
end

--selene: allow(unused_variable, unscoped_variables)
MarkdownNvim = M

return M

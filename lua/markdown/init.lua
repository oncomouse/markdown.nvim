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
	if vim.b.markdown_nvim_loaded then return end

	vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
		buffer = 0,
		callback = function()
			require("markdown.renumber").renumber_ordered_list()
		end
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

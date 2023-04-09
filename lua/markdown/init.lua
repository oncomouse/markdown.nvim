local M = {}

local modules = {
	"markdown.delete",
	"markdown.detab",
	"markdown.join",
	"markdown.movements",
	"markdown.newline",
	"markdown.renumber",
	"markdown.switch",
	"markdown.tab",
}

for _, module in ipairs(modules) do
	M = vim.tbl_extend("force", M, require(module))
end

function M.setup()
	if vim.b.markdown_nvim_loaded then return end

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

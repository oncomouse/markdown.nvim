local M = {}

local modules = vim.g.markdown_nvim_modules or {
	"markdown.delete",
	"markdown.detab",
	"markdown.join",
	"markdown.movements",
	"markdown.newline",
	"markdown.paste",
	"markdown.renumber",
	"markdown.tab",
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

	local do_not_load = vim.b.markdown_nvim_do_not_set_default_maps == 1 or vim.b.markdown_nvim_do_not_set_default_maps == true or vim.g.markdown_nvim_do_not_set_default_maps == 1 or vim.g.markdown_nvim_do_not_set_default_maps == true

	-- If we are setting default mappings, set them here:
	if not do_not_load then
		for _, map in pairs(M.maps) do
			require("markdown.utils").set_binding(map)
		end
	end
	-- If bindings aren't set, <Plug> bindings for all functionality are still defined by .setup()

	vim.b.markdown_nvim_loaded = true
end

--selene: allow(unused_variable, unscoped_variables)
MarkdownNvim = M

return M

local M = {}

local modules = {
	"markdown.join",
	"markdown.detab",
	"markdown.newline",
	"markdown.movements",
}

for _, module in ipairs(modules) do
	M = vim.tbl_extend("force", M, require(module))
end

local run

function M.setup()
	if run then return end

	-- Create <Plug> bindings for each module
	M.maps = {}
	for _, module in ipairs(modules) do
		for _, map in ipairs(require(module).maps) do
			table.insert(M.maps, map)
			require("markdown.utils").set_plug_binding(map)
		end
	end

	run = true
end

--selene: allow(unused_variable, unscoped_variables)
MarkdownNvim = M

return M

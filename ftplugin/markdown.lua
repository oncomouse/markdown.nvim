require("markdown").setup()

-- If we are setting default mappings, set them here:
if vim.g.markdown_nvim_do_not_set_default_maps ~= 1 then
	for _,map in pairs(require("markdown").maps) do
		require("markdown.utils").set_binding(map)
	end
end
-- If bindings aren't set, <Plug> bindings for all functionality are still defined by .setup()

vim.opt_local.comments = vim.opt_local.comments - "n:>"

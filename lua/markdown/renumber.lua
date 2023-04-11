local M = {}

function M.renumber_ordered_list()
	local row = require("markdown.utils").get_current_row()
	local start, stop = unpack(vim.b.markdown_nvim_current_block)
	if start == -1 or stop == -1 then
		start, stop = require("markdown.utils").detect_block(row)
	end
	local lines = vim.api.nvim_buf_get_lines(0, start, stop + 1, false)
	local levels = {}
	local output = {}
	for _, line in ipairs(lines) do
		local spaces, contents = line:match("^(%s*)%d+([.] .*)")
		if spaces == nil then
			table.insert(output, line)
		else
			if not levels[spaces] then
				levels[spaces] = 1
			end
			table.insert(output, string.format("%s%d%s", spaces, levels[spaces], contents))
			levels[spaces] = levels[spaces] + 1
		end
	end
	vim.api.nvim_buf_set_lines(0, start, stop + 1, false, output)
end

M.trigger = [[:execute "normal \<Plug>(markdown-nvim-renumber)"<CR>]]

return require("markdown.utils").add_key_bindings(M, {
	{ "n", "<Plug>(markdown-nvim-renumber)", "<cmd>lua MarkdownNvim.renumber_ordered_list()<CR>", "<leader>mn" },
})

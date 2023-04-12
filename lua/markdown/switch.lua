local M = {}

function switch_line(line)
	local spaces, contents = line:match("^(%s*)%d+[.] (.*)")
	if spaces ~= nil then
		return string.format("%s* %s", spaces, contents)
	end
	spaces, contents = line:match("^(%s*)[*-] (.*)")
	if spaces ~= nil then
		return string.format("%s1. %s", spaces, contents)
	end
	return line
end

function M.switch_line()
	local start = require("markdown.utils").get_current_row()
	local col = vim.api.nvim_win_get_cursor(0)[2]
	local stop = start
	local line = vim.api.nvim_buf_get_lines(0, start, stop + 1, false)[1]
	if line:match("^%s*[*-] ") then
		col = col + 1
	elseif line:match("^%s*%d. ") then
		col = col - 1
	end
	vim.api.nvim_buf_set_lines(0, start, stop + 1, false, { switch_line(line) })
	vim.api.nvim_win_set_cursor(0, { start + 1, col })
end

function switch_lines(start, stop)
	local lines = vim.api.nvim_buf_get_lines(0, start, stop + 1, false)
	local output = {}
	for _, line in ipairs(lines) do
		table.insert(output, switch_line(line))
	end
	vim.api.nvim_buf_set_lines(0, start, stop + 1, false, output)
	require("markdown.renumber").renumber_ordered_list()
end

function M.switch()
	local row = require("markdown.utils").get_current_row()
	local start, stop = require("markdown.utils").detect_block(row)
	switch_lines(start, stop)
end

function M.switch_opfunc(mode)
	local start, _ = unpack(vim.api.nvim_buf_get_mark(0, mode == "visual" and "<" or "["))
	local stop, _ = unpack(vim.api.nvim_buf_get_mark(0, mode == "visual" and ">" or "]"))
	if start == 0 or stop == 0 then return end
	start = start - 1
	stop = stop - 1
	switch_lines(start, stop)
end

return require("markdown.utils").add_key_bindings(M, {
	{ "n", "<Plug>(markdown-nvim-switch)", "<cmd>lua MarkdownNvim.switch()<CR>", "<leader>mss" },
	{ "v", "<Plug>(markdown-nvim-switch-visual)", ":<c-u>lua MarkdownNvim.switch_opfunc('visual')<CR>", "<leader>ms" },
	{ "n", "<Plug>(markdown-nvim-switch_opfunc)", "<cmd>set opfunc=v:lua.require'markdown.switch'.switch_opfunc<CR>g@", "<leader>ms" },
	{ "i", "<Plug>(markdown-nvim-switch)", "<cmd>lua MarkdownNvim.switch_line()<CR>", "<C-Z>" },
})

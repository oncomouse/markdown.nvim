local M = {}

local register

function M.delete_opfunc(mode)
	if mode == nil then
		register = vim.v.register
		vim.opt.operatorfunc = "v:lua.MarkdownNvim.delete_opfunc"
	end
	if mode == "line" then
		vim.cmd([['[,']d ]] .. register)
	end
	if mode == "char" then
		local row_left, col_left = unpack(vim.api.nvim_buf_get_mark(0, "["))
		local row_right, col_right = unpack(vim.api.nvim_buf_get_mark(0, "]"))
		row_left = row_left - 1
		row_right = row_right - 1
		local output = {}
		if row_left == row_right then
			local line = vim.api.nvim_buf_get_lines(0, row_left, row_left + 1, false)[1]
			line = line:sub(0, col_left) .. line:sub(col_right + 2, #line)
			table.insert(output, line)
		else
			local start_line = vim.api.nvim_buf_get_lines(0, row_left, row_left + 1, false)[1]
			start_line = start_line:sub(1, col_left)
			local stop_line = vim.api.nvim_buf_get_lines(0, row_right, row_right + 1, false)[1]
			stop_line = stop_line:sub(col_right + 2, #stop_line)
			table.insert(output, start_line)
			table.insert(output, stop_line)
		end
		vim.api.nvim_buf_set_lines(0, row_left, row_right + 1, false, output)
	end
	vim.cmd([[exec "normal! \<Plug>(markdown-nvim-renumber)"]])
end

return require("markdown.utils").add_key_bindings(M, {
	{ "n", "<Plug>(markdown-nvim-delete-line)", [[<cmd>exec "normal! dd\<Plug>(markdown-nvim-renumber)"<CR>]], "dd" },
	{ "n", "<Plug>(markdown-nvim-delete-opfunc)", "<cmd>lua MarkdownNvim.delete_opfunc()<CR>g@", "d" },
})

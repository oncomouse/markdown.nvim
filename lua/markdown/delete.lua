local M = {}

local register

function M.delete_opfunc(mode)
	if mode == nil then
		register = vim.v.register
		vim.opt.operatorfunc = "v:lua.MarkdownNvim.delete_opfunc"
	end
	if mode == "line" then
		vim.cmd([['[,']d ]] .. register)
		return
	end
	local row_left, col_left, row_right, col_right
	if mode == "char" then
		row_left, col_left = unpack(vim.api.nvim_buf_get_mark(0, "["))
		row_right, col_right = unpack(vim.api.nvim_buf_get_mark(0, "]"))
	elseif mode == "visual" then
		row_left, col_left = unpack(vim.api.nvim_buf_get_mark(0, "<"))
		row_right, col_right = unpack(vim.api.nvim_buf_get_mark(0, ">"))
	end
	row_left = row_left - 1
	row_right = row_right - 1
	local output = {}
	if row_left == row_right then
		local line = vim.api.nvim_buf_get_lines(0, row_left, row_left + 1, false)[1]
		vim.fn.setreg(register, line:sub(col_left, col_right + 1))
		line = line:sub(0, col_left) .. line:sub(col_right + 2, #line)
		table.insert(output, line)
	else
		local deleted = vim.api.nvim_buf_get_lines(0, row_left, row_right + 1, false)

		-- New contents:
		local start_line = deleted[1]:sub(1, col_left)
		local stop_line = deleted[#deleted]:sub(col_right + 2, #deleted[#deleted])

		-- Register contents:
		deleted[1] = deleted[1]:sub(col_left, #deleted[1])
		deleted[#deleted] = deleted[#deleted]:sub(1, col_right + 1)
		vim.fn.setreg(register, table.concat(deleted, "\n"))

		table.insert(output, start_line)
		table.insert(output, stop_line)
	end
	vim.api.nvim_buf_set_lines(0, row_left, row_right + 1, false, output)
	vim.cmd([[exec "normal! \<Plug>(markdown-nvim-renumber)"]])
end

function M.delete_line()
	local row = require("markdown.utils").get_current_row()
	local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
	vim.fn.setreg(vim.v.register, line)
	vim.api.nvim_buf_set_lines(0, row, row + 1, false, {})
end

return require("markdown.utils").add_key_bindings(M, {
	{ "n", "<Plug>(markdown-nvim-delete-line)", [[<cmd>lua MarkdownNvim.delete_line()<CR><cmd>exec "normal! \<Plug>(markdown-nvim-renumber)"<CR>]], "dd" },
	{ "n", "<Plug>(markdown-nvim-delete-opfunc)", "<cmd>lua MarkdownNvim.delete_opfunc()<CR>g@", "d" },
	-- { "v", "<Plug>(markdown-nvim-delete-visual)", ":<C-u>lua MarkdownNvim.delete_opfunc('visual')<CR>", "d" },
})


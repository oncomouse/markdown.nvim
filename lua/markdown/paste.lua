local M = {}
function M.visual_paste()
	if vim.fn.visualmode() == "V" then
		if vim.fn.getregtype() == "V" then
			vim.cmd([[exe "normal! gv\"_c\<space>\<bs>\<esc>" . vim.v.count1 . '"' . vim.v.register . ']pk"_dd']])
		else
			vim.cmd([[exe "normal! gv\"_c\<space>\<bs>\<esc>" . vim.v.count1 . '"' . vim.v.register . ']p']])
		end
	else
		-- workaround strange Vim behavior (""p is no-op in visual mode)
		local reg = vim.v.register == '"' and "" or [[\"]] .. vim.v.register

		vim.cmd(string.format([[exe "normal! gv%d%sp"]], vim.v.count1, reg))
	end
end
return require("markdown.utils").add_key_bindings(M, {
	{ "n", "<Plug>(markdown-nvim-paste)", [[<cmd>execute "normal! " . v:count1 . "p\<Plug>(markdown-nvim-renumber)"<CR>]], "p" },
	{ "n", "<Plug>(markdown-nvim-paste-above)", [[<cmd>execute "normal! " . v:count1 . "P\<Plug>(markdown-nvim-renumber)"<CR>]], "P" },
	{
		"x",
		"<Plug>(markdown-nvim-paste)",
		[[:<C-u>lua require'markdown.paste'.visual_paste()<CR><cmd>execute "normal! \<Plug>(markdown-nvim-renumber)"<CR>]],
		{ "p", "P" },
		{ silent = true },
	},
})

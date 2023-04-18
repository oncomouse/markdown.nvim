local M = {}

return require("markdown.utils").add_key_bindings(M, {
	{ "n", "<Plug>(markdown-nvim-paste)", [[<cmd>execute "normal! p\<Plug>(markdown-nvim-renumber)"<CR>]], "p" },
	{ "n", "<Plug>(markdown-nvim-paste-above)", [[<cmd>execute "normal! P\<Plug>(markdown-nvim-renumber)"<CR>]], "P" },
})

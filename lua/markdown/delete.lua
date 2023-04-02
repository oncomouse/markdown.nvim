local M = {}

return require("markdown.utils").add_key_bindings(M, {
	{ "n", "<Plug>(markdown-nvim-delete-line)", [[<cmd>exec "normal! dd\<Plug>(markdown-nvim-renumber)"<CR>]], "dd" },
})

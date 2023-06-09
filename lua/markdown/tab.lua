local M = {}

function M.tab(normal_mode)
	local line = vim.api.nvim_get_current_line()
	local operation = normal_mode and ">>" or "<C-T>"
	if line:match("^%s*%d+[.] ") then
		return string.format(
			"%s<Esc>_ce1.<Esc>%s%s",
			operation,
			require("markdown.renumber").trigger,
			normal_mode and "" or "A"
		)
	end
	return operation
end

M.tab_opfunc = function(mode)
	if mode == nil then
		vim.o.operatorfunc = "v:lua.require'markdown.tab'.tab_opfunc"
		return "g@"
	end
	local target = mode == "visual" and "'<,'>" or "'[,']"
	vim.cmd(string.format([[execute "%snormal! >>\<Plug>(markdown-nvim-renumber)"]], target))
	return ""
end

return require("markdown.utils").add_key_bindings(M, {
	{ "i", "<Plug>(markdown-nvim-tab)", M.tab, "<C-t>", { expr = true } },
	{
		"n",
		"<Plug>(markdown-nvim-tab)",
		function()
			return M.tab(true)
		end,
		">>",
		{ expr = true },
	},
	{
		"n",
		"<Plug>(markdown-nvim-tab-opfunc)",
		M.tab_opfunc,
		">",
		{ expr = true },
	},
	{
		"v",
		"<Plug>(markdown-nvim-tab-opfunc)",
		":<C-u>lua require'markdown.tab'.tab_opfunc('visual')<CR>",
		">",
		{ silent = true },
	},
})

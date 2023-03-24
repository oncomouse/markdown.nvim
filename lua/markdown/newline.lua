local M = {}

function M.insert_newline(above)
	local action = above and "O" or "o"
	local line = vim.api.nvim_get_current_line()
	if line:match("^> ") then
		return action .. "> "
	end
	return action
end

return require("markdown.utils").add_key_bindings(M, {
	{
		"n",
		"<Plug>(markdown-nvim-newline_below)",
		M.insert_newline,
		"o",
		{ expr = true },
	},
	{
		"n",
		"<Plug>(markdown-nvim-newline_above)",
		function() return M.insert_newline(true) end,
		"O",
		{ expr = true },
	},
})

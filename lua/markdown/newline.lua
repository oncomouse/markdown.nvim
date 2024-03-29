local M = {}

function M.insert_newline(above)
	local list_chars = vim.b.markdown_nvim_unordered_list_chars or "[*-]"
	local action = above and "O" or "o"
	local line = vim.api.nvim_get_current_line()
	local lnum = require("markdown.utils").get_current_row()
	local next_line = vim.api.nvim_buf_get_lines(
		0,
		lnum + (above and -1 or 1),
		lnum + (above and 0 or 2),
		false
	)[1]
	if line:match("^> ") then
		return action .. "> "
	end
	if next_line and next_line:match("^> ") then
		return action .. "> "
	end
	-- Lists, ordered and unordered
	local space, number = line:match("^(%s*)(%d+)[.] ")
	if not space and next_line then
		space, _ = next_line:match("^(%s*)(%d+)[.] ")
	end
	if space and number then
		return string.format("%s%d. <Esc>%sA", action, number, require("markdown.renumber").trigger)
	end
	space, number = line:match("^(%s*)(" .. list_chars .. ") ")
	if not space and next_line then
		space, number = next_line:match("^(%s*)(" .. list_chars .. ") ")
	end
	if space then
		return string.format("%s%s ", action, number)
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
		function()
			return M.insert_newline(true)
		end,
		"O",
		{ expr = true },
	},
})

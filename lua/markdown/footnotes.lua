local M = {}

function M.follow_note()
	local line = vim.api.nvim_get_current_line()
	-- Find reference:
	local in_definition = string.match(line, "^%[%^(%w+)%]:")
	if in_definition then
		local l = vim.fn.searchpos(string.format([==[\[\^%s\][^:]]==], in_definition), "bnW")	
		if l[1] > 0 then
			vim.api.nvim_win_set_cursor(0, { l[1], l[2] + 1 })
		end
		return
	end
	-- Find definition:
	local in_ref = vim.fn.search([==[\[\^\([^]]*\%#[^]]*\)\]]==], 'cn')
	if in_ref then
		local name = vim.fn.matchlist(line, [==[\[\^\([^]]\+\)\]]==])[2]
		local l = vim.fn.searchpos(string.format([==[^\[\^%s\]: ]==], name), 'en')
		if l[1] > 0 then
			vim.api.nvim_win_set_cursor(0, { l[1], l[2] })
		end
		return
	end

end

return require("markdown.utils").add_key_bindings(M, {
	{
		"n",
		"<Plug>(markdown-nvim-footnote)",
		[[<cmd>lua require'markdown.footnotes'.follow_note()<CR>]],
		"<leader>mf",
	},
})

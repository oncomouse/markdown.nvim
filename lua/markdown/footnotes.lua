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
	else
		local in_ref = vim.fn.search([==[\[\^\([^]]*\%#[^]]*\)\]]==], "cn")
		if in_ref then
			local name = vim.fn.matchlist(line, [==[\[\^\([^]]\+\)\]]==])[2]
			local l = vim.fn.searchpos(string.format([==[^\[\^%s\]: ]==], name), "en")
			if l[1] > 0 then
				vim.api.nvim_win_set_cursor(0, { l[1], l[2] })
			else
				-- Run a project grep for the name
				vim.cmd(string.format("silent! grep! '%s'", string.format([==[^\[\^%s\]: ]==], name)))
				if #vim.fn.getqflist() > 0 then
					vim.cmd("copen")
				else -- Make sure quickfix is closed
					vim.cmd("cclose")
				end
			end
		end
	end
	-- Find definition:
end

return require("markdown.utils").add_key_bindings(M, {
	{
		"n",
		"<Plug>(markdown-nvim-footnote)",
		[[<cmd>lua require'markdown.footnotes'.follow_note()<CR>]],
		"<leader>mf",
	},
})

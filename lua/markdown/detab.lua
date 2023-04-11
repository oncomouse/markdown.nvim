local M = {}

local detab_regexes = {
	[[^[*-] \(\[.\]\)\{0,1\}]],
	[[^\d\+\. \(\[.\]\)\{0,1\}]],
	"^> ",
}

-- Works like string.match but for vim regexes:
local function match_vimregex(line, regex)
	local match = nil
	local start, ed = vim.regex(regex):match_str(line)
	if start ~= nil then
		match = string.sub(line, start, ed)
	end
	return match
end

function M.detab(normal_mode)
	local line = vim.api.nvim_get_current_line()
	for _, r in pairs(detab_regexes) do
		local match = match_vimregex(line, r)
		if match then
			local savepos = vim.fn.winsaveview().col
			local restore_input = normal_mode and "" or ((savepos == #line) and "$a" or savepos - #match .. "li")
			local leave_insert = normal_mode and "" or "<Esc>"
			return string.format([[%s0"_%ddl%s]], leave_insert, #match, restore_input)
		end
	end
	local operation = normal_mode and "<<" or "<C-D>"
	-- Check if we need to change number for an ordered list:
	local row = require("markdown.utils").get_current_row()
	local spaces = line:match("^(%s*)%d+[.] ")
	if row > 1 and spaces then
		local up_spaces, number = string.match(vim.api.nvim_buf_get_lines(0, row - 2, row - 1, false)[1], "^(%s*)(%d+)[.] ")
		local indent_step = require("markdown.utils").indent_step()
		if number and #up_spaces == #spaces - indent_step then
			return string.format("%s<Esc>_ce%d.<Esc>%s", operation, tonumber(number) + 1, normal_mode and "" or "A")
		end
		return string.format(
			"%s<Esc>_ce1.<Esc>%s",
			operation,
			normal_mode and "<Esc>" or "A"
		)
	end
	return operation
end

M.detab_opfunc = function(mode)
	local target = mode == "visual" and "'<,'>" or "'[,']"
	vim.cmd(string.format([[execute "%snormal! <<"]], target))
end


return require("markdown.utils").add_key_bindings(M, {
	{ "i", "<Plug>(markdown-nvim-detab)", M.detab, "<C-d>", { expr = true } },
	{
		"n",
		"<Plug>(markdown-nvim-detab)",
		function()
			return M.detab(true)
		end,
		"<<",
		{ expr = true },
	},
	{
		"n",
		"<Plug>(markdown-nvim-detab-opfunc)",
		"<cmd>set operatorfunc=v:lua.MarkdownNvim.detab_opfunc<CR>g@",
		"<",
	},
	{
		"v",
		"<Plug>(markdown-nvim-detab-opfunc)",
		":<C-u>lua MarkdownNvim.detab_opfunc('visual')<CR>",
		"<",
	},
})

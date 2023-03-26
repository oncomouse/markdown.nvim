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

function M.renumber_ordered_list()

end

function M.detab()
	local line = vim.api.nvim_get_current_line()
	for _, r in pairs(detab_regexes) do
		local match = match_vimregex(line, r)
		if match then
			local savepos = vim.fn.winsaveview().col
			local restore_input = (savepos == #line) and "$a" or savepos - #match .. "li"
			return '<Esc>0"_' .. #match .. "dl" .. restore_input
		end
	end
	-- Check if we need to change number for an ordered list:
	local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
	local number = nil
	if row > 1 and line:match("^%s*%d+[.] ") then
		number = string.match(vim.api.nvim_buf_get_lines(0, row - 2, row - 1, false)[1], "^%s*(%d+)[.] ")
		if number then
			return string.format("<C-D><Esc>_ce%d.<Esc>A", tonumber(number) + 1)
		end
		return "<C-D><Esc>_ce1.<Esc>:lua MarkdownNvim.renumber_ordered_list()<CR>A"
	end
	return "<c-d>"
end

function M.tab()
	local line = vim.api.nvim_get_current_line()
	if line:match("^%s*%d+[.] ") then
		return "<c-t><Esc>_ce1.<Esc>:lua MarkdownNvim.renumber_ordered_list()<CR>A"
	end
	return "<c-t>"
end

return require("markdown.utils").add_key_bindings(M, {
	{ "i", "<Plug>(markdown-nvim-detab)", M.detab, "<C-d>", { expr = true } },
	{ "i", "<Plug>(markdown-nvim-tab)", M.tab, "<C-t>", { expr = true } },
})

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
	return "<c-d>"
end

return require("markdown.utils").add_key_bindings(M, {
	{ "i", "<Plug>(markdown-nvim-detab)", M.detab, "<C-d>", { expr = true } }
})

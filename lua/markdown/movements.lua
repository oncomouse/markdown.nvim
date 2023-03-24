local M = {}
-- The vim-markdown movement commands (source https://github.com/preservim/vim-markdown/blob/master/ftplugin/markdown.vim):
local headersRegexp = [[\v^(#|.+\n(\=+|-+)$)]]
local headersRegexpCompiled = vim.regex(headersRegexp)
local levelRegexpDict = {
	vim.regex([[\v^(#[^#]@=|.+\n\=+$)]]),
	vim.regex([[\v^(##[^#]@=|.+\n-+$)]]),
	vim.regex([[\v^###[^#]@=]]),
	vim.regex([[\v^####[^#]@=]]),
	vim.regex([[\v^#####[^#]@=]]),
	vim.regex([[\v^######[^#]@=]]),
}

function M.move_to_next_header()
	if vim.fn.search(headersRegexp, "W") == 0 then
		vim.print("no next header")
	end
end

local function get_header_line_num(l)
	if l == nil then
		l = vim.fn.line(".")
	end
	while l > 0 do
		if headersRegexpCompiled:match_str(vim.fn.join(vim.fn.getline(l, l + 1), "\n")) then
			return l
		end
		l = l - 1
	end
	return 0
end

local function get_level_of_header_at_line(linenum)
	local lines = vim.fn.join(vim.fn.getline(linenum, linenum + 1), "\n")
	for i, regex in ipairs(levelRegexpDict) do
		if regex:match_str(lines) then
			return i
		end
	end
	return 0
end

local function get_header_level(line)
	if line == nil then
		line = vim.fn.line(".")
	end
	local linenum = get_header_line_num(line)
	if linenum ~= 0 then
		return get_level_of_header_at_line(linenum)
	else
		return 0
	end
end

local function get_previous_header_line_number_at_level(level, line)
	if line == nil then
		line = vim.fn.line(".")
	end
	local l = line
	while l > 0 do
		if levelRegexpDict[level]:match_str(vim.fn.join(vim.fn.getline(l, l + 1), "\n")) then
			return l
		end
		l = l - 1
	end
	return 0
end

local function get_next_header_line_number_at_level(level, line)
	if line == nil then
		line = vim.fn.line(".")
	end
	local l = line
	while l <= vim.fn.line("$") do
		if levelRegexpDict[level]:match_str(vim.fn.join(vim.fn.getline(l, l + 1), "\n")) then
			return l
		end
		l = l + 1
	end
	return 0
end

local function get_parent_header_line_number(line)
	if line == nil then
		line = vim.fn.line(".")
	end
	local level = get_header_level(line)
	local linenum
	if level > 1 then
		linenum = get_previous_header_line_number_at_level(level - 1, line)
		return linenum
	end
	return 0
end

function M.move_to_previous_header()
	local curHeaderLineNumber = get_header_line_num()
	local noPreviousHeader = false
	if curHeaderLineNumber <= 1 then
		noPreviousHeader = true
	else
		local previousHeaderLineNumber = get_header_line_num(curHeaderLineNumber - 1)
		if previousHeaderLineNumber == 0 then
			noPreviousHeader = true
		else
			vim.fn.cursor(previousHeaderLineNumber, 1)
		end
	end
	if noPreviousHeader then
		vim.print("no previous header")
	end
end

function M.move_to_parent_header()
	local linenum = get_parent_header_line_number()
	if linenum ~= 0 then
		vim.fn.setpos("''", vim.fn.getpos("."))
		vim.fn.cursor(linenum, 1)
	else
		vim.print("no parent header")
	end
end

function M.move_to_next_sibling_header()
	local curHeaderLineNumber = get_header_line_num()
	local curHeaderLevel = get_level_of_header_at_line(curHeaderLineNumber)
	local curHeaderParentLineNumber = get_parent_header_line_number()
	local nextHeaderSameLevelLineNumber = get_next_header_line_number_at_level(curHeaderLevel, curHeaderLineNumber + 1)
	local noNextSibling = false
	if nextHeaderSameLevelLineNumber == 0 then
		noNextSibling = true
	else
		local nextHeaderSameLevelParentLineNumber = get_parent_header_line_number(nextHeaderSameLevelLineNumber)
		if curHeaderParentLineNumber == nextHeaderSameLevelParentLineNumber then
			vim.fn.cursor(nextHeaderSameLevelLineNumber, 1)
		else
			noNextSibling = true
		end
	end
	if noNextSibling then
		vim.print("no next sibling header")
	end
end

function M.move_to_previous_sibling_header()
	local curHeaderLineNumber = get_header_line_num()
	local curHeaderLevel = get_level_of_header_at_line(curHeaderLineNumber)
	local curHeaderParentLineNumber = get_parent_header_line_number()
	local previousHeaderSameLevelLineNumber =
		get_previous_header_line_number_at_level(curHeaderLevel, curHeaderLineNumber - 1)
	local noPreviousSibling = false
	if previousHeaderSameLevelLineNumber == 0 then
		noPreviousSibling = true
	else
		local previousHeaderSameLevelParentLineNumber = get_parent_header_line_number(previousHeaderSameLevelLineNumber)
		if curHeaderParentLineNumber == previousHeaderSameLevelParentLineNumber then
			vim.fn.cursor(previousHeaderSameLevelLineNumber, 1)
		else
			noPreviousSibling = true
		end
	end
	if noPreviousSibling then
		vim.print("no previous sibling header")
	end
end

function M.move_to_cur_header()
	local lineNum = get_header_line_num()
	if lineNum ~= 0 then
		vim.fn.cursor(lineNum, 1)
	else
		vim.print("outside any header")
	end
	return lineNum
end

function vis(f)
	return function(...)
		vim.cmd([[normal! gv]])
		f(...)
	end
end

return require("markdown.utils").add_key_bindings(M, {
	-- Movements sourced from vim-markdown:
	{ "n", "<Plug>(markdown-nvim-next_header)", M.move_to_next_header, "]]", { silent = true } },
	{ "v", "<Plug>(markdown-nvim-next_header)", vis(M.move_to_next_header), "]]" , { silent = true } },
	{ "n", "<Plug>(markdown-nvim-previous_header)", M.move_to_previous_header, "[[", { silent = true } },
	{ "v", "<Plug>(markdown-nvim-previous_header)", vis(M.move_to_previous_header), "[[", { silent = true } },
	{ "n", "<Plug>(markdown-nvim-next_sibling_header)", M.move_to_next_sibling_header, "][", { silent = true } },
	{ "v", "<Plug>(markdown-nvim-next_sibling_header)", vis(M.move_to_next_sibling_header), "][", { silent = true } },
	{ "n", "<Plug>(markdown-nvim-previous_sibling_header)", M.move_to_previous_sibling_header, "[]", { silent = true } },
	{ "v", "<Plug>(markdown-nvim-previous_sibling_header)", vis(M.move_to_previous_sibling_header), "[]", { silent = true } },
	{ "n", "<Plug>(markdown-nvim-parent_header)", M.move_to_parent_header, "]u", { silent = true } },
	{ "v", "<Plug>(markdown-nvim-parent_header)", vis(M.move_to_parent_header), "]u", { silent = true } },
	{ "n", "<Plug>(markdown-nvim-current_header)", M.move_to_cur_header, "]h", { silent = true } },
	{ "v", "<Plug>(markdown-nvim-current_header)", vis(M.move_to_cur_header), "]h", { silent = true } },
})

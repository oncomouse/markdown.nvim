local M = {}

local join_patterns = {
	"^> ", -- Block quotes
	"^%s*([0-9]+%. )", -- Ordered lists
	"^%s*([*-] )", -- Bulleted lists
}

local function find_match(line, pattern)
	local start, stop, match = line:find(pattern)
	local results = { start, stop, match }
	return start ~= nil, results
end

local function do_substitution(line, results, no_indent)
	local start, stop, match = unpack(results)
	local ws = ""
	if no_indent then
		ws = line:sub(start, (match == nil and 0 or stop - #match))
	end
	line = ws .. line:sub(stop + 1)
	return line
end

local function find_active_pattern(line, sub, no_indent)
	local active_pattern = nil
	for _, pattern in pairs(join_patterns) do
		local found, results = find_match(line, pattern)
		if found then
			active_pattern = pattern
			if sub then
				line = do_substitution(line, results, no_indent)
			end
			break
		end
	end
	if not no_indent and active_pattern == nil and sub then
		line = line:gsub("^%s+", "")
	end
	return active_pattern, line
end

local function join_lines(linenr, end_linenr, no_indent)
	local active_pattern = nil
	local lines = {}
	for _, ln in pairs(vim.fn.range(linenr, end_linenr)) do
		local line = vim.fn.getline(ln)
		local found, results
		if active_pattern then
			found, results = find_match(line, active_pattern)
		end
		if found then
			line = do_substitution(line, results, no_indent)
		else
			active_pattern, line = find_active_pattern(line, ln ~= linenr, no_indent)
		end
		if #line > 0 then
			table.insert(lines, line)
		end
	end
	vim.api.nvim_buf_set_lines(0, linenr - 1, end_linenr, false, { vim.fn.join(lines, no_indent and "" or " ") })
end

function M.join(no_indent)
	local linenr = vim.fn.line(".")
	local end_linenr = linenr + (vim.v.count == 0 and 1 or vim.v.count)
	join_lines(linenr, end_linenr, no_indent)
end

function M.join_opfunc(mode)
	-- Handle J vs gJ:
	local function do_opfunc(m)
		vim.b.dotfiles_markdown_join_no_indent = m
		vim.opt.operatorfunc = "v:lua.require'markdown.join'.join_opfunc" -- Can't have parentheses
		return "g@"
	end
	if type(mode) == "nil" then
		return do_opfunc(false)
	end
	if type(mode) == "boolean" then
		return function()
			return do_opfunc(mode)
		end
	end

	-- Read whether we are running J or gJ:
	local no_indent = vim.b.dotfiles_markdown_join_no_indent
	vim.b.dotfiles_markdown_join_no_indent = nil

	-- This code is from mini.nvim's comment module
	local mark_left, mark_right = "[", "]"
	if mode == "visual" then
		mark_left, mark_right = "<", ">"
	end

	local line_left, col_left = unpack(vim.api.nvim_buf_get_mark(0, mark_left))
	local line_right, col_right = unpack(vim.api.nvim_buf_get_mark(0, mark_right))

	-- Do nothing if "left" mark is not on the left (earlier in text) of "right"
	-- mark (indicating that there is nothing to do, like in comment textobject).
	if (line_left > line_right) or (line_left == line_right and col_left > col_right) then
		return
	end
	--- End code from mini.nvim
	join_lines(line_left, line_right, no_indent)
end

return require("markdown.utils").add_key_bindings(M, {
	{ "n", "<Plug>(markdown-nvim-join)", "<cmd>lua MarkdownNvim.join()<cr>", "J" },
	{ "n", "<Plug>(markdown-nvim-join_indent)", "<cmd>lua MarkdownNvim.join(true)<cr>", "gJ" },
	{ "v", "<Plug>(markdown-nvim-join-visual)", ":<c-u>lua MarkdownNvim.join_opfunc()<cr>", "J" },
	{ "v", "<Plug>(markdown-nvim-join_indent-visual)", ":<c-u>lua MarkdownNvim.join_opfunc(true)<cr>", "gJ" },
})

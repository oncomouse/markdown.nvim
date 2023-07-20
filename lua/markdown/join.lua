local M = {}


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
	local list_chars = vim.b.markdown_nvim_unordered_list_chars or "[*-]"
	local join_patterns = {
		"^> ", -- Block quotes
		"^%s*([0-9]+%. )", -- Ordered lists
		"^%s*(" .. list_chars .. " )", -- Bulleted lists
	}

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
	local end_linenr = linenr + vim.v.count1
	join_lines(linenr, end_linenr, no_indent)
end

function M.join_visual(no_indent)
	local line_left, _ = unpack(vim.api.nvim_buf_get_mark(0, "<"))
	local line_right, _ = unpack(vim.api.nvim_buf_get_mark(0, ">"))
	join_lines(line_left, line_right, no_indent)
end

return require("markdown.utils").add_key_bindings(M, {
	{ "n", "<Plug>(markdown-nvim-join)", "<cmd>lua require'markdown.join'.join()<cr>", "J" },
	{ "n", "<Plug>(markdown-nvim-join_indent)", "<cmd>lua require'markdown.join'.join(true)<cr>", "gJ" },
	{ "v", "<Plug>(markdown-nvim-join-visual)", ":<c-u>lua require'markdown.join'.join_visual()<cr>", "J", { silent = true } },
	{
		"v",
		"<Plug>(markdown-nvim-join_indent-visual)",
		":<c-u>lua require'markdown.join'.join_visual(true)<cr>",
		"gJ",
		{ silent = true },
	},
})

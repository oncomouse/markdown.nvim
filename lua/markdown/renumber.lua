local M = {}

function detect_indent(row)
	local line = vim.api.nvim_buf_get_lines(0, row, row + 1 , false)[1]
	local spaces = string.match(line, "^(%s*)")
	if not spaces then
		return
	end
	local i = row - 2
	while i >= 0 do
		local l = vim.api.nvim_buf_get_lines(0, i, i + 1, false)
		if #l == 0 then
			break
		end
		l = l[1]
		local s = string.match(l, "^(%s*)")
		if s == nil then break end
		if s == nil or #s ~= #spaces then
			break
		end
		i = i - 1
	end
	local start = i + 2
	i = row + 1
	while i >= 1 do
		local l = vim.api.nvim_buf_get_lines(0, i, i + 1, false)
		if #l == 0 then
			break
		end
		l = l[1]
		local s = string.match(l, "^(%s*)")
		if s == nil or #s ~= #spaces then
			break
		end
		i = i + 1
	end
	local stop = i - 1
	return start - 1, stop - 1
end

function M.renumber_ordered_list()
	local row = require("markdown.utils").get_current_row()
	local start, stop = detect_indent(row)
	local lines = vim.api.nvim_buf_get_lines(0, start, stop + 1, false)
	local line_number = 1
	for num, line in ipairs(lines) do
		local spaces, contents = line:match("^(%s*)%d+([.] .*$)")
		if spaces ~= nil then
			line_number = line_number + 1
		end
	end
end

return require("markdown.utils").add_key_bindings(M, {})

local M = {}

function M.renumber_ordered_list()
	local row = require("markdown.utils").get_current_row()
	local line = vim.api.nvim_get_current_line()
	local spaces = string.match(line, "^(%s*)%d+[.] ")
	if not spaces then
		return
	end
	local i = row - 2
	while i >= 0 do
		local l = vim.api.nvim_buf_get_lines(0, i, i + 1, false)
		if #l == 0 then
			break
		end
		vim.print(l, i)
		l = l[1]
		local s = string.match(l, "^(%s*)%d+[.] ")
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
		local s = string.match(l, "^(%s*)%d+[.] ")
		if s == nil or #s ~= #spaces then
			break
		end
		i = i + 1
	end
	local stop = i - 1
	vim.print(start, stop)
end

return require("markdown.utils").add_key_bindings(M, {})

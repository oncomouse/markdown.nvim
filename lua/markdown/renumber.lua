local M = {}

function M.renumber_ordered_list()
	local row = require("markdown.utils").get_current_row()
	local spaces, _ = string.match("^(%s*)(%d+)[.] ", vim.api.nvim_get_current_line())
	if not spaces then
		return
	end
	local i = row - 1
	while i >= 1 do
		local l = vim.api.nvim_buf_get_lines(0, i, i + 1, false)
		if #l == 0 then
			break
		end
		l = l[1]
		local s = string.match("^(%s*)%d+[.] ", l)
		if s == nil or #s ~= #spaces then
			break
		end
		i = i - 1
	end
	local start = i
	i = row + 1
	while i >= 1 do
		local l = vim.api.nvim_buf_get_lines(0, i, i + 1, false)
		if #l == 0 then
			break
		end
		l = l[1]
		local s = string.match("^(%s*)%d+[.] ", l)
		if s == nil or #s ~= #spaces then
			break
		end
		i = i + 1
	end
	local stop = i
	vim.print(start, stop)
end

return require("markdown.utils").add_key_bindings(M, {})

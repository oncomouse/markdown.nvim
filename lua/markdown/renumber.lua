local M = {}

function detect_block(row)
	local i = row - 2
	while i >= 0 do
		local l = vim.api.nvim_buf_get_lines(0, i, i + 1, false)
		if #l == 0 then
			break
		end
		l = l[1]
		if #l == 0 then break end
		i = i - 1
	end
	local start = i + 1
	i = row + 1
	while i >= 1 do
		local l = vim.api.nvim_buf_get_lines(0, i, i + 1, false)
		if #l == 0 then
			break
		end
		l = l[1]
		if #l == 0 then break end
		i = i + 1
	end
	local stop = i - 1
	return start, stop
end

function M.renumber_ordered_list()
	local row = require("markdown.utils").get_current_row()
	local start, stop = detect_block(row)
	local lines = vim.api.nvim_buf_get_lines(0, start, stop + 1, false)
	local levels = {}
	local output = {}
	for _, line in ipairs(lines) do
		local spaces, contents = line:match("^(%s*)%d+([.] .*)")
		if spaces == nil then
			table.insert(output, line)
		else
			if not levels[spaces] then
				levels[spaces] = 1
			end
			table.insert(output, string.format("%s%d%s", spaces, levels[spaces], contents))
			levels[spaces] = levels[spaces] + 1
		end
	end
	vim.api.nvim_buf_set_lines(0, start, stop + 1, false, output)
end

return require("markdown.utils").add_key_bindings(M, {})

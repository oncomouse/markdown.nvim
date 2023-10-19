local M = {}

function M.add_key_bindings(module, keys)
	return setmetatable(module, {
		__index = {
			maps = keys,
		},
	})
end

function M.set_plug_binding(binding)
	local opts = vim.tbl_extend("force", {
		desc = type(binding[3]) == "string" and binding[3] or binding[2],
	}, binding[5] or {})
	vim.keymap.set(binding[1], binding[2], binding[3], opts)
end

function M.set_binding(binding)
	local maps = type(binding[4]) == "string" and { binding[4] } or binding[4]
	for _, map in ipairs(maps) do
		vim.keymap.set(binding[1], map, binding[2], { buffer = true, desc = binding[2] })
	end
end

function M.indent_step(bufnr)
	return vim.api.nvim_get_option_value("expandtab", { buf = bufnr or 0 })
			and vim.api.nvim_get_option_value("softtabstop", { buf = bufnr or 0 })
		or 1
end

function M.get_current_row()
	return vim.api.nvim_win_get_cursor(0)[1] - 1
end

function M.detect_block(row)
	local i = row - 2
	while i >= 0 do
		local l = vim.api.nvim_buf_get_lines(0, i, i + 1, false)
		if #l == 0 then
			break
		end
		l = l[1]
		if #l == 0 then
			break
		end
		i = i - 1
	end
	local start = i + 1
	if start < 0 then
		start = 0
	end
	i = row + 1
	while i >= 1 do
		local l = vim.api.nvim_buf_get_lines(0, i, i + 1, false)
		if #l == 0 then
			break
		end
		l = l[1]
		if #l == 0 then
			break
		end
		i = i + 1
	end
	local stop = i - 1
	return start, stop
end

return M

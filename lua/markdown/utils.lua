local M = {}

function M.add_key_bindings(module, keys)
	return setmetatable(module, {
		__index = {
			maps = keys,
		},
	})
end

function M.set_plug_binding(binding)
	vim.keymap.set(binding[1], binding[2], binding[3], binding[5] or {})
end

function M.set_binding(binding)
	vim.keymap.set(binding[1], binding[4], binding[2], { buffer = true })
end

function M.indent_step(bufnr)
	return vim.api.nvim_buf_get_option(bufnr or 0, "expandtab")
			and vim.api.nvim_buf_get_option(bufnr or 0, "softtabstop")
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

-- Wrapper for operatorfunc functions:
function M.opfunc(fn)
	if type(fn) == "function" then
		return function(mode)
			if mode == nil then
				vim.g.markdown_nvim_opfunc = fn
				vim.opt.operatorfunc = "v:lua.require'markdown.nvim.utils'.opfunc" -- Can't have parentheses
				return "g@"
			end
		end
	end
	local mode = fn
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

	return vim.g.markdown_nvim_opfunc(line_left, line_right)
end

return M

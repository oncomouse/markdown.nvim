local M = {}

function M.add_key_bindings(module, keys)
	return setmetatable(module, {
		__index = {
			maps = keys,
		}
	})
end

function M.set_plug_binding(binding)
	vim.keymap.set(binding[1], binding[2], binding[3], binding[5] or {})
end

function M.set_binding(binding)
	vim.keymap.set(binding[1], binding[4], binding[2], { buffer = true })
end

function M.indent_step(bufnr)
	return vim.api.nvim_buf_get_option(bufnr or 0, "expandtab") and vim.api.nvim_buf_get_option(bufnr or 0, "softtabstop") or 1
end

function M.get_current_row()
	return vim.api.nvim_win_get_cursor(0)[1]
end

return M

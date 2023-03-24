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

return M

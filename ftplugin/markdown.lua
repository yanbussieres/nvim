vim.keymap.set("n", "<CR>", function()
	local clients = vim.lsp.get_clients({ bufnr = 0, method = "textDocument/definition" })
	if vim.tbl_isempty(clients) then
		return vim.api.nvim_replace_termcodes("<CR>", true, true, true)
	end
	vim.lsp.buf.definition({
		on_list = function(list)
			local seen = {}
			list.items = vim.tbl_filter(function(item)
				if seen[item.filename] then
					return false
				end
				seen[item.filename] = true
				return true
			end, list.items)
			vim.fn.setqflist({}, " ", { title = list.title, items = list.items })
			vim.cmd("cfirst")
		end,
	})
	return ""
end, { buffer = true, expr = true, desc = "Follow [M]arkdown link" })

vim.keymap.set("n", "<leader>x", function()
	local line = vim.api.nvim_get_current_line()
	if not line:match("^%s*[-*+]%s*%[") then
		return
	end
	if line:match("%[ %]") then
		line = line:gsub("%[ %]", "[x]", 1)
	elseif line:match("%[[xX]%]") then
		line = line:gsub("%[[xX]%]", "[ ]", 1)
	end
	vim.api.nvim_set_current_line(line)
end, { buffer = true, desc = "Toggle markdown checkbox" })

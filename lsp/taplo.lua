---@diagnostic disable: undefined-doc-name
---@type vim.lsp.Config
return {
	cmd = { "taplo", "lsp", "stdio" },
	filetypes = { "toml" },
	root_markers = { "taplo.toml", ".taplo.toml", "Cargo.toml", ".git" },
}

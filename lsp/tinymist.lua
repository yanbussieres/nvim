---@diagnostic disable: undefined-doc-name
---@type vim.lsp.Config
return {
	cmd = { "tinymist" },
	filetypes = { "typst" },
	root_markers = { "typst.toml", ".git" },
	settings = {
		formatterMode = "typstyle",
		exportPdf = "onSave",
		semanticTokens = "enable",
	},
}

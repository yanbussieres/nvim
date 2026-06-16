---@diagnostic disable: undefined-doc-name
local ok, schemastore = pcall(require, "schemastore")
local schemas = ok and schemastore.json.schemas() or {}

---@type vim.lsp.Config
return {
	cmd = { "vscode-json-language-server", "--stdio" },
	filetypes = { "json", "jsonc" },
	root_markers = { ".git" },
	init_options = { provideFormatter = true },
	settings = {
		json = {
			schemas = schemas,
			validate = { enable = true },
		},
	},
}

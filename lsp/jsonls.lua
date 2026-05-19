---@diagnostic disable: undefined-doc-name
---@type vim.lsp.Config
local schemas, validate = {}, true
local ok, schemastore = pcall(require, "schemastore")
if ok then
	schemas = schemastore.json.schemas()
end

return {
	cmd = { "vscode-json-language-server", "--stdio" },
	filetypes = { "json", "jsonc" },
	root_markers = { ".git" },
	init_options = { provideFormatter = true },
	settings = {
		json = {
			schemas = schemas,
			validate = { enable = validate },
		},
	},
}

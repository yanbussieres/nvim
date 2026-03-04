---@diagnostic disable: undefined-doc-name
---@type vim.lsp.Config
return {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = {
		".luarc.json",
		".luarc.jsonc",
		".luacheckrc",
		".stylua.toml",
		"stylua.toml",
		".git",
	},
	settings = {
		Lua = {
			runtime = { version = "Lua 5.4" },
			workspace = {
				library = { vim.env.VIMRUNTIME },
				checkThirdParty = false,
			},
			completion = { callSnippet = "Replace" },
			diagnostics = { globals = { "vim" } },
		},
	},
}

---@diagnostic disable: undefined-doc-name
---@type vim.lsp.Config
return {
	cmd = { "vscode-eslint-language-server", "--stdio" },
	filetypes = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
	},
	root_markers = { ".eslintrc", ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.json", "eslint.config.js", "eslint.config.mjs", "eslint.config.ts", "package.json" },
	before_init = function(params, config)
		local folder = params.workspaceFolders and params.workspaceFolders[1]
		if folder then
			config.settings = config.settings or {}
			config.settings.workspaceFolder = {
				uri = folder.uri,
				name = vim.fn.fnamemodify(vim.uri_to_fname(folder.uri), ":t"),
			}
		end
	end,
	settings = {
		eslint = {
			validate = "on",
			packageManager = nil,
			useESLintClass = false,
			useFlatConfig = nil,
			experimentalUseFlatConfig = false,
			codeAction = {
				disableRuleComment = { enable = true, location = "separateLine" },
				showDocumentation = { enable = true },
			},
			codeActionOnSave = { mode = "all" },
			format = true,
			quiet = false,
			onIgnoredFiles = "off",
			rulesCustomizations = {},
			run = "onType",
			problems = { shortenToSingleLine = false },
			nodePath = "",
			workingDirectory = { mode = "location" },
		},
	},
}

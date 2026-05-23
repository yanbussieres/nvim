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
	-- Priority groups (nvim 0.12): an eslint config wins over package.json so the
	-- server always roots at a dir that actually has a flat/legacy config. In a
	-- monorepo, files under a config-less package.json (repo root, packages/tsconfig)
	-- would otherwise root config-less and throw "path undefined".
	root_markers = {
		{ "eslint.config.js", "eslint.config.mjs", "eslint.config.cjs", "eslint.config.ts" },
		{ ".eslintrc", ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.json" },
		"package.json",
		".git",
	},
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
			useESLintClass = false,
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

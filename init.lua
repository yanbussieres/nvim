-- Neovim 0.12+ config — uses vim.pack instead of lazy.nvim
-- Mirrors nvimREAL plugin set and settings

-- ─────────────────────────────── Leader ─────────────────────────────────
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

-- Disable unused providers
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
vim.g.python3_host_prog = vim.env.HOME .. "/.venv/neovim/bin/python"

-- ─────────────────────────────── Options ────────────────────────────────
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"
vim.o.showmode = false
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)
vim.o.breakindent = true
vim.o.swapfile = false
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = "yes"
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.o.inccommand = "split"
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true

-- ────────────────────────────── Filetypes ───────────────────────────────
vim.filetype.add({ extension = { mdc = "markdown" } })

-- ─────────────────────────────── Keymaps ────────────────────────────────
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("n", "<C-g>", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	vim.notify("Copied: " .. path, vim.log.levels.INFO)
end, { desc = "Copy file path to clipboard" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus left" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus right" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus down" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus up" })

-- ─────────────────────────────── Autocmds ───────────────────────────────
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- ─────────────────────────────── Packages ───────────────────────────────
-- vim.pack manages plugins in $XDG_DATA_HOME/nvim/site/pack/core/opt
-- Update: :lua vim.pack.update()   Remove: :lua vim.pack.del({'name'})
vim.pack.add({
	-- Colorscheme
	{ src = "https://github.com/scottmckendry/cyberdream.nvim" },

	-- Core editing
	{ src = "https://github.com/NMAC427/guess-indent.nvim" },
	{ src = "https://github.com/echasnovski/mini.nvim" },

	-- Git
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },

	-- Keybinding hints
	{ src = "https://github.com/folke/which-key.nvim" },

	-- Fuzzy finder
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	{ src = "https://github.com/dmtrKovalenko/fff.nvim" },

	-- LSP
	{ src = "https://github.com/j-hui/fidget.nvim" },

	-- Completion
	{ src = "https://github.com/saghen/blink.cmp", version = "v1.9.1" },
	{ src = "https://github.com/L3MON4D3/LuaSnip", version = "v2.4.1" },
	{ src = "https://github.com/rafamadriz/friendly-snippets" },
	{ src = "https://github.com/zbirenbaum/copilot.lua" },
	{ src = "https://github.com/giuxtaposition/blink-cmp-copilot" },

	-- Formatting
	{ src = "https://github.com/stevearc/conform.nvim" },

	-- Treesitter
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },

	-- File tree
	{ src = "https://github.com/MunifTanjim/nui.nvim" },
	{ src = "https://github.com/nvim-neo-tree/neo-tree.nvim" },

	-- Tmux navigation
	{ src = "https://github.com/christoomey/vim-tmux-navigator" },
}, { load = true })

-- ─────────────────────────── Plugin Setup ───────────────────────────────

-- Colorscheme
vim.cmd.colorscheme("cyberdream-light")

-- Guess indent
require("guess-indent").setup({})

-- Mini statusline
local statusline = require("mini.statusline")
statusline.setup({ use_icons = vim.g.have_nerd_font })
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function()
	return "%2l:%-2v"
end

-- Gitsigns
require("gitsigns").setup({
	signs = {
		add = { text = "+" },
		change = { text = "~" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
	},
	on_attach = function(bufnr)
		local gs = require("gitsigns")
		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end
		map("n", "]c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "]c", bang = true })
			else
				gs.nav_hunk("next")
			end
		end, { desc = "Jump to next git [c]hange" })
		map("n", "[c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "[c", bang = true })
			else
				gs.nav_hunk("prev")
			end
		end, { desc = "Jump to previous git [c]hange" })
		map("v", "<leader>hs", function()
			gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "git [s]tage hunk" })
		map("v", "<leader>hr", function()
			gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "git [r]eset hunk" })
		map("n", "<leader>hs", gs.stage_hunk, { desc = "git [s]tage hunk" })
		map("n", "<leader>hr", gs.reset_hunk, { desc = "git [r]eset hunk" })
		map("n", "<leader>hS", gs.stage_buffer, { desc = "git [S]tage buffer" })
		map("n", "<leader>hR", gs.reset_buffer, { desc = "git [R]eset buffer" })
		map("n", "<leader>hp", gs.preview_hunk, { desc = "git [p]review hunk" })
		map("n", "<leader>hb", gs.blame_line, { desc = "git [b]lame line" })
		map("n", "<leader>hd", gs.diffthis, { desc = "git [d]iff against index" })
		map("n", "<leader>hD", function()
			gs.diffthis("@")
		end, { desc = "git [D]iff against last commit" })
		map("n", "<leader>ub", gs.toggle_current_line_blame, { desc = "[U]I Toggle git [b]lame" })
		map("n", "<leader>uD", gs.preview_hunk_inline, { desc = "[U]I Toggle git show [D]eleted" })
	end,
})

-- Which-key
require("which-key").setup({
	delay = 300,
	icons = { mappings = vim.g.have_nerd_font, keys = vim.g.have_nerd_font and {} or {} },
	preset = "modern",
	spec = {
		{ "<leader>s", group = "[S]earch" },
		{ "<leader>g", group = "[G]it" },
		{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
		{ "<leader>f", group = "[F]ile/Format/Fix" },
		{ "<leader>u", group = "[U]I Toggle" },
	},
})

-- Telescope
require("telescope").setup({})
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
vim.keymap.set("n", "<leader>gg", builtin.git_status, { desc = "[G]it [S]tatus" })
vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = "[S]earch Recent Files" })
vim.keymap.set("n", "<leader>/", function()
	builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({ winblend = 10, previewer = false }))
end, { desc = "[/] Fuzzily search in current buffer" })
vim.keymap.set("n", "<leader>s/", function()
	builtin.live_grep({ grep_open_files = true, prompt_title = "Live Grep in Open Files" })
end, { desc = "[S]earch [/] in Open Files" })
vim.keymap.set("n", "<leader>sn", function()
	builtin.find_files({ cwd = vim.fn.stdpath("config") })
end, { desc = "[S]earch [N]eovim files" })
vim.keymap.set("n", "<leader>sf", function()
	builtin.find_files({ hidden = true, no_ignore = true, prompt_title = "Find Files" })
end, { desc = "[S]earch [F]iles (hidden)" })

-- fff.nvim
require("fff").setup({})
vim.keymap.set("n", "<leader><leader>", function()
	local git_root = vim.fs.root(0, ".git")
	if git_root then
		require("fff").find_files_in_dir(git_root)
	else
		require("fff").find_files()
	end
end, { desc = "Find files (fff, git-root or cwd)" })

-- Fidget
require("fidget").setup({})

-- Copilot (suggestions disabled — used via blink-cmp-copilot)
require("copilot").setup({
	suggestion = { enabled = false },
	panel = { enabled = false },
	filetypes = { yaml = false, markdown = false, help = false, gitcommit = false, ["."] = false },
})

-- LSP attach keymaps & highlights
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
	callback = function(event)
		local map = function(keys, func, desc, mode)
			vim.keymap.set(mode or "n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end
		-- gr* keymaps are nvim 0.12 built-in defaults; extras below are not covered natively
		map("gO", require("telescope.builtin").lsp_document_symbols, "Document Symbols")
		map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Workspace Symbols")
		map("grt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype Definition")

		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client then
			if client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
				local hl = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
				vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
					buffer = event.buf,
					group = hl,
					callback = vim.lsp.buf.document_highlight,
				})
				vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
					buffer = event.buf,
					group = hl,
					callback = vim.lsp.buf.clear_references,
				})
				vim.api.nvim_create_autocmd("LspDetach", {
					group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
					callback = function(ev)
						vim.lsp.buf.clear_references()
						vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = ev.buf })
					end,
				})
			end
			if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
				map("<leader>uh", function()
					vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
				end, "[U]I Toggle Inlay [H]ints")
			end
		end
	end,
})

vim.diagnostic.config({
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
	underline = { severity = vim.diagnostic.severity.ERROR },
	signs = vim.g.have_nerd_font and {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅚 ",
			[vim.diagnostic.severity.WARN] = "󰀪 ",
			[vim.diagnostic.severity.INFO] = "󰋽 ",
			[vim.diagnostic.severity.HINT] = "󰌶 ",
		},
	} or {},
	virtual_text = { source = "if_many", spacing = 2 },
})

-- Global: merge blink capabilities into every server
vim.lsp.config("*", {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
})

-- LSP servers (all installed manually via brew/npm — no mason)
-- ts_ls: npm install -g typescript typescript-language-server
-- lua_ls: brew install lua-language-server
-- eslint_ls: npm install -g vscode-langservers-extracted
-- tailwindcss: npm install -g @tailwindcss/language-server
vim.lsp.enable({ "ts_ls", "lua_ls", "eslint_ls", "tailwindcss" })

-- Conform (format on save)
require("conform").setup({
	notify_on_error = true,
	format_on_save = function(bufnr)
		local ft = vim.bo[bufnr].filetype
		if ft == "c" or ft == "cpp" then
			return nil
		end
		return { timeout_ms = 500, lsp_format = "fallback" }
	end,
	formatters_by_ft = {
		lua = { "stylua" },
		javascript = { "prettierd" },
		typescript = { "prettierd" },
		javascriptreact = { "prettierd" },
		typescriptreact = { "prettierd", "prettier", stop_after_first = true },
		css = { "prettierd" },
		html = { "prettierd" },
		json = { "prettierd" },
		yaml = { "prettierd" },
		markdown = { "prettierd" },
	},
})
vim.keymap.set({ "n", "v" }, "<leader>f", function()
	require("conform").format({ async = true, lsp_format = "never" })
end, { desc = "[F]ormat buffer" })
vim.keymap.set("n", "<leader>fe", "<cmd>EslintFixAll<CR>", { desc = "[F]ix [E]SLint" })

-- LuaSnip
require("luasnip").setup({
	history = true,
	delete_check_events = "TextChanged",
})
require("luasnip.loaders.from_vscode").lazy_load()
-- Jump forward/backward through snippet nodes (<Tab>/<S-Tab> are owned by blink.cmp)
vim.keymap.set({ "i", "s" }, "<C-l>", function()
	if require("luasnip").jumpable(1) then
		require("luasnip").jump(1)
	end
end, { desc = "LuaSnip jump forward" })
vim.keymap.set({ "i", "s" }, "<C-h>", function()
	if require("luasnip").jumpable(-1) then
		require("luasnip").jump(-1)
	end
end, { desc = "LuaSnip jump backward" })

-- Blink.cmp
require("blink.cmp").setup({
	keymap = { preset = "default" },
	appearance = { nerd_font_variant = "mono" },
	completion = { documentation = { auto_show = false, auto_show_delay_ms = 500 } },
	snippets = { preset = "luasnip" },
	sources = {
		default = { "lsp", "path", "snippets", "copilot" },
		providers = {
			copilot = { name = "copilot", module = "blink-cmp-copilot", score_offset = 25, async = true },
		},
	},
	fuzzy = { implementation = "prefer_rust_with_warning" },
	signature = { enabled = true },
})

-- Treesitter
require("nvim-treesitter").install({
	"bash",
	"diff",
	"html",
	"javascript",
	"jsdoc",
	"json",
	"tsx",
	"typescript",
	"lua",
	"luadoc",
	"markdown",
	"markdown_inline",
	"query",
	"toml",
	"vim",
	"vimdoc",
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function()
		pcall(vim.treesitter.start)
	end,
})

-- Neo-tree
require("neo-tree").setup({
	filesystem = {
		window = {
			mappings = {
				["<leader>e"] = "close_window",
				["P"] = { "toggle_preview", config = { use_float = false, title = "Neo-tree Preview" } },
			},
		},
	},
})
vim.keymap.set("n", "<leader>e", ":Neotree reveal<CR>", { desc = "NeoTree reveal", silent = false })

-- vim: ts=2 sts=2 sw=2 et

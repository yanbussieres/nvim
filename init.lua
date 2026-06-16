-- Neovim 0.12+ config — uses vim.pack instead of lazy.nvim

-- ─────────────────────────────── Leader ─────────────────────────────────
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
vim.keymap.set({ "n", "x" }, "<Space>", "<Nop>", { silent = true })

-- Disable unused providers
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0

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
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [L]ocation list" })
vim.keymap.set("n", "<C-g>", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	vim.notify("Copied: " .. path, vim.log.levels.INFO)
end, { desc = "Copy file path to clipboard" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
-- <C-h/j/k/l> window/tmux navigation provided by vim-tmux-navigator

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
	{ src = "https://github.com/projekt0n/github-nvim-theme" },
	-- Core editing
	{ src = "https://github.com/echasnovski/mini.nvim" },

	-- Git
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },

	-- Fuzzy finder
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim" },
	{ src = "https://github.com/dmtrKovalenko/fff" },

	-- LSP
	{ src = "https://github.com/b0o/SchemaStore.nvim" },

	-- Completion
	{ src = "https://github.com/saghen/blink.cmp", version = "v1.10.2" },

	-- Formatting
	{ src = "https://github.com/stevearc/conform.nvim" },

	-- Treesitter
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },

	-- Markdown rendering
	{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },

	-- Tmux navigation
	{ src = "https://github.com/christoomey/vim-tmux-navigator" },

	-- Keymap hints (helix-style popup)
	{ src = "https://github.com/folke/which-key.nvim" },
}, { load = true })

-- nvim-treesitter installs parsers + queries to stdpath("data")/site,
-- which is not automatically in rtp in Neovim 0.12.
vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/site")

-- ─────────────────────────── Plugin Setup ───────────────────────────────

-- Colorscheme — github-nvim-theme, follows macOS light/dark appearance.
-- Variants: github_light, github_light_default, github_light_high_contrast,
--           github_light_colorblind, github_light_tritanopia (+ dark equivalents)
require("github-theme").setup({})

local function macos_is_dark()
	-- `defaults read -g AppleInterfaceStyle` prints "Dark" in dark mode and
	-- exits non-zero (no value) in light mode.
	return vim.trim(vim.fn.system("defaults read -g AppleInterfaceStyle 2>/dev/null")) == "Dark"
end

local function sync_theme()
	local want = macos_is_dark() and "github_dark_high_contrast" or "github_light_high_contrast"
	if vim.g.colors_name ~= want then
		vim.cmd.colorscheme(want)
	end
end

sync_theme()

-- Re-check when nvim regains focus so it follows live macOS theme toggles.
vim.api.nvim_create_autocmd("FocusGained", { callback = sync_theme })

-- Mini statusline
local statusline = require("mini.statusline")
statusline.setup({})
statusline.section_location = function()
	return "%2l:%-2v"
end
statusline.section_git = function()
	local branch = vim.b.gitsigns_head
	if not branch or branch == "" then
		return ""
	end
	local d = vim.b.gitsigns_status_dict
	local dirty = d and ((d.added or 0) + (d.changed or 0) + (d.removed or 0) > 0)
	return " " .. branch .. (dirty and "  ●" or "")
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

-- Lazygit + gh CLI (no plugin — runs in a new tab terminal)
local function open_in_term(cmd)
	vim.cmd.tabnew()
	vim.fn.jobstart(cmd, {
		term = true,
		on_exit = function()
			vim.schedule(function()
				if vim.api.nvim_buf_is_valid(0) then
					vim.cmd("silent! bdelete!")
				end
			end)
		end,
	})
	vim.cmd.startinsert()
end
vim.keymap.set("n", "<leader>gg", function()
	open_in_term("lazygit")
end, { desc = "Lazygit" })
vim.keymap.set("n", "<leader>gp", "<cmd>!gh pr view --web<CR>", { desc = "GitHub: open PR in browser" })
vim.keymap.set("n", "<leader>gl", function()
	open_in_term("gh pr list")
end, { desc = "GitHub: list PRs" })

-- Build native binaries for plugins that ship source (run on install/update).
-- telescope-fzf-native: compiled fzf sorter. fff: Rust file-picker binary.
vim.api.nvim_create_autocmd("PackChanged", {
	group = vim.api.nvim_create_augroup("pack-build", { clear = true }),
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if kind ~= "install" and kind ~= "update" then
			return
		end
		if name == "telescope-fzf-native.nvim" then
			local result = vim.system({ "make" }, { cwd = ev.data.path }):wait()
			if result.code ~= 0 then
				vim.notify("telescope-fzf-native build failed:\n" .. (result.stderr or ""), vim.log.levels.ERROR)
			end
		elseif name == "fff" then
			if not ev.data.active then
				vim.cmd.packadd("fff")
			end
			require("fff.download").download_or_build_binary()
		end
	end,
})

-- Telescope — ancillary pickers (helptags/keymaps/buffers/blines/oldfiles/hidden files).
-- File find + live grep stay on fff.nvim below (faster Rust-backed indexer).
require("telescope").setup({
	defaults = {
		path_display = { "truncate" },
		sorting_strategy = "ascending",
		layout_config = { prompt_position = "top" },
		mappings = {
			i = {
				["<C-h>"] = "which_key",
				["<C-u>"] = false, -- let <C-u> clear the prompt instead of scrolling preview
			},
		},
	},
	pickers = {
		buffers = {
			sort_mru = true,
			ignore_current_buffer = true,
			mappings = { i = { ["<C-d>"] = "delete_buffer" } },
		},
	},
	extensions = {
		fzf = {}, -- defaults: fuzzy=true, override_generic_sorter=true, override_file_sorter=true
	},
})
pcall(require("telescope").load_extension, "fzf")

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[H]elp" })
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[K]eymaps" })
vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = "[.] Recent files" })
vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "[/] Buffer fuzzy" })
vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "[B]uffers" })
vim.keymap.set("n", "<leader>sf", function()
	builtin.find_files({ hidden = true, no_ignore = true, prompt_title = "All files" })
end, { desc = "HIDDEN-[F]iles" })
vim.keymap.set("n", "<leader>s$", function()
	builtin.find_files({
		hidden = true,
		no_ignore = true,
		find_command = { "rg", "--files", "--hidden", "--no-ignore", "--iglob", ".env*", "--glob", "!.git" },
		prompt_title = ".env* files",
	})
end, { desc = ".env* files" })
vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[R]esume picker" })
vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[D]iagnostics" })

-- fff.nvim — file picker + live grep (Rust-backed; binary built via PackChanged above)
vim.g.fff = { lazy_sync = true }
vim.keymap.set("n", "<leader><leader>", function()
	require("fff").find_files()
end, { desc = "Find files (fff)" })
vim.keymap.set("n", "<leader>sg", function()
	require("fff").live_grep()
end, { desc = "[G]rep (fff)" })
vim.keymap.set("n", "<leader>sw", function()
	require("fff").live_grep({ query = vim.fn.expand("<cword>") })
end, { desc = "[W]ord (fff grep)" })
vim.keymap.set("n", "<leader>sn", function()
	require("fff").find_files_in_dir(vim.fn.stdpath("config"))
end, { desc = "[N]eovimConf" })

-- LSP attach keymaps & highlights
-- Document-highlight augroup is created once here so LspDetach (also registered
-- once below) can always clear it, even if no highlight-capable client attached.
local lsp_highlight = vim.api.nvim_create_augroup("lsp-highlight", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
	callback = function(event)
		local map = function(keys, func, desc, mode)
			vim.keymap.set(mode or "n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end
		-- gW = workspace symbols; gO (document symbols) and grt (type def) are built-in in 0.12
		map("gW", function()
			vim.lsp.buf.workspace_symbol("")
		end, "Workspace Symbols")
		-- grd/grD are NOT built-in defaults in 0.12 (only grn/gra/grr/gri/grt/gO are)
		map("grd", vim.lsp.buf.definition, "Goto Definition")
		map("grD", vim.lsp.buf.declaration, "Goto Declaration")

		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if not client then
			return
		end
		if client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = event.buf,
				group = lsp_highlight,
				callback = vim.lsp.buf.document_highlight,
			})
			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = event.buf,
				group = lsp_highlight,
				callback = vim.lsp.buf.clear_references,
			})
		end
		if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
			map("<leader>uh", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
			end, "[U]I Toggle Inlay [H]ints")
		end
	end,
})

vim.api.nvim_create_autocmd("LspDetach", {
	group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
	callback = function(event)
		vim.lsp.buf.clear_references()
		vim.api.nvim_clear_autocmds({ group = lsp_highlight, buffer = event.buf })
	end,
})

vim.diagnostic.config({
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
	underline = { severity = vim.diagnostic.severity.ERROR },
	virtual_text = { source = "if_many", spacing = 2 },
})

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
		javascript = { "prettier" },
		typescript = { "prettier" },
		javascriptreact = { "prettier" },
		typescriptreact = { "prettier" },
		css = { "prettier" },
		html = { "prettier" },
		json = { "prettier" },
		yaml = { "prettier" },
		markdown = { "prettier" },
		toml = { "taplo" },
	},
})
vim.keymap.set({ "n", "v" }, "<leader>ff", function()
	require("conform").format({ async = true, lsp_format = "never" })
end, { desc = "[F]ormat buffer" })

-- Blink.cmp
require("blink.cmp").setup({
	keymap = { preset = "default" },
	appearance = { nerd_font_variant = "mono" },
	completion = { documentation = { auto_show = false, auto_show_delay_ms = 500 } },
	sources = {
		default = { "lsp", "path" },
	},
	fuzzy = { implementation = "prefer_rust" },
	signature = { enabled = true },
})

-- Global: merge blink capabilities into every server
vim.lsp.config("*", {
	capabilities = vim.tbl_deep_extend("force", require("blink.cmp").get_lsp_capabilities(), {
		general = { positionEncodings = { "utf-16" } },
	}),
})

-- LSP servers (all installed manually via brew/npm — no mason)
-- vtsls:       npm install -g @vtsls/language-server
-- lua_ls:      brew install lua-language-server
-- tailwindcss: npm install -g @tailwindcss/language-server
-- taplo:       brew install taplo
-- marksman:    brew install marksman
-- jsonls:      npm install -g vscode-langservers-extracted
vim.lsp.enable({ "vtsls", "lua_ls", "tailwindcss", "taplo", "marksman", "jsonls" })

-- Treesitter — only call install() when a parser is actually missing.
-- install() unconditionally reloads the parsers module on every call.
local ts_parsers = {
	"bash",
	"css",
	"diff",
	"dockerfile",
	"gitattributes",
	"gitcommit",
	"gitignore",
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
	"printf",
	"query",
	"regex",
	"toml",
	"vim",
	"vimdoc",
	"yaml",
}
do
	local nvim_ts = require("nvim-treesitter")
	local installed = {}
	for _, p in ipairs(nvim_ts.get_installed("parsers")) do
		installed[p] = true
	end
	local missing = {}
	for _, p in ipairs(ts_parsers) do
		if not installed[p] then
			missing[#missing + 1] = p
		end
	end
	if #missing > 0 then
		nvim_ts.install(missing)
	end
end
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
	pattern = "*",
	callback = function()
		pcall(vim.treesitter.start)
	end,
})

-- Render-markdown
require("render-markdown").setup({
	preset = "obsidian",
	latex = { enabled = false },
	yaml = { enabled = false },
	code = { width = "block", border = "thick" },
	checkbox = {
		custom = {
			doing = { raw = "[~]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
			important = { raw = "[!]", rendered = " ", highlight = "DiagnosticWarn" },
		},
	},
	overrides = {
		buftype = {
			nofile = {
				padding = { highlight = "NormalFloat" },
				sign = { enabled = false },
			},
		},
	},
})

-- mini.files — file explorer (column-based, edit FS as a buffer)
require("mini.files").setup({})
vim.keymap.set("n", "<leader>e", function()
	local mf = require("mini.files")
	if not mf.close() then
		mf.open(vim.api.nvim_buf_get_name(0), true)
	end
end, { desc = "Toggle mini.files (reveal current file)" })

-- which-key (helix-style popup)
require("which-key").setup({
	preset = "helix",
	spec = {
		{ "<leader>g", group = "git / github" },
		{ "<leader>h", group = "git hunks" },
		{ "<leader>s", group = "search" },
		{ "<leader>u", group = "UI toggles" },
		{ "<leader>f", group = "format" },
	},
})

-- vim: ts=2 sts=2 sw=2 et

-- Neovim 0.12+ config — uses vim.pack instead of lazy.nvim

-- ─────────────────────────────── Leader ─────────────────────────────────
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

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
  { src = "https://github.com/junegunn/fzf.vim" },

  -- LSP
  { src = "https://github.com/b0o/SchemaStore.nvim" },

  -- Completion
  { src = "https://github.com/saghen/blink.cmp",                         version = "v1.9.1" },

  -- Formatting
  { src = "https://github.com/stevearc/conform.nvim" },

  -- Treesitter
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },

  -- Markdown rendering
  { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },

  -- File tree
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/MunifTanjim/nui.nvim" },
  { src = "https://github.com/nvim-neo-tree/neo-tree.nvim" },

  -- Tmux navigation
  { src = "https://github.com/christoomey/vim-tmux-navigator" },
}, { load = true })

-- nvim-treesitter installs parsers + queries to stdpath("data")/site,
-- which is not automatically in rtp in Neovim 0.12.
vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/site")

-- ─────────────────────────── Plugin Setup ───────────────────────────────

-- Colorscheme — github-nvim-theme (matches Ghostty "GitHub Light Default")
-- Variants: github_light, github_light_default, github_light_high_contrast,
--           github_light_colorblind, github_light_tritanopia (+ dark equivalents)
vim.o.background = "light"
require("github-theme").setup({})
vim.cmd.colorscheme("github_light_default")

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

-- fzf.vim — uses brew-installed fzf binary + runtime
vim.opt.rtp:prepend("/opt/homebrew/opt/fzf")
vim.g.fzf_layout = { down = "40%" }
vim.keymap.set("n", "<leader><leader>", function()
  if vim.fs.root(0, ".git") then
    vim.cmd("GFiles")
  else
    vim.cmd("Files")
  end
end, { desc = "Find files (git-root or cwd)" })
vim.keymap.set("n", "<leader>g", ":Rg<CR>", { desc = "Live grep (Rg)" })
vim.keymap.set("n", "<leader>sh", ":Helptags<CR>", { desc = "[H]elp" })
vim.keymap.set("n", "<leader>sk", ":Maps<CR>", { desc = "[K]eymaps" })
vim.keymap.set("n", "<leader>sw", ':execute "Rg " . expand("<cword>")<CR>', { desc = "[W]ord" })
vim.keymap.set("n", "<leader>s.", ":History<CR>", { desc = "[.]recent Files" })
vim.keymap.set("n", "<leader>/", ":BLines<CR>", { desc = "[/] Fuzzily search in current buffer" })
vim.keymap.set("n", "<leader>sb", ":Buffers<CR>", { desc = "[B]uffers" })
vim.keymap.set("n", "<leader>sn", function()
  vim.cmd("Files " .. vim.fn.stdpath("config"))
end, { desc = "[N]eovimConf" })
vim.keymap.set("n", "<leader>sf", function()
  vim.cmd("call fzf#vim#files('', {'source': 'rg --files --hidden --no-ignore --glob=!.git'})")
end, { desc = "HIDDEN-[F]iles" })

-- LSP attach keymaps & highlights
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
vim.keymap.set("n", "<leader>fe", function()
  local bufnr = vim.api.nvim_get_current_buf()
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = "eslint_ls" })) do
    client:exec_cmd(
      { command = "eslint.applyAllFixes", arguments = { { uri = vim.uri_from_bufnr(bufnr) } } },
      { bufnr = bufnr }
    )
  end
end, { desc = "[F]ix [E]SLint" })

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
  capabilities = require("blink.cmp").get_lsp_capabilities(),
})

-- LSP servers (all installed manually via brew/npm — no mason)
-- ts_ls:       npm install -g typescript typescript-language-server
-- lua_ls:      brew install lua-language-server
-- eslint_ls:   npm install -g vscode-langservers-extracted
-- tailwindcss: npm install -g @tailwindcss/language-server
-- taplo:       brew install taplo
-- marksman:    brew install marksman
-- jsonls:      npm install -g vscode-langservers-extracted (already required by eslint_ls)
vim.lsp.enable({ "ts_ls", "lua_ls", "eslint_ls", "tailwindcss", "taplo", "marksman", "jsonls" })

-- Treesitter — only call install() when a parser is actually missing.
-- install() unconditionally reloads the parsers module on every call.
local ts_parsers = {
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
  pattern = "*",
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

-- Render-markdown
require("render-markdown").setup({ latex = { enabled = false }, yaml = { enabled = false } })

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
vim.keymap.set("n", "<leader>e", ":Neotree reveal<CR>", { desc = "NeoTree reveal", silent = true })

-- vim: ts=2 sts=2 sw=2 et

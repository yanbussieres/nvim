# Neovim Config — CLAUDE.md

Neovim 0.12+ configuration using the built-in `vim.pack` plugin manager.
N3. hheovim 1.12+ configuratio using the built-in `vim.pack` plugin manager.o lazy.nvim or other external plugin manager. No Mason — LSP servers installed manually.

## Structure

```
~/.config/nvim/
├── init.lua              # Single-file config (all plugins, options, keymaps)
├── lsp/
│   ├── lua_ls.lua        # lua-language-server config
│   ├── vtsls.lua         # vtsls (TS/JS language server, @vtsls/language-server)
│   ├── tailwindcss.lua   # tailwindcss-language-server config
│   ├── taplo.lua         # taplo (TOML) LSP config
│   ├── jsonls.lua        # vscode-json-language-server config (uses SchemaStore)
│   └── marksman.lua      # marksman (markdown) LSP config
├── ftplugin/
│   └── markdown.lua      # <CR> follows markdown links; <leader>x toggles checkbox
└── nvim-pack-lock.json   # Lockfile — managed by vim.pack automatically
```

## Plugin Manager: vim.pack

`vim.pack` is the **built-in** plugin manager added in Neovim 0.12.

- Plugins declared in `vim.pack.add({...}, { load = true })` in `init.lua`
- Plugins stored in `$XDG_DATA_HOME/nvim/site/pack/core/opt/`
- Lockfile: `nvim-pack-lock.json` — committed to git
- Update all: `:lua vim.pack.update()`
- Remove plugin: `:lua vim.pack.del({'plugin-name'})`
- Pinned versions use `version = "vX.Y.Z"` (blink.cmp v1.10.2)

## LSP Setup (0.12 native style)

- Server configs live in `lsp/<server_name>.lua` — canonical location, auto-loaded by Neovim 0.12
- Global capabilities set via `vim.lsp.config("*", {...})` in `init.lua` (blink.cmp caps)
- Servers enabled via `vim.lsp.enable({ "vtsls", "lua_ls", "tailwindcss", "taplo", "marksman", "jsonls" })`
- **No Mason** — install servers manually:
  - `vtsls`: `npm install -g @vtsls/language-server`
  - `lua_ls`: `brew install lua-language-server`
  - `tailwindcss`: `npm install -g @tailwindcss/language-server`
  - `taplo`: `brew install taplo`
  - `marksman`: `brew install marksman`

## Plugin Inventory

| Plugin               | Purpose                                                   |
| -------------------- | --------------------------------------------------------- |
| github-nvim-theme    | Colorscheme (`github_light_default` — matches Ghostty)    |
| mini.nvim            | Statusline (mini.statusline) + file explorer (mini.files) |
| gitsigns.nvim        | Git hunk signs + keymaps                                  |
| nvim-web-devicons    | Icons (requires nerd font)                                |
| plenary.nvim         | Telescope dependency (async/utils)                        |
| telescope.nvim       | Helptags/Keymaps/Buffers/BLines/Oldfiles/Hidden pickers   |
| telescope-fzf-native | Compiled fzf sorter (built via `make` on install/update)  |
| fff.nvim             | File picker + live grep (Rust binary, built on install)   |
| SchemaStore.nvim     | JSON schemas for jsonls                                   |
| blink.cmp (v1.9.1)   | Completion engine (rust fuzzy impl)                       |
| conform.nvim         | Format on save                                            |
| nvim-treesitter      | Syntax/highlighting (FileType autocmd enables per-buffer) |
| render-markdown.nvim | Markdown rendering in buffer (latex/yaml disabled)        |
| vim-tmux-navigator   | C-h/j/k/l tmux pane navigation                            |

## Key Keymaps

| Key                           | Action                                                    |
| ----------------------------- | --------------------------------------------------------- |
| `<leader>`                    | Space                                                     |
| `<leader>e`                   | Toggle mini.files (reveals current file)                  |
| `<leader>ff`                  | Format buffer (conform, async)                            |
| `<leader>sg`                  | Live grep (fff.nvim)                                      |
| `<leader>sw`                  | Live grep current word (fff.nvim)                         |
| `<leader>sn`                  | Find files in nvim config dir (fff.nvim)                  |
| `<leader>sh/sk/s./sb/sf`      | Telescope help/keymaps/oldfiles/buffers/hidden            |
| `<leader>gg/gl/gp`            | Lazygit / `gh pr list` / `gh pr view --web`               |
| `<leader>sr/sd`               | Telescope resume / diagnostics                            |
| `<leader>/`                   | Telescope `current_buffer_fuzzy_find`                     |
| `<leader><leader>`            | Find files (fff.nvim)                                     |
| `<leader>h*`                  | Gitsigns hunk operations                                  |
| `<leader>x` (md buf)          | Toggle markdown checkbox `[ ]` ↔ `[x]`                    |
| `<leader>u*`                  | UI toggles (blame, inlay hints, deleted)                  |
| `<leader>q`                   | Open diagnostic location list                             |
| `<C-g>`                       | Copy current file path to clipboard                       |
| `grn/gra/grr/gri/grt`         | LSP rename/action/refs/impl/type (native 0.12 defaults)   |
| `grd/grD`                     | LSP definition/declaration (config-defined, not native)   |
| `<C-]>`                       | Go to definition (native, via `tagfunc`)                  |
| `gO / gW`                     | Document (native) / workspace symbols (config-defined)     |
| `<leader>uh`                  | Toggle LSP inlay hints                                    |

## Formatting (conform.nvim)

- Format on save for all filetypes except `c`/`cpp`
- Formatters: `stylua` (lua), `prettier` (js/ts/css/html/json/yaml/md), `taplo` (toml)
- Manual format: `<leader>ff`

## Completion (blink.cmp)

- Sources: lsp, path
- Signature help enabled
- Documentation auto_show = false
- `<Tab>`/`<S-Tab>` belong to blink.cmp for completion selection

## Filetype Notes

- `.mdc` files mapped to `markdown` filetype
- `ftplugin/markdown.lua`:
  - `<CR>` follows markdown links via LSP go-to-definition (dedups by filename
    before opening quickfix); falls back to a literal `<CR>` when no LSP client
    on the buffer supports `textDocument/definition` (uses `expr = true`)
  - `<leader>x` toggles the checkbox on the current list line (`[ ]` ↔ `[x]`)

## Editing This Config

- All plugin config is in `init.lua` — single file, no splits
- To add a plugin: add `{ src = "https://github.com/..." }` to `vim.pack.add()`
- To add an LSP server: create `lsp/<server>.lua` with `---@type vim.lsp.Config`, then add to `vim.lsp.enable()`
- `nvim-pack-lock.json` is auto-updated on install/update — commit it
- Treesitter parsers installed via `require("nvim-treesitter").install({...})`
- Treesitter stdpath prepend needed: `vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/site")`

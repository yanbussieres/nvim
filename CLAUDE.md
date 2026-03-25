# Neovim Config — CLAUDE.md

Neovim 0.12+ configuration using the built-in `vim.pack` plugin manager.
No lazy.nvim or other external plugin manager. No Mason — LSP servers installed manually.

## Structure

```
~/.config/nvim/
├── init.lua              # Single-file config (all plugins, options, keymaps)
├── lsp/
│   ├── lua_ls.lua        # lua-language-server config
│   ├── ts_ls.lua         # typescript-language-server config
│   ├── eslint_ls.lua     # vscode-eslint-language-server config
│   ├── tailwindcss.lua   # tailwindcss-language-server config
│   └── taplo.lua         # taplo (TOML) LSP config
├── ftplugin/
│   └── markdown.lua      # <CR> to follow markdown links via LSP go-to-def
└── nvim-pack-lock.json   # Lockfile — managed by vim.pack automatically
```

## Plugin Manager: vim.pack

`vim.pack` is the **built-in** plugin manager added in Neovim 0.12.

- Plugins declared in `vim.pack.add({...}, { load = true })` in `init.lua`
- Plugins stored in `$XDG_DATA_HOME/nvim/site/pack/core/opt/`
- Lockfile: `nvim-pack-lock.json` — committed to git
- Update all: `:lua vim.pack.update()`
- Remove plugin: `:lua vim.pack.del({'plugin-name'})`
- Pinned versions use `version = "vX.Y.Z"` (blink.cmp v1.9.1, LuaSnip v2.4.1)

## LSP Setup (0.12 native style)

- Server configs live in `lsp/<server_name>.lua` — canonical location, auto-loaded by Neovim 0.12
- Global capabilities set via `vim.lsp.config("*", {...})` in `init.lua` (blink.cmp caps)
- Servers enabled via `vim.lsp.enable({ "ts_ls", "lua_ls", "eslint_ls", "tailwindcss", "taplo" })`
- **No Mason** — install servers manually:
  - `ts_ls`: `npm install -g typescript typescript-language-server`
  - `lua_ls`: `brew install lua-language-server`
  - `eslint_ls`: `npm install -g vscode-langservers-extracted`
  - `tailwindcss`: `npm install -g @tailwindcss/language-server`
  - `taplo`: `brew install taplo`

## Plugin Inventory

| Plugin                  | Purpose                                                  |
| ----------------------- | -------------------------------------------------------- |
| cyberdream.nvim         | Colorscheme (light variant active)                       |
| guess-indent.nvim       | Auto-detect indentation                                  |
| mini.nvim               | Statusline (mini.statusline)                             |
| gitsigns.nvim           | Git hunk signs + keymaps                                 |
| neogit                  | Full git UI (`<leader>gg`)                               |
| which-key.nvim          | Keymap hints (delay 300ms, modern preset)                |
| plenary.nvim            | Telescope dependency                                     |
| nvim-web-devicons       | Icons (requires nerd font)                               |
| telescope.nvim          | Fuzzy finder                                             |
| fff.nvim                | Fast file finder (git-root aware)                        |
| fidget.nvim             | LSP progress spinner                                     |
| blink.cmp (v1.9.1)      | Completion engine (rust fuzzy impl)                      |
| LuaSnip (v2.4.1)        | Snippet engine                                           |
| friendly-snippets       | Community snippet collection (VSCode format)             |
| copilot.lua             | Copilot backend (suggestions/panel disabled)             |
| blink-cmp-copilot       | Copilot source for blink.cmp                             |
| conform.nvim            | Format on save                                           |
| nvim-treesitter         | Syntax/highlighting (FileType autocmd enables per-buffer)|
| render-markdown.nvim    | Markdown rendering in buffer (latex/yaml disabled)       |
| vim-table-mode          | Markdown table editing                                   |
| nui.nvim                | Neo-tree dependency                                      |
| neo-tree.nvim           | File explorer                                            |
| vim-tmux-navigator      | C-h/j/k/l tmux pane navigation                           |

## Key Keymaps

| Key                     | Action                                          |
| ----------------------- | ----------------------------------------------- |
| `<leader>`              | Space                                           |
| `<leader>e`             | Toggle Neo-tree (reveal current file)           |
| `<leader>ff`            | Format buffer (conform, async)                  |
| `<leader>fe`            | Fix ESLint (apply all fixes via eslint_ls)      |
| `<leader>k`             | Live grep (fff)                                 |
| `<leader>s*`            | Telescope searches                              |
| `<leader><leader>`      | Find files (fff: git-root or cwd)               |
| `<leader>gg`            | Open Neogit                                     |
| `<leader>h*`            | Gitsigns hunk operations                        |
| `<leader>u*`            | UI toggles (blame, inlay hints, deleted)        |
| `<leader>q`             | Open diagnostic location list                   |
| `<C-g>`                 | Copy current file path to clipboard             |
| `grn/gra/grr/gri/grd/grD/grt` | LSP rename/action/refs/impl/def/decl/type |
| `gO / gW`               | Document / workspace symbols (Telescope)        |
| `<leader>uh`            | Toggle LSP inlay hints                          |

## Formatting (conform.nvim)

- Format on save for all filetypes except `c`/`cpp`
- Formatters: `stylua` (lua), `prettier` (js/ts/css/html/json/yaml/md), `taplo` (toml)
- Manual format: `<leader>ff`
- ESLint fix (all rules): `<leader>fe`

## Completion (blink.cmp + LuaSnip)

- Snippet engine: LuaSnip (`snippets = { preset = "luasnip" }`)
- Sources: lsp, path, snippets, copilot
- Copilot score_offset = 25 (boosted)
- Signature help enabled
- Documentation auto_show = false
- LuaSnip jump keymaps: `<C-l>` forward, `<C-h>` backward (insert/select mode)
  (`<Tab>`/`<S-Tab>` belong to blink.cmp for completion selection)

## Filetype Notes

- `.mdc` files mapped to `markdown` filetype
- `ftplugin/markdown.lua`: `<CR>` follows markdown links via LSP go-to-definition
  (deduplicates results by filename before opening quickfix)

## Editing This Config

- All plugin config is in `init.lua` — single file, no splits
- To add a plugin: add `{ src = "https://github.com/..." }` to `vim.pack.add()`
- To add an LSP server: create `lsp/<server>.lua` with `---@type vim.lsp.Config`, then add to `vim.lsp.enable()`
- `nvim-pack-lock.json` is auto-updated on install/update — commit it
- Treesitter parsers installed via `require("nvim-treesitter").install({...})`
- Treesitter stdpath prepend needed: `vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/site")`

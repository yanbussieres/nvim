# Neovim Config — CLAUDE.md

Neovim 0.12+ configuration using the built-in `vim.pack` plugin manager.
No lazy.nvim or other external plugin manager.

## Structure

```
~/.config/nvim/
├── init.lua              # Single-file config (all plugins, options, keymaps)
├── lsp/
│   ├── lua_ls.lua        # lua-language-server config (vim.lsp.config spec)
│   └── ts_ls.lua         # typescript-language-server config
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
- `nvim-lspconfig` not in `vim.pack.add`; it appears in the lockfile as a transitive dep of mason-lspconfig
- mason-lspconfig v2.1.0: `automatic_enable = true` calls `vim.lsp.enable()` for all Mason-installed servers
  — the old `handlers` API is gone; don't use it

## Plugin Inventory

| Plugin                    | Purpose                                                   |
| ------------------------- | --------------------------------------------------------- |
| cyberdream.nvim           | Colorscheme (light variant active)                        |
| guess-indent.nvim         | Auto-detect indentation                                   |
| mini.nvim                 | Statusline (mini.statusline)                              |
| gitsigns.nvim             | Git hunk signs + keymaps                                  |
| which-key.nvim            | Keymap hints (delay 300ms, modern preset)                 |
| plenary.nvim              | Telescope dependency                                      |
| nvim-web-devicons         | Icons (requires nerd font)                                |
| telescope.nvim            | Fuzzy finder                                              |
| fff.nvim                  | Fast file finder (git-root aware)                         |
| mason.nvim                | LSP/tool installer                                        |
| mason-lspconfig.nvim      | Mason ↔ LSP bridge                                        |
| mason-tool-installer.nvim | Ensures ts_ls, lua_ls, stylua, prettierd, prettier        |
| fidget.nvim               | LSP progress spinner                                      |
| blink.cmp (v1.9.1)        | Completion engine (rust fuzzy impl)                       |
| LuaSnip (v2.4.1)          | Snippet engine                                            |
| friendly-snippets         | Community snippet collection (VSCode format)              |
| copilot.lua               | Copilot backend (suggestions/panel disabled)              |
| blink-cmp-copilot         | Copilot source for blink.cmp                              |
| conform.nvim              | Format on save                                            |
| nvim-treesitter           | Syntax/highlighting (FileType autocmd enables per-buffer) |
| nui.nvim                  | Neo-tree dependency                                       |
| neo-tree.nvim             | File explorer                                             |
| vim-tmux-navigator        | C-h/j/k/l tmux pane navigation                            |

## Key Keymaps

| Key                       | Action                                   |
| ------------------------- | ---------------------------------------- |
| `<leader>`                | Space                                    |
| `<leader>e`               | Toggle Neo-tree                          |
| `<leader>f`               | Format buffer (conform)                  |
| `<leader>s*`              | Telescope searches                       |
| `<leader><leader>`        | Find files (fff: git-root or cwd)        |
| `<leader>gg`              | Git status (Telescope)                   |
| `<leader>h*`              | Gitsigns hunk operations                 |
| `<leader>u*`              | UI toggles (blame, inlay hints, deleted) |
| `<leader>q`               | Diagnostic quickfix list                 |
| `<C-g>`                   | Copy current file path to clipboard      |
| `grn/gra/grr/gri/grd/grD/grt` | LSP rename/action/refs/impl/def/decl/type |
| `gO / gW`                 | Document / workspace symbols             |

## Formatting (conform.nvim)

- Format on save for all filetypes except `c`/`cpp`
- Formatters: `stylua` (lua), `prettierd`/`prettier` (js/ts/css/html/json/yaml/md)
- Manual format: `<leader>f`

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
- To add an LSP server: create `lsp/<server>.lua` with `---@type vim.lsp.Config`
- `nvim-pack-lock.json` is auto-updated on install/update — commit it
- Treesitter parsers installed via `require("nvim-treesitter").install({...})`

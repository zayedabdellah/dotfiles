# Zayed’s Inari Neovim IDE

This is a small, hand-built Neovim setup for Gentoo, Hyprland, and Kitty. It uses the Inari Vermilion × Gruvbox Dark Hard palette from the Kitty configuration. It is not a prebuilt distribution. Neovim 0.12.6 is the target.

The repository copy is `config/nvim/`. The installed copy is `~/.config/nvim/`. They are separate directories: editing one does not update the other. This guide describes the repository version unless it says “live”.

## First ten minutes

1. Start with `nvim`. Open a file with `nvim hello.py`, or from inside Neovim type `:e hello.py` and press Enter. A new file is created when you save it.
2. You start in **Normal mode**, where keys navigate and edit. Press an arrow key to move. Press `i` to enter **Insert mode** and type. Press `Esc` to return to Normal mode.
3. Press `/`, type `print`, then Enter to search. Press `n` for the next match or `N` for the previous match. Press `Esc` to clear the highlight.
4. Try `u` to undo. Press `r` to redo (or use Neovim’s usual `Ctrl+r`). `dd` deletes a line; `yy` copies a line; `p` pastes after the cursor.
5. Save with `:w`. Save and quit with `:wq`. Quit with `:q`. If there are unsaved changes, `:q` asks you to save or cancel; `:q!` discards them.
6. Press Space and pause. Which-key displays the available leader shortcuts and their descriptions. For example, press Space, then `f`, then `f` to open the file picker.
7. In a project, Space `f` `g` searches its text. Type a word and press Enter on a result to open that location.
8. Open `:Explore` or press Space `e` to browse files in the current directory. Press `-` inside netrw to move to the parent directory; press Enter to open a file or directory.
9. Open a code file that has a configured, installed formatter and save it. Formatting runs before the write. Use Space `c` `f` to format manually.
10. Close the current buffer with Space `b` `d`. If it has unsaved changes, Neovim asks whether to save, discard, or cancel.

## Neovim modes and files

Neovim is a terminal text editor. Its modes let the same keyboard serve for navigation, typing, selecting, and commands.

| Mode | What it does | How to enter / leave |
| --- | --- | --- |
| Normal | Navigate, delete, copy, paste, undo, and run mappings | The starting mode; `Esc` returns here |
| Insert | Type text into the file | `i` enters; `Esc` leaves |
| Visual | Select text or lines | `v` selects characters; `V` selects lines; `Esc` leaves |
| Command-line | Enter commands such as `:w` and `:q` | Type `:` in Normal mode; Enter runs, Esc cancels |

Arrow keys work in Normal, Insert, and Visual modes. The usual `h`, `j`, `k`, and `l` motions remain available too. Neovim’s built-in `w` and `b` meanings are deliberately reversed in Normal and Visual mode: `w` goes to the previous word and `b` to the next word. Operator-pending mode keeps Neovim’s normal motions, so combinations such as `dw` and `cw` continue to operate in their familiar direction.

Files are saved with `:w`; `:wq` saves and exits; `:q` exits when there are no unsaved edits; and `:q!` exits while discarding edits. `i`, `Esc`, and `v` are ordinary built-in mode keys. `dd`, `yy`, `p`, `u`, `/`, `n`, `N`, `gg`, `G`, `0`, and `$` are also Neovim’s built-in editing or navigation commands.

`r` is remapped to redo, the same action as `Ctrl+r`. The tradeoff is that Neovim’s built-in Normal-mode `r` command for replacing one character is no longer available under that key. `Ctrl+r` still works. In Insert mode, `Ctrl+r` keeps its native “insert a register” behavior.

## Leader and Which-key

Space is the leader key. A mapping written `<leader>ff` means: press Space, then `f`, then `f`. Which-key opens after the Space prefix and shows descriptions for the leader commands. Mapping descriptions also label the custom `w`, `b`, and `r` actions. No custom arrow-key mappings are needed; the arrows keep their built-in behavior.

## Complete custom keybinding reference

`gd`, `gr`, `K`, `<leader>ca`, and `<leader>rn` are installed for the current buffer when an LSP server attaches. The remaining mappings are global.

| Key | Mode | Action |
| --- | --- | --- |
| `w` | Normal, Visual | Move to the previous word |
| `b` | Normal, Visual | Move to the next word |
| `r` | Normal | Redo; same as `Ctrl+r` |
| `Esc` | Normal | Clear search highlighting |
| `<leader>e` | Normal | Open the built-in netrw file explorer (`:Explore`) |
| `<leader>ff` | Normal | Telescope: find files |
| `<leader>fg` | Normal | Telescope: search text in project files (needs `rg`) |
| `<leader>fb` | Normal | Telescope: find and switch open buffers |
| `<leader>fh` | Normal | Telescope: search Neovim help |
| `<leader>bd` | Normal | Close buffer; prompt before handling unsaved edits |
| `<leader>cw` | Normal | Close the current window |
| `<leader>cf` | Normal | Format current file with Conform |
| `<leader>sw` | Normal | Write the current file with vim-suda and sudo |
| `gd` | Normal, LSP buffer | Go to definition |
| `gr` | Normal, LSP buffer | Find references |
| `K` | Normal, LSP buffer | Show hover documentation |
| `<leader>ca` | Normal, LSP buffer | Show code actions |
| `<leader>rn` | Normal, LSP buffer | Rename symbol |
| `<C-k>` | Normal, LSP buffer | Show signature help |

The standard arrow keys work in Normal, Insert, and Visual modes. Normal Vim keys such as `i`, `v`, `dd`, `yy`, `p`, `u`, `gg`, `G`, `0`, `$`, `/`, `n`, and `N` are built in rather than custom mappings. Normal save and quit commands are `:w`, `:wq`, `:q`, and `:q!`.

### Small cheat sheet

| Goal | Keys / command |
| --- | --- |
| Start typing | `i`; return to navigation with `Esc` |
| Move | Arrow keys; or `w` previous word, `b` next word |
| Copy / delete / paste a line | `yy` / `dd` / `p` |
| Undo / redo | `u` / `r` or `Ctrl+r` |
| Search | `/text`, Enter, then `n` or `N` |
| Save / quit | `:w`, `:wq`, `:q`; force discard with `:q!` |
| Find file / project text | Space `f` `f` / Space `f` `g` |
| Format / protected save | Space `c` `f` / Space `s` `w` |

For example, `/config` searches forward for “config”. Press `n` to visit the next occurrence and `N` to go back to the previous one. Search ignores letter case unless the query contains an uppercase letter.

## Files, buffers, and windows

A **file** is stored on disk. A **buffer** is Neovim’s in-memory view of a file; several buffers can be open even though only one is visible. A **window** is a view onto a buffer; splitting a window does not create another file. `<leader>fb` lists buffers. `<leader>bd` closes the current buffer and uses Neovim’s confirmation flow when it has unsaved changes. `<leader>cw` closes the current window.

The built-in netrw browser opens with `<leader>e` or `:Explore`. Telescope’s `<leader>ff` searches filenames from the working directory; `<leader>fg` searches file contents and requires ripgrep (`rg`). Telescope opens a selected result in a buffer. `<leader>fh` searches installed Neovim help.

## Programming tools

### Syntax, Treesitter, and LSP

Treesitter parses source code so Neovim can highlight its structure, fold syntax nodes, and use parser indentation when a parser is installed. This setup uses the current `nvim-treesitter` main API. Use `:TSInstallRecommended` for the selected parser list and `:checkhealth nvim-treesitter` to inspect it. Parser installation needs GitHub access and a compiler/toolchain.

An **LSP server** is a separate program that understands a language and reports definitions, references, completion items, diagnostics, and edits. This configuration uses Neovim 0.12’s `vim.lsp.config()` and `vim.lsp.enable()` APIs. It does not use the old `require('lspconfig').server.setup()` pattern. When a server attaches, `gd`, `gr`, `K`, Space `c` `a`, Space `r` `n`, and `Ctrl+k` become available for that buffer. Diagnostics appear as signs, underlines, and virtual text.

Mason loads at startup so `:Mason` is available immediately. It is optional: no language servers are installed automatically. Open `:Mason` to browse installers. mason-lspconfig enables configured servers after they are installed. Servers already on `PATH` can also work without Mason. The configured server names are `lua_ls`, `clangd`, `pyright`, `rust_analyzer`, `ts_ls`, `html`, `cssls`, `jsonls`, `bashls`, and `fish_lsp`. Check `:checkhealth vim.lsp`, `:Mason`, and `:LspLog` if a server does not start.

nvim-cmp provides completion from LSP, paths, the current buffer, and LuaSnip snippets. In Insert mode, `Ctrl+Space` opens completion, `Ctrl+n` and `Ctrl+p` change the selection, Enter accepts the selected item, `Ctrl+e` closes the menu, and Tab / Shift-Tab expand or move through snippets when available. LuaSnip loads the friendly-snippets collection.

### Automatic formatting

Conform formats a buffer **before it is saved** if a configured formatter is installed and available. It runs only one formatter per filetype, never invokes LSP formatting on save, and uses a 1.8 second timeout. Missing formatters are skipped; saving remains available. There is no fallback that silently rewrites an unsupported language. Space `c` `f` runs the configured formatter manually. `:ConformInfo` reports which formatter Conform selected.

| Filetype | Formatter | Availability on this machine |
| --- | --- | --- |
| Lua | `stylua` | Missing; Gentoo search finds `dev-util/stylua` masked |
| C / C++ | `clang-format` | Installed at `/usr/lib/llvm/22/bin/clang-format` |
| Python | `ruff format` | Missing; Gentoo search finds `dev-util/ruff` |
| JavaScript / JSX / TypeScript / TSX, JSON / JSONC, HTML, CSS / SCSS, YAML, Markdown | `prettier` | Missing; Gentoo search did not find the general Prettier package |
| Shell / Bash | `shfmt` | Missing; Gentoo search did not find the formatter package |
| Fish | `fish_indent` | Installed at `/usr/bin/fish_indent` |
| Rust | `rustfmt` | Installed at `/usr/bin/rustfmt` |

Formatter tools use their normal project configuration (for example `.prettierrc`, `pyproject.toml`, `.clang-format`, or `stylua.toml`). The EditorConfig plugin applies `.editorconfig` indentation and line-ending settings to buffers; formatters that support EditorConfig can read it too. `fixendofline` requests a final newline by default, subject to buffer/project settings. A missing formatter is not downloaded by Neovim. No formatter package has been installed as part of this setup. Gentoo package searches are local-tree snapshots; check your current Portage tree before choosing an atom. Do not enable global USE flags just for the editor.

### Protected files with vim-suda

The Lazy spec loads vim-suda when `:SudaRead`, `:SudaWrite`, or Space `s` `w` is used, including from a fresh session after the plugin has been installed. vim-suda provides the two commands through the normal sudo authentication mechanism. The config explicitly sets `g:suda_smart_edit = 0`; normal `:w` does **not** request elevated access. For a protected file you cannot read normally, use `:SudaRead /etc/portage/make.conf`, edit it, then press Space `s` `w` or run `:SudaWrite`. For readable files, ordinary `:e /path` works and explicit `:SudaWrite` can still be used to save.

GitHub DNS is unavailable in this restricted environment, so I could not inspect the plugin source or verify that the deferred commands register as expected after installation. Its exact symlink, ownership, external-modification, and replacement behavior also remains unverified here. Treat privileged writes as sensitive: inspect the buffer and target before saving, and keep a separate backup of important system files. No privileged write was run during testing; do not assume the plugin’s write is atomic or race-free.

## Remaining plugins

| Plugin | Purpose |
| --- | --- |
| Lazy.nvim | Sole plugin manager; bootstrap, lazy loading, updates, and lockfile |
| nvim-web-devicons | Small Nerd Font-compatible file icons for Telescope and Lualine |
| lualine.nvim | Mode, filename, Git diff, diagnostics, filetype, progress, and cursor status |
| which-key.nvim | Descriptions for leader-key sequences |
| telescope.nvim | File, text, buffer, and help pickers |
| plenary.nvim | Telescope’s required utility dependency |
| nvim-treesitter | Parsing, highlighting, folds, and parser indentation |
| treesitter-parser-registry | Parser metadata used by current Treesitter |
| mason.nvim | Optional language-server installer and `:Mason` UI |
| mason-lspconfig.nvim | Connects Mason-installed servers to Neovim LSP |
| nvim-lspconfig | Language-server configuration data for native Neovim LSP APIs |
| nvim-cmp and cmp sources | Completion menu, LSP/buffer/path/command sources, and snippets |
| LuaSnip, cmp_luasnip, friendly-snippets | Snippet expansion and completion integration |
| conform.nvim | External formatters and format-on-save |
| editorconfig-vim | Applies project `.editorconfig` settings |
| vim-suda | Explicit privileged read and write commands |

Harpoon, Fugitive, Rhubarb, vim-css-color, and nvim-notify have been removed. Git stays available in the terminal and Telescope can search files in Git repositories; there is no added Git interface. CSS color preview was dropped to keep the plugin set small.

## Clipboard and Kitty

On the local Wayland session Neovim uses its native clipboard provider, which detects `wl-copy` and `wl-paste`. In SSH sessions, the config selects Neovim’s built-in OSC 52 clipboard provider. Remote clipboard reads depend on terminal support and policy. Kitty still controls JetBrains Mono, Arabic fallback, cursor, colors, true color, and background opacity. The theme uses an opaque `#1c1c1c` background and does not enable transparency or change Kitty settings.

## Plugin and lockfile maintenance

Use `:Lazy` to inspect plugins. `:Lazy sync` installs declared plugins, updates their lock entries, and removes unused ones. `:Lazy restore` installs the revisions in the lockfile. `:Lazy clean` removes installed plugins that are no longer declared. After changing plugin specs, run `:Lazy sync`, inspect `~/.config/nvim/lazy-lock.json`, and copy the reviewed lockfile into the repository with the deployment workflow below. The repository lockfile preserves the previously populated revisions of retained plugins and removes obsolete entries. The newly added vim-suda and EditorConfig plugins do not have pinned revisions until a successful sync records them.

Restart Neovim to reload the complete configuration. There is intentionally no hot-reload mapping.

## Safe Neovim-only deployment

Do not run the main `install.sh` just to update Neovim; it manages other desktop settings too. From the dotfiles repository, close Neovim first, then review and validate the repository config. Run this Bash block to stage a complete copy, move the old live config itself (including a symlink, if present) to a timestamped backup beside it, and install the staged directory. It does not use sudo or follow a `~/.config/nvim` destination symlink.

```bash
set -euo pipefail
repo="$PWD"
live="$HOME/.config/nvim"
stamp="$(date +%Y%m%d-%H%M%S)"
backup="$HOME/.config/nvim.backup-$stamp"
[[ ! -e "$backup" && ! -L "$backup" ]] || { printf 'Backup path already exists: %s\n' "$backup" >&2; exit 1; }
stage="$(mktemp -d "$HOME/.config/.nvim-stage.XXXXXX")"
trap '[[ -z "${stage:-}" ]] || { [[ ! -d "$stage" ]] || mv -- "$stage" "$stage.failed"; }' EXIT

cp -a -- "$repo/config/nvim/." "$stage/"
if [[ -s "$live/lazy-lock.json" ]]; then
    cp -- "$live/lazy-lock.json" "$stage/lazy-lock.json"
fi
if [[ -e "$live" || -L "$live" ]]; then
    mv -- "$live" "$backup"
fi
mv -- "$stage" "$live"
stage=""
trap - EXIT
printf 'Installed %s; previous config is backed up at %s\n' "$live" "$backup"
```

The backup is `~/.config/nvim.backup-<timestamp>`. If the live config has a populated lockfile, the staged config inherits that file instead of replacing it with the repository copy; run `:Lazy sync` after deployment to reconcile removed/added plugins. Then copy the reviewed generated lockfile back into `config/nvim/` as described below. To roll back, close Neovim and use the exact backup path printed by the deployment command:

```bash
live="$HOME/.config/nvim"
backup="$HOME/.config/nvim.backup-YYYYMMDD-HHMMSS" # replace with the printed path
failed="$HOME/.config/nvim.failed-$(date +%Y%m%d-%H%M%S)"
mv -- "$live" "$failed"
mv -- "$backup" "$live"
```

This procedure deliberately keeps each backup rather than deleting it. If copying or installation fails, inspect the staged directory and backup before retrying; do not run the full desktop installer as recovery.

### Repository, live config, and lockfile workflow

The live config is a separate copy. Check differences before deployment or copying its lockfile: `diff -ru config/nvim ~/.config/nvim`. Do not replace a populated live lockfile with an empty or older repository file. After `:Lazy sync`, review the live lockfile and, from the repository root, copy only that file back:

```bash
cp -a -- ~/.config/nvim/lazy-lock.json config/nvim/lazy-lock.json
git diff -- config/nvim/lazy-lock.json
```

Before staging, `git diff` does not show untracked Neovim files; use `git status --short` and inspect the files under `config/nvim/`. The staged diff below shows every file that will be committed. Save changes to Git only after reviewing it. Example commands for this feature branch:

```bash
test "$(git branch --show-current)" = feature/neovim-ide
git status --short
git add config/nvim/ install.sh tests/test-installer-safety.sh
git diff --cached --check
git diff --cached
git commit -m "Finalize custom Inari Neovim IDE"
git push -u origin feature/neovim-ide
```

These are instructions only; this configuration does not switch branches, stage, commit, or push automatically. Keep `master` unchanged.

## Health checks and troubleshooting

- `:checkhealth` — inspect Neovim providers and core features.
- `:checkhealth vim.lsp` — inspect native LSP support.
- `:checkhealth nvim-treesitter` — inspect parser prerequisites and installs.
- `:Mason` — inspect or install optional language servers.
- `:ConformInfo` — inspect formatter availability for the current buffer.
- `:Lazy` — inspect plugin state; `:Lazy sync` reconciles specs and lockfile.
- `:messages` — see startup and plugin messages.
- `:echo executable('clang-format')` — check an external program; replace the name as needed.
- `:verbose map <leader>sw` — find the source of a mapping.
- If `:SudaWrite` is unknown, run `:Lazy sync`, restart Neovim, then try the command again. It needs the vim-suda checkout and a working sudo setup.
- If Telescope live grep fails, install or expose `rg` on `PATH`.
- If formatting does not run, inspect `:ConformInfo`; a missing executable is skipped. Install only the formatter you need.
- If an LSP does not attach, check Mason or the server executable, project root markers, `:checkhealth vim.lsp`, and `:LspLog`.
- If local clipboard is unavailable, confirm `WAYLAND_DISPLAY` and `wl-copy` / `wl-paste`. For SSH, the terminal must support OSC 52 and permit clipboard operations.

No system package install, privileged file write, or graphical session test is part of this configuration work. Formatters and plugins absent from the machine require separate installation and interactive verification.

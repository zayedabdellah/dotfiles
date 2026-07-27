# Asset provenance and redistribution review

This inventory covers assets currently present in the repository after the
Phase 1 safety review. An asset marked `EXCLUDED` is not part of the intended
installer payload. A `REVIEW` item must be cleared before public redistribution.

| Asset | Status | Provenance / license | Notes |
| --- | --- | --- | --- |
| `fonts/` JetBrains Mono and Nerd Font variants | INCLUDED | SIL Open Font License 1.1; notices retained in `fonts/OFL.txt`, `fonts/fonts/ttf/OFL.txt`, and `fonts/AUTHORS.txt` | Confirm the complete Nerd Fonts attribution/source record before a public release. |
| `themes/gruvbox-dark-gtk/` | INCLUDED | GPLv3; local `LICENSE`; upstream `jmattheis/gruvbox-dark-gtk` | Its README identifies an external icon-theme project, but this repository does not bundle that icon theme. |
| `icons/Bibata-Modern-Amber/` | INCLUDED | GPL-3.0-only; official upstream `https://github.com/ful1e5/Bibata_Cursor` | The repository contains an upstream-license notice beside the cursor files. |
| `config/rofi/themes/gruvbox-dark-hard.rasi` | INCLUDED | MIT; upstream `https://github.com/bardisty/gruvbox-rofi` | Local MIT notice added beside the theme. |
| `config/cava/shaders/orion_*.frag` | INCLUDED | MIT; SPDX copyright and license notices are present in each shader | These are the only bundled Cava shaders retained in Phase 1. |
| `themes/kvantum/gruvbox-kvantum/` | INCLUDED / LICENSE NOTICE ABSENT | The owner authorized publishing the exact active `.kvconfig` and `.svg`; the configuration identifies Sourav Gope, but the local payload contains no standalone license notice | Deployed only to `~/.config/Kvantum/gruvbox-kvantum/`. Owner authorization covers this branch; downstream redistribution rights should still be reviewed. |
| `config/btop/themes/gruvbox_dark_v2.theme` | INCLUDED | btop is Apache-2.0; the theme header credits the Gruvbox project and named authors | Exact active theme copied into the user-theme location; attribution is retained in the file and this inventory. |
| `themes/oh-my-posh/torii-zayed.omp.json` | INCLUDED | Exact active user theme; no embedded credentials or machine path | Deployed to `~/.themes/torii-zayed.omp.json`; dynamic path and hostname segments remain intentional prompt behavior. |
| `config/fastfetch/claude.txt` | INCLUDED | User explicitly confirmed permission to use and publish this active logo | Deployed with `config.jsonc` to `~/.config/fastfetch/`; contains no credentials, host paths, or executable content. Claude/Anthropic branding may still carry trademark considerations. |
| Unlicensed Cava shaders and themes | EXCLUDED | License/provenance not established; one shader explicitly credited an unlicensed Shadertoy source | Removed from the repository payload. |
| `config/hypr/wallpapers/torii.jpg` | INCLUDED | User confirmed ownership or permission to redistribute | Shared wallpaper for both profiles; Hyprlock uses it when present and uses the screenshot fallback only when it is absent. |
| `config/brave/theme/manifest.json` | INCLUDED | Sanitized theme manifest authored for this repository | Contains browser-interface colors only; no profile or extension state. |
| `config/google-chrome/themes/` | EXCLUDED | Generated browser-extension payload | Removed; the sanitized Brave manifest is the only browser theme payload. |
| Optional emulator and overlay configs | OPTIONAL | Sanitized configuration only; generated or hardware-specific values are documented | No ROMs, BIOS files, saves, states, cores, thumbnails, logs, caches, or private paths are included. |

Unknown or incompatible assets must remain excluded until their copyright and
redistribution terms are documented.

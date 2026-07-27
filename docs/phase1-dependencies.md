# Phase 1 visual dependencies

This is the portability record for the profile-aware installer. Arch has a
complete official-package path; other distributions retain the limitations
documented in `docs/compatibility.md`.

| Feature | Required dependency | Current repository use | Portability note |
| --- | --- | --- | --- |
| GTK, Qt, and xsettingsd icons | `Papirus-Dark` icon theme | Referenced by GTK 3/4, Qt6ct, and xsettingsd | Required. Arch installs `papirus-icon-theme`; Gentoo and experimental platforms retain the mapping limitations documented separately. |
| Rofi application icons | `Oranchelo` preferred, `Papirus-Dark` fallback | `config/rofi/config.rasi` preserves Oranchelo; `config/rofi/launch.sh` detects it at runtime | Oranchelo is not bundled or redistributed. If unavailable, the wrapper passes `-icon-theme Papirus-Dark`; if both are absent, Rofi still starts with its default icon behavior. |
| Qt widget style | `gruvbox-kvantum`, Kvantum, Qt6ct | Exact approved local payload under `themes/kvantum/gruvbox-kvantum/`, user selector, and `style=kvantum` | Installed to Kvantum's user discovery directory for both profiles. Owner approved branch publication; the local payload has no standalone license notice. |
| Fastfetch prompt | `fastfetch`, JetBrains Mono Nerd Font | Active `config/fastfetch/config.jsonc` and approved `claude.txt` logo | Built-in modules degrade gracefully when VM battery/GPU data is absent. Private-use key glyphs require the bundled Nerd Font. |
| Login shell | Fish, `chsh`, `getent`, `/etc/shells` | Interactive no-argument installer defaults the Fish question to Yes | Arch `util-linux` supplies `chsh`; the installer targets the `id`-resolved non-root account and verifies field 7 from `getent`. |
| Wallpaper | `awww`, `awww-daemon`, Torii asset | Shared `wallpaper.sh` owns daemon startup for both profiles | A bounded cold-start readiness loop prevents the default Hyprland background from winning the startup race. |
| btop theme | `gruvbox_dark_v2` | Exact active theme under `config/btop/themes/` | Deployed as a user theme, avoiding the active machine's `/usr/share` absolute path. |
| MPV subtitles | `JetBrains Mono` | Bundled under the repository's font payload | Replaces the unverified Google Sans font and removes the missing MPV font directory reference. |

The installer checks for Papirus-Dark but does not install it outside its
existing package-management behavior. Oranchelo remains the preferred visual
choice without being bundled; runtime fallback is automatic and documented.

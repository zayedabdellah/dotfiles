# Dotfiles

This repository contains a portable snapshot of the active desktop rice. The
active configuration is the source of truth; backups, generated state, private
profiles, browser profiles, and game content are intentionally excluded.

The Hyprland configuration is modular Lua and keeps the active keybinds,
startup commands, window rules, workspace behavior, Waybar actions, scripts,
and appearance values intact.

## Prerequisites

Run the installer as the normal desktop user on a supported Arch, Gentoo, or
experimental Fedora/NixOS system. A fresh Arch installation is supported: the
default operation installs the complete verified official package set before
deploying configuration. It must not be run as root.

## Machine profiles

The current laptop is represented by the exact first-class profile:

```text
config/hypr/profiles/zayed-laptop.lua
  eDP-1 / 2560x1600@165 / position 0x0 / scale 2
```

`config/hypr/profiles/generic.lua` is the safe fallback. The laptop profile is
never selected implicitly: choose it explicitly with
`DOTFILES_MACHINE_PROFILE=zayed-laptop` or an ignored
`config/hypr/machine.local.lua` based on
`config/hypr/machine.local.lua.example`. Invalid profile names stop with a
clear error.

Waybar receives the selected profile's `DOTFILES_NETWORK_INTERFACE`. The
laptop retains `wlp3s0`; generic systems use the active route interface or
Waybar's own automatic selection.

## Installation

To set up these dotfiles, follow these steps:

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/zayedabdellah/dotfiles.git
    cd dotfiles
    ```

2.  **Run the installation script:**

    The `install.sh` script will:
    *   Check the current system for required applications (e.g., `kitty`,
        `waybar`, `rofi`, `grim`, `slurp`, `brightnessctl`, `playerctl`,
        `swaync`, `awww-daemon`, `hyprpolkitagent`, `hyprshutdown`).
    *   Copy the approved core configuration to its XDG destination, including
        hidden files.
    *   Copy the approved configuration, theme, cursor, font, wallpaper, and
        script assets to their corresponding XDG locations.
    *   Install Fastfetch and its approved Claude logo, then start it once per
        interactive Fish session (`ff` is an alias for `/usr/bin/fastfetch`).
    *   Apply the GTK, icon, cursor, font, Qt6ct, and Kvantum user settings.
    *   Ask once near the beginning about the Fish login shell and required
        NetworkManager, Bluetooth, and power-profile services.

    ```bash
    chmod +x install.sh
    ./install.sh
    ```

With no arguments the installer presents the profile menu, prints the complete
plan, asks for confirmation, installs packages, deploys files, applies desktop
settings, validates the result, and prints a detailed final checklist. No
additional `--apply-desktop-settings` or `--set-default-shell` invocation is
required. The menu is:

```text
1) Generic
   Detect monitor, network interface, and safe GPU settings.
2) Zayed laptop
   Preserve eDP-1, 2560x1600@165, position 0x0, scale 2, wlp3s0, and NVIDIA settings.
```

If the non-private display/GPU check is exact, option 2 is recommended but
never selected silently. Non-interactive operation safely selects `generic`
unless `--profile` is supplied.

The normal no-argument flow offers official and AUR optional modules in one
early selection prompt; Enter selects none. `--enable-optional MODULE` remains
available for advanced or targeted runs. `--packages-only`, `--config-only`,
and `--skip-packages` separate package and configuration operations. Use `--audit`
or `--dry-run` to inspect planned actions without downloads, package changes,
shell changes, desktop settings, or configuration deployment. On a normal
interactive full install, Fish is offered as the default shell with Yes as the
default. The installer resolves the target with `id`, verifies Fish and
`/etc/shells`, runs `chsh` for that account, checks the resulting `getent`
record, and explains that logout/login or reboot is required. Declining leaves
the login shell unchanged. `--set-default-shell` remains available for
explicit targeted runs. Normal no-argument installation automatically applies
the approved desktop settings; `--apply-desktop-settings` remains available
for targeted reruns.

The initial flow also asks whether required system services should be enabled
when needed. It never enables a display manager or unrelated system service.
Optional official and AUR components remain clearly separated. AUR components
require an existing helper and explicit approval; no helper is installed.

Before replacing a different existing file, the installer creates a
timestamped backup under `~/.local/state/dotfiles/backups/` and records each
replacement in `manifest.tsv`. Unchanged files are left untouched, and
unrelated files are preserved. A complete restore/uninstall orchestrator is
still future work.

Gentoo and Arch are the supported package-management targets. Gentoo uses
verified Portage atoms only and prints USE-flag/overlay guidance without
changing Portage configuration. Fedora support is experimental and performs
no automatic package installation. NixOS requires a future native
NixOS/Home Manager module; this shell installer does not manage NixOS
packages declaratively.

3.  **Restart Hyprland:**

    After the script completes, restart your Hyprland session to apply the new configurations.

## Configuration Details

### Hyprland

The Hyprland configuration is located in `~/.config/hypr/`. It uses a modular Lua setup, with `hyprland.lua` requiring various modules from the `modules/` directory for different aspects like keybinds, autostart, decorations, and more.

### Waybar

The Waybar configuration is located in `~/.config/waybar/`. It includes `config.jsonc` for the main bar layout and `style.css` for styling. Custom scripts used by Waybar are found in `scripts/`.

### Themes

GTK, Qt/Kvantum, cursor, browser-interface theme, font, and wallpaper assets
are included under `themes/`, `icons/`, `config/brave/`, `fonts/`, and
`config/hypr/`. The confirmed Torii image is included at
`config/hypr/wallpapers/torii.jpg`; the Hyprlock wrapper still uses a
screenshot fallback only when the image is absent. Hyprland autostart invokes
`wallpaper.sh` for both profiles. That script is the sole owner of starting
`awww-daemon`, waits up to ten seconds for cold-start readiness, and reports a
real failure if the daemon or `awww img` fails.

Fastfetch is deployed to `~/.config/fastfetch/config.jsonc` with its approved
logo at `~/.config/fastfetch/claude.txt`. Its private-use icons require the
bundled JetBrains Mono Nerd Font payload. Oh My Posh uses only
`~/.themes/torii-zayed.omp.json`; no nested duplicate theme is deployed.

#### Theme Setup Instructions

The installer selects the GTK, Papirus-Dark icon, Bibata cursor, and Nerd Font
settings automatically. For Qt, it deploys the complete approved payload only
to `~/.config/Kvantum/gruvbox-kvantum/`, preserves unrelated selector entries,
sets `theme=gruvbox-kvantum`, and configures Qt6ct with `style=kvantum`.
Kvantum Manager consequently lists **gruvbox-kvantum** under its user themes;
no manual theme selection is required.

## Dependencies

The following applications are used in these configurations:

*   **Hyprland**: The Wayland compositor itself.
*   **Waybar**: A highly customizable Wayland bar.
*   **kitty**: A fast, feature-rich, GPU based terminal emulator.
*   **Thunar**: A fast and easy to use file manager.
*   **Rofi**: A window switcher, application launcher, and dmenu replacement.
*   **Brave Browser**: A privacy-focused web browser.
*   **hyprshutdown**: A graceful shutdown utility for Hyprland.
*   **hyprlock**: A screen locker for Hyprland.
*   **grim**: A screenshot utility for Wayland.
*   **slurp**: A utility to select a region on a Wayland compositor.
*   **wl-clipboard**: Command-line copy/paste utilities for Wayland.
*   **PipeWire**: A server for handling audio and video streams.
*   **brightnessctl**: A utility to control screen brightness.
*   **playerctl**: A command-line utility to control media players.
*   **swaync**: A Wayland native notification daemon.
*   **awww-daemon**: An animated wallpaper daemon for Wayland.
*   **hyprpolkitagent**: A Polkit agent for Hyprland.
*   **nwg-look**: A GTK3 settings editor for wlroots-based compositors.
*   **Kvantum**: A SVG-based theme engine for Qt.
*   **qt6ct**: Qt6 Configuration Tool.
*   **fish**: A smart and user-friendly command line shell.
*   **Fastfetch**: Interactive system information using the approved Claude logo.
*   **util-linux / chsh**: Safe login-shell selection and verification support.
*   **Papirus-Dark**: Required icon theme for GTK, Qt, xsettingsd, and Rofi fallback.

Rofi preserves Oranchelo as the preferred icon theme without bundling it. The
Rofi launcher detects Oranchelo and falls back to the required Papirus-Dark
theme when Oranchelo is unavailable. If neither theme is installed, Rofi still
starts with its default icon behavior.

## Optional modules

RetroArch appearance settings, Sunshine, Dolphin Emulator, Suyu, GOverlay,
vkBasalt, vkSumi, Pavucontrol preferences, `mimeapps.list`, and Brave are
stored under `config/optional/` or `config/brave/` and are not part of the
default rice deployment. Arch official optional packages are installed only
when explicitly enabled. AUR modules (`suyu`, `vksumi`, and `brave`) require an
existing `paru` or `yay` and a separate confirmation; the installer never
installs an AUR helper.
ROMs, BIOS files, saves, states, downloaded cores, thumbnails, logs, caches,
private emulator paths, and complete Brave profiles are not included.

## Compatibility workaround

The unsafe `xhost +SI:localuser:root` command is not part of the default
autostart. Only if a specific legacy X11 application requires root access,
apply that command manually for the duration of that session and remove the
access afterward. It is not installed or automated by this repository.

## Fresh Arch VM test

Run these commands as the normal VM user:

```bash
sudo pacman -S --needed git
git clone --branch sync-host-2026 --single-branch https://github.com/zayedabdellah/dotfiles.git
cd dotfiles
git --no-pager log -1 --oneline
./install.sh
```

Choose `1) Generic`. Do not run the installer as root. After a successful run,
log out and back in or reboot. Real package and graphical-session integration
must be confirmed in the VM; the repository test suite uses mocked package,
account, service, and desktop-setting commands with temporary homes.

## Contributing

Feel free to fork this repository and adapt the configurations to your needs. If you have improvements or suggestions, please open an issue or submit a pull request.

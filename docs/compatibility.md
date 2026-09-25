# Compatibility notes

The default Hyprland autostart does not grant root access to XWayland.

If a specific legacy X11 application has an independently verified need for
root access, a user may manually run the following for that session only:

```sh
xhost +SI:localuser:root
```

This command is intentionally not automated by the repository. Remove the
access afterward with the appropriate X server command for that session.

## Distribution support

Arch is the immediate full-install target. Gentoo remains a primary target,
but the installer only passes verified Gentoo `category/package` atoms to
Portage and never adds overlays, keywords, masks, licenses, or USE flags
automatically. If a required Hypr ecosystem atom is not verified, deployment
stops before files are copied and the required manual review is printed.

Verified Gentoo examples used by the installer include:

```text
gui-wm/hyprland
gui-apps/waybar
app-emulation/kitty
app-shells/fish
app-misc/fastfetch
sys-apps/util-linux
app-misc/jq
media-fonts/noto
x11-misc/sddm
gui-libs/display-manager-init
xfce-base/thunar
gui-apps/grim
gui-apps/slurp
gui-apps/wl-clipboard
sys-power/brightnessctl
media-sound/playerctl
x11-themes/kvantum
gui-apps/qt6ct
net-misc/networkmanager
app-misc/btop
net-vpn/tailscale
net-wireless/bluez
net-wireless/blueman
```

Gentoo has no `bluez-utils` atom equivalent to Arch's split package.
`net-wireless/bluez` is the valid atom for the Bluetooth daemon and standard
tools, while `net-wireless/blueman` supplies both `blueman-manager` and
`blueman-applet`. `net-vpn/tailscale` supplies the Tailscale client and
daemon. Executable names are never passed to `emerge`.

On Gentoo/systemd the approved service path uses `bluetooth.service` and
`tailscaled.service`. On OpenRC it uses the package-provided `bluetooth` and
`tailscaled` services with `rc-update` and `rc-service`. The installer asks
before either path and never edits Portage, BlueZ, or Tailscale configuration.
Audit/dry-run and packages-only do not change services. The service tests are
mocked; both init variants still require confirmation on a real Gentoo system.

The official `tailscale systray` Linux tray is bundled in Tailscale 1.88 and
later, remains attached to the graphical user session, publishes a
StatusNotifierItem compatible with Waybar, and requires the `tailscaled`
daemon. Current Gentoo package versions are new enough; no alternate
executable or separate tray atom is needed. The installer validates the
subcommand with `tailscale systray --help` but never launches it in the
non-graphical validation phase and never runs `tailscale up`.

Waybar commonly needs `network`, `wifi`, `tray`, `mpris`, `pipewire`,
`pulseaudio`, and `upower` USE support. Hyprland versions newer than the
verified main-repository ebuild may require `hyproverlay`; this repository
only prints that guidance and never enables it.

Fedora/Nobara support is experimental and incomplete. This installer does not
run `dnf` or `dnf5` automatically; the full Arch package path is not claimed
for Fedora and external repository coverage is not verified.

NixOS uses the repository's native flake and Home Manager configuration.
Follow `docs/nixos-install.md` for a fresh UEFI installation. The imperative
installer refuses to manage NixOS packages; use `nixos-rebuild` for subsequent
system and Home Manager changes. The current flake targets x86_64 UEFI and
expects a generated, reviewed `nixos/hardware-configuration.nix`.

## Kvantum local dependency

The active selector remains `gruvbox-kvantum`. The exact local payload is kept
under `themes/kvantum/gruvbox-kvantum/`; its source metadata names Sourav Gope
and the owner explicitly authorized publication on this testing branch. No
standalone redistribution license accompanied the local files, so downstream
reuse still requires review. Deployment copies `gruvbox-kvantum.kvconfig` and
`gruvbox-kvantum.svg` into:

```text
~/.config/Kvantum/gruvbox-kvantum/
```

That directory and matching base filenames are Kvantum's user-theme discovery
layout. The installer preserves unrelated entries in
`~/.config/Kvantum/kvantum.kvconfig`, sets `theme=gruvbox-kvantum`, and sets
Qt6ct `style=kvantum`. An incomplete payload is a fatal validation error; no
fallback theme is silently substituted.

Fastfetch maps to `app-misc/fastfetch` on Gentoo. The installer continues to
stop before deployment when any other required command lacks a verified
Gentoo atom; it never passes executable names to `emerge` or edits Portage
configuration.

## Arabic font resolution

Arch `noto-fonts` and Gentoo `media-fonts/noto` both provide the exact
Fontconfig family `Noto Kufi Arabic`. The repository-owned user rule is
installed at:

```text
~/.config/fontconfig/conf.d/65-noto-kufi-arabic.conf
```

It prepends Noto Kufi Arabic only when Fontconfig receives an Arabic-language
sans-serif, serif, or monospace generic request. English generic and terminal
fonts remain unchanged. CSS/Pango components add the family after JetBrains
Mono, and Kitty maps Arabic Unicode ranges without changing its primary font.
Qt6ct and Kvantum remain unchanged and use Fontconfig fallback.

Chromium/Brave and Firefox can use this fallback for browser UI and web content
that delegates to system fonts. Sites embedding their own webfont remain in
control. Terminal Arabic shaping, bidi order, and cell width depend on the
terminal and are not guaranteed to match proportional browser rendering.

## SDDM service handling

Arch uses the official `sddm` package and systemd `sddm.service`. The installer
requires a valid Hyprland entry under `/usr/share/wayland-sessions/`, never
starts the greeter during installation, and verifies both SDDM enablement and
the `display-manager.service` alias. A different enabled display manager is
left unchanged unless the user explicitly approves replacement.

Gentoo uses `x11-misc/sddm`; the standard OpenRC integration comes from
`gui-libs/display-manager-init`. On systemd Gentoo, the systemd path is used.
On OpenRC, the installer preserves unrelated
`/etc/conf.d/display-manager` content, sets only
`DISPLAYMANAGER="sddm"`, enables the `display-manager` service for the next
boot, and verifies both values. Unknown init layouts stop with TTY recovery
instructions instead of guessing.

The repository owns only `/etc/sddm.conf.d/10-dotfiles.conf`; it selects the
Bibata cursor at size 24 and contains no autologin, username, or password.
SDDM keeps its standard theme and default Latin UI font. Noto Kufi Arabic is
available through the system font package for Arabic fallback.

Optional emulator, overlay, streaming, and MIME modules are disabled by
default. Arch official packages are installed only when explicitly enabled;
AUR modules require an existing helper and a separate confirmation. Their
hardware-specific choices must still be reviewed manually before enabling
them.

## Hyprland and Waybar tray integration

`config/hypr/modules/autostart.lua` is the sole source of truth for
`blueman-applet` and `tailscale systray` startup in both the generic and
`zayed-laptop` profiles. It launches each asynchronously behind a per-user
`flock`, so a Hyprland reload does not create another copy. Missing commands
are skipped without failing the session, while genuine exits are recorded in
the user state log.

Waybar's existing `tray` module remains enabled in its original location.
There are no custom Tailscale/Blueman modules. Workspaces 1–5, media and Cava,
click actions, module order/style, generic network discovery, and the
`zayed-laptop` `wlp3s0` behavior remain unchanged. A fresh real Hyprland
session is required to verify that both StatusNotifier icons render and their
menus operate.

## Cursor resolution

Both profiles deploy `Bibata-Modern-Amber` under
`~/.local/share/icons/` and export an `XCURSOR_PATH` containing that directory
before the Hyprland session starts. This is required because Xcursor/XWayland
clients may otherwise search only legacy or system icon roots and fall back to
the generic `default` theme. The sole managed default index is
`~/.local/share/icons/default/index.theme`; it inherits
`Bibata-Modern-Amber`. The installer intentionally does not create a second
`~/.icons/default` copy.

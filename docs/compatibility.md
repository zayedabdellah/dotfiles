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
```

Waybar commonly needs `network`, `wifi`, `tray`, `mpris`, `pipewire`,
`pulseaudio`, and `upower` USE support. Hyprland versions newer than the
verified main-repository ebuild may require `hyproverlay`; this repository
only prints that guidance and never enables it.

Fedora/Nobara support is experimental and incomplete. This installer does not
run `dnf` or `dnf5` automatically; the full Arch package path is not claimed
for Fedora and external repository coverage is not verified.

NixOS support is experimental and incomplete. Use a future Nix flake and
Home Manager/NixOS module for Fish, Oh My Posh, packages, and configuration;
this shell installer does not replace declarative system configuration.

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

Optional emulator, overlay, streaming, and MIME modules are disabled by
default. Arch official packages are installed only when explicitly enabled;
AUR modules require an existing helper and a separate confirmation. Their
hardware-specific choices must still be reviewed manually before enabling
them.

## Cursor resolution

Both profiles deploy `Bibata-Modern-Amber` under
`~/.local/share/icons/` and export an `XCURSOR_PATH` containing that directory
before the Hyprland session starts. This is required because Xcursor/XWayland
clients may otherwise search only legacy or system icon roots and fall back to
the generic `default` theme. The sole managed default index is
`~/.local/share/icons/default/index.theme`; it inherits
`Bibata-Modern-Amber`. The installer intentionally does not create a second
`~/.icons/default` copy.

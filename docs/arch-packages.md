# Arch package plan

The default `./install.sh` Arch path installs the following official
repository packages with `pacman -S --needed` before deployment. The names
were checked against current Arch package metadata on 2026-07-28.

## Required official packages

```text
hyprland xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
xorg-xwayland waybar swaync fish kitty rofi hyprlock hypridle awww
pipewire pipewire-audio pipewire-alsa pipewire-pulse wireplumber
polkit hyprpolkitagent gtk3 gtk4 gsettings-desktop-schemas
qt6ct qt6-wayland qt5-wayland kvantum
papirus-icon-theme thunar thunar-volman tumbler mpv btop mangohud cava
grim slurp wl-clipboard brightnessctl playerctl pavucontrol-qt
networkmanager power-profiles-daemon bluez bluez-utils blueman tailscale
dbus libnotify xorg-xrdb xsettingsd fontconfig iproute2 procps-ng
coreutils findutils gawk curl unzip xdg-utils xdg-user-dirs
fastfetch util-linux jq noto-fonts sddm
```

This includes the executables used by Hyprland Lua, Waybar, Fish, scripts,
theming, audio, Bluetooth, networking, power profiles, screenshots, media,
and the user-local Oh My Posh installer. The repository supplies JetBrains
Mono and Bibata assets directly, so separate font/cursor packages are not
mandatory. `util-linux` supplies `chsh`, `fastfetch` renders the interactive
Fish system summary, and `jq` provides strict deployed JSON validation.
`noto-fonts` is the verified official package containing
`/usr/share/fonts/noto/NotoKufiArabic-Regular.ttf` and the exact Fontconfig
family `Noto Kufi Arabic`. `sddm` supplies the login manager; Hyprland itself
supplies the discoverable session entry under `/usr/share/wayland-sessions/`.
After the package transaction completes, the installer runs `fc-cache -f`
before its mandatory family check, then verifies the regular family through
both `fc-list` and `fc-match`; it does not require a particular weight,
filename, or `noto-fonts-extra`. A failed check prints the `noto-fonts` package
state and the relevant Fontconfig matches before configuration deployment is
refused. Audit and dry-run modes do not refresh the cache.
The bundled cursor is installed before desktop settings are applied; a missing
Bibata Xcursor/Hyprcursor payload is a fatal pre-deployment validation error.

`bluez` supplies `bluetooth.service`, `bluez-utils` supplies tools including
`bluetoothctl`, and `blueman` supplies both `blueman-manager` and
`blueman-applet`. `tailscale` supplies `/usr/bin/tailscale`,
`/usr/bin/tailscaled`, and `tailscaled.service`. As of this check, Arch Extra
ships Tailscale 1.98.9, which is newer than the 1.88 minimum for the official
Linux `tailscale systray` beta. The tray is part of the `tailscale` CLI; no
separate official Arch tray package is required.

After installation the executable phase validates `tailscale`, `tailscaled`,
`bluetoothctl`, `blueman-manager`, and `blueman-applet`. A separate
non-graphical check runs `tailscale systray --help`; it does not launch the
tray. The installer does not treat the absence of a graphical session as a
package failure.

The normal interactive flow asks before running the equivalents of
`systemctl enable --now bluetooth.service` and
`systemctl enable --now tailscaled.service`. It verifies enablement and active
state, or clearly reports that an enabled daemon must start after reboot.
Audit and dry-run never mutate services, packages-only does not configure
services, and a declined approval leaves them unchanged. The installer never
runs `tailscale up` or changes Tailscale/BlueZ preferences, credentials,
devices, pairings, trust, routes, exit nodes, or DNS.

The normal interactive flow also offers to enable `sddm.service` for the next
boot.
It verifies the package and Hyprland session, detects enabled GDM, LightDM,
greetd, Ly, and LXDM units, and requires explicit replacement approval before
using `systemctl enable --force sddm.service`. It never starts SDDM during the
installer. Packages-only mode installs both `noto-fonts` and `sddm` but does
not deploy Fontconfig or change services.

## Optional packages

Official repository packages are installed only when the matching module is
explicitly enabled:

```text
retroarch       -> retroarch
sunshine        -> sunshine
dolphin-emu     -> dolphin-emu
goverlay        -> goverlay
vkBasalt        -> vkbasalt
pavucontrol     -> pavucontrol-qt (already required by the active Waybar action)
```

These AUR packages are never installed silently:

```text
suyu             -> suyu
vkSumi           -> vksumi
brave            -> brave-bin
```

An existing `paru` or `yay` and a separate confirmation are required. The
installer never installs an AUR helper and never copies a Brave profile.

Oh My Posh is a pinned user-local upstream installation (`v29.31.1`) rather
than a distro package. Its exact theme is deployed to
`~/.themes/torii-zayed.omp.json`.

The installer uses exactly `pacman -S --needed` for interactive installation
(`--noconfirm` is added only for explicitly non-interactive mode). It does not
perform an unrelated `pacman -Syu`, and a mandatory package failure stops
before configuration deployment.

Hyprland launches `blueman-applet` and the verified `tailscale systray`
command once through the canonical Lua autostart module. Their StatusNotifier
icons use Waybar's existing `tray` module. This remains subject to a real
graphical Hyprland test after logout/reboot.

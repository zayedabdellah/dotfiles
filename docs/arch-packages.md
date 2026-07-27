# Arch package plan

The default `./install.sh` Arch path installs the following official
repository packages with `pacman -S --needed` before deployment. The names
were checked against current Arch package metadata on 2026-07-21.

## Required official packages

```text
hyprland xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
xorg-xwayland waybar swaync fish kitty rofi hyprlock hypridle awww
pipewire pipewire-audio pipewire-alsa pipewire-pulse wireplumber
polkit hyprpolkitagent gtk3 gtk4 gsettings-desktop-schemas
qt6ct qt6-wayland qt5-wayland kvantum
papirus-icon-theme thunar thunar-volman tumbler mpv btop mangohud cava
grim slurp wl-clipboard brightnessctl playerctl pavucontrol-qt
networkmanager power-profiles-daemon bluez bluez-utils blueman
dbus libnotify xorg-xrdb xsettingsd fontconfig iproute2 procps-ng
coreutils findutils gawk curl unzip xdg-utils xdg-user-dirs
fastfetch util-linux jq
```

This includes the executables used by Hyprland Lua, Waybar, Fish, scripts,
theming, audio, Bluetooth, networking, power profiles, screenshots, media,
and the user-local Oh My Posh installer. The repository supplies JetBrains
Mono and Bibata assets directly, so separate font/cursor packages are not
mandatory. `util-linux` supplies `chsh`, `fastfetch` renders the interactive
Fish system summary, and `jq` provides strict deployed JSON validation.
The bundled cursor is installed before desktop settings are applied; a missing
Bibata Xcursor/Hyprcursor payload is a fatal pre-deployment validation error.

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

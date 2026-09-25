# Fresh NixOS installation

This repository provides a UEFI/x86_64 NixOS configuration with Hyprland and
Home Manager. The Home Manager profile reuses the existing rice files; it does
not run the imperative `install.sh` installer. It selects the existing
`zayed-laptop` profile and assumes the username `zayed`, an NVIDIA-capable
x86_64 UEFI system, and a network connection during installation.

## 1. Boot and partition

Boot the official NixOS minimal ISO in UEFI mode, connect to the network, and
partition the intended installation disk using the NixOS manual's partitioning
guidance. The commands below assume an EFI System Partition at `/dev/disk/by-label/ESP`
formatted as FAT32 and a root filesystem at `/dev/disk/by-label/nixos` formatted
as ext4. Replace those labels and filesystem commands to match the partitions
you actually created. Formatting the wrong device destroys data.

Become root in the live environment, identify the correct disk and partitions,
then format the EFI and root partitions you created. Substitute the device
names shown by `lsblk`; these example commands erase the selected partitions.

```sh
sudo -i
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS
mkfs.fat -F 32 -n ESP /dev/<efi-partition>
mkfs.ext4 -L nixos /dev/<root-partition>
```

Mount the filesystems, then clone the repository into the target system's
configuration directory:

```sh
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount -o umask=077 /dev/disk/by-label/ESP /mnt/boot
mkdir -p /mnt/etc/nixos
nix-shell -p git --run 'git clone https://github.com/zayedabdellah/dotfiles.git /mnt/etc/nixos'
```

Generate hardware configuration for the mounted target, then place it under
the NixOS module directory. Keep this machine-specific file local; review it
before deciding whether to commit it to a public repository.

```sh
nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix \
  /mnt/etc/nixos/nixos/hardware-configuration.nix
cd /mnt/etc/nixos
nix-shell -p git --run 'git -C /mnt/etc/nixos add nixos/hardware-configuration.nix'
```

The local `git add` makes the generated file visible to the Git-backed flake.
It does not commit or push it. The hardware module defines real filesystem
UUIDs and any detected swap device; do not replace it with a generic example.

## 2. Lock dependencies and install

The first run creates `flake.lock`, pinning nixpkgs and Home Manager revisions
for repeatable rebuilds. Keep this lock file with the repository and review
updates deliberately.

```sh
nix --extra-experimental-features 'nix-command flakes' flake lock
nix-shell -p git --run 'git -C /mnt/etc/nixos add flake.lock'
nix --extra-experimental-features 'nix-command flakes' build --dry-run --no-link .#nixosConfigurations.dotfiles.config.system.build.toplevel
nixos-install --flake /mnt/etc/nixos#dotfiles --root /mnt
```

The dry run reports which store paths Nix can fetch and which derivations it
would build locally. If a package derivation that you do not want compiled
appears under “will be built,” stop here; the official cache does not have a
substitute for it. Small system-configuration and Home Manager asset-assembly
derivations may still be built locally even when all package binaries are
fetched.

Set the root password when prompted. Before rebooting, set the desktop user's
password in the installed system:

```sh
nixos-enter --root /mnt -c 'passwd zayed'
```

Then reboot, select the Hyprland session in SDDM, and sign in as `zayed`. The
desktop packages are declared in NixOS `environment.systemPackages`, so
they are available system-wide to users. Home Manager links the repository's
active configuration, Torii wallpaper, Gruvbox GTK and Kvantum themes,
Kitty/Qt/GTK settings, JetBrains Mono fonts, and Bibata cursor into `zayed`'s
home. NixOS enables Qt 5/6 platform and Kvantum styling and the Hyprland
Wayland portal. It provides the Brave command aliases needed by the laptop
profile and the native Qt Pavucontrol application used by Waybar.

## 3. Rebuild after installation

The installed system keeps its generated hardware module in the repository
directory. From the installed system, update the flake lock only when you
intend to move dependency versions, then rebuild:

```sh
cd /etc/nixos
sudo nixos-rebuild switch --flake .#dotfiles
```

For a rollback, choose an earlier generation from the boot menu. The
`zayed-laptop` Hyprland profile is selected automatically. Its monitor rule
matches the repository owner's built-in eDP-1 panel at 2560x1600/165 Hz, scale
2; edit `config/hypr/profiles/zayed-laptop.lua` in `/etc/nixos` if your display
differs, then add the changed file to Git and rebuild. NVIDIA support is
enabled because this profile declares NVIDIA GPU settings.

## Scope and hardware notes

The configuration currently targets `x86_64-linux`, UEFI boot, NetworkManager,
SDDM, Hyprland, NVIDIA graphics, PipeWire, Bluetooth, Power Profiles Daemon,
and Tailscale. The native
NixOS path declares those services and packages; it never authenticates a
Tailscale account. It does not partition disks, enable Secure Boot, configure
disk encryption, or assume a particular swap layout. The generated hardware
module supplies the target's filesystems and hardware-specific settings.

The flake follows the `nixos-unstable` and Home Manager `master` branches.
The first `nix flake lock` pins their exact input revisions in `flake.lock`;
future `nix flake update` commands can move those pins to newer unstable
revisions. The system prefers the official NixOS binary cache and disables
fallback builds when a known substitute cannot be fetched. This does not
guarantee every package has a binary: Nix may still build from source when no
substitute exists for an output. Check the dry-run build plan before installing
if you want to avoid source builds entirely.

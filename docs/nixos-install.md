# Fresh NixOS installation

This repository provides a UEFI/x86_64 NixOS configuration with Hyprland and
Home Manager. The Home Manager profile reuses the existing rice files; it does
not run the imperative `install.sh` installer. The configuration assumes the
username `zayed`, a UEFI system, and a network connection during installation.

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
nixos-install --flake /mnt/etc/nixos#dotfiles --root /mnt
```

Set the root password when prompted. Before rebooting, set the desktop user's
password in the installed system:

```sh
nixos-enter --root /mnt -c 'passwd zayed'
```

Then reboot, select the Hyprland session in SDDM, and sign in as `zayed`. Git
is installed system-wide; Home Manager links the repository's active
configuration, theme, font, and cursor assets into the user's home.

## 3. Rebuild after installation

The installed system keeps its generated hardware module in the repository
directory. From the installed system, update the flake lock only when you
intend to move dependency versions, then rebuild:

```sh
cd /etc/nixos
sudo nixos-rebuild switch --flake .#dotfiles
```

For a rollback, choose an earlier generation from the boot menu. The
`zayed-laptop` Hyprland profile is never selected automatically; use the generic
profile on new hardware, and opt into the laptop profile only on the matching
machine.

## Scope and hardware notes

The configuration currently targets `x86_64-linux`, UEFI boot, NetworkManager,
SDDM, PipeWire, Bluetooth, Power Profiles Daemon, and Tailscale. The native
NixOS path declares those services and packages; it never authenticates a
Tailscale account. It does not partition disks, enable Secure Boot, configure
disk encryption, select a GPU driver, or assume a particular swap layout.
Those choices belong in the generated hardware module and should be reviewed
for the target computer before installation.

The NixOS profile uses `nixos-26.05` and the matching Home Manager release.
The first `nix flake lock` pins the exact input revisions in `flake.lock`.

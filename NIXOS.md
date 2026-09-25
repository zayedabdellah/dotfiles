# Install NixOS from the live ISO

These steps install the repository's `nixos-unstable` flake to `/dev/sda` on a
UEFI x86_64 computer. Packages are declared system-wide; Home Manager applies
the rice configuration to the `zayed` account. The `zayed-laptop` profile is
selected automatically, including its NVIDIA setup and current eDP-1 monitor
profile.

> **Warning:** The partitioning and formatting commands below erase the entire
> `/dev/sda` disk. Confirm it is the intended disk before continuing. Do not
> run the partitioning or formatting commands if the disk already contains data
> you need.

Boot the NixOS minimal ISO, connect to the internet, open a terminal, and run:

```sh
sudo -i
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS
```

If `/dev/sda` is the disk you intend to erase, create a 1 GiB EFI partition and
use the rest of the disk for the ext4 root filesystem:

```sh
parted -s /dev/sda mklabel gpt
parted -s /dev/sda mkpart ESP fat32 1MiB 1025MiB
parted -s /dev/sda set 1 esp on
parted -s /dev/sda mkpart nixos ext4 1025MiB 100%
udevadm settle

mkfs.fat -F 32 -n ESP /dev/sda1
mkfs.ext4 -L nixos /dev/sda2
```

Mount the new filesystems and clone the repository into the target system's
`/etc/nixos` directory (mounted under `/mnt` in the live ISO):

```sh
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount -o umask=077 /dev/disk/by-label/ESP /mnt/boot
mkdir -p /mnt/etc/nixos
nix-shell -p git --run 'git clone https://github.com/zayedabdellah/dotfiles.git /mnt/etc/nixos'
```

Generate hardware settings for this machine, stage them so the Git-backed flake
can read them, then create and stage the lock file:

```sh
nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/nixos/hardware-configuration.nix
nix-shell -p git --run 'git -C /mnt/etc/nixos add nixos/hardware-configuration.nix'

cd /mnt/etc/nixos
nix --extra-experimental-features 'nix-command flakes' flake lock
nix-shell -p git --run 'git -C /mnt/etc/nixos add flake.lock'
```

Check the download/build plan, then install. Nix prefers the official binary
cache; if package derivations you do not want compiled appear under “will be
built,” stop and review the plan before running `nixos-install`.

```sh
nix --extra-experimental-features 'nix-command flakes' build --dry-run --no-link .#nixosConfigurations.dotfiles.config.system.build.toplevel
nixos-install --flake /mnt/etc/nixos#dotfiles --root /mnt
```

Set the `zayed` account password in the installed system and reboot:

```sh
nixos-enter --root /mnt -c 'passwd zayed'
reboot
```

Remove the ISO after shutdown, boot from the installed disk, choose the
Hyprland session in SDDM, and sign in as `zayed`. The installed configuration
will be at `/etc/nixos`.

Nix can still build from source when the cache has no substitute for an
output; preferring the cache cannot guarantee a binary for every package.

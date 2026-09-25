{ lib, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Dubai";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  users.users.zayed = {
    isNormalUser = true;
    description = "Zayed";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.fish;
  };
  programs.fish.enable = true;
  security.sudo.wheelNeedsPassword = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ "https://cache.nixos.org/" ];
    fallback = false;
  };
  nixpkgs.config.allowUnfree = true;

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;
  hardware.bluetooth.enable = true;
  services.power-profiles-daemon.enable = true;
  services.tailscale.enable = true;

  environment.systemPackages = with pkgs; [
    bash
    brightnessctl
    bluez
    blueman
    fastfetch
    coreutils
    curl
    findutils
    gawk
    git
    grim
    gtk3
    gtk4
    hypridle
    hyprlock
    hyprpolkitagent
    jq
    kitty
    libnotify
    networkmanagerapplet
    noto-fonts
    noto-fonts-color-emoji
    nwg-look
    papirus-icon-theme
    playerctl
    polkit
    procps
    power-profiles-daemon
    qt6ct
    qt6Packages.qtwayland
    rofi
    slurp
    swaynotificationcenter
    thunar
    thunar-volman
    tailscale
    tumbler
    unzip
    util-linux
    waybar
    wl-clipboard
    xdg-user-dirs
    xdg-utils
    xsettingsd
    xorg.xrandr
    xorg.xrdb
    xwayland
  ];

  fonts.packages = with pkgs; [ noto-fonts noto-fonts-color-emoji ];
  services.dbus.enable = true;
  programs.dconf.enable = true;

  system.stateVersion = "26.05";
}

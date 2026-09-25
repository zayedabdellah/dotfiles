{ lib, pkgs, ... }:
let
  braveBrowser = pkgs.writeShellScriptBin "brave-browser" ''
    exec ${pkgs.brave}/bin/brave "$@"
  '';
  braveBrowserStable = pkgs.writeShellScriptBin "brave-browser-stable" ''
    exec ${pkgs.brave}/bin/brave "$@"
  '';
in {
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  environment.sessionVariables = {
    DOTFILES_MACHINE_PROFILE = "zayed-laptop";
    DOTFILES_QT_PLATFORMTHEME = "qt5ct";
    DOTFILES_QT_STYLE_OVERRIDE = "kvantum";
  };
  time.timeZone = "Asia/Dubai";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
  };
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
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = false;
  hardware.nvidia.modesetting.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
  };

  qt = {
    enable = true;
    platformTheme = "qt5ct";
    style = "kvantum";
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
    awww
    bc
    btop
    brave
    braveBrowser
    braveBrowserStable
    brightnessctl
    bluez
    blueman
    cava
    fastfetch
    fontconfig
    coreutils
    gnugrep
    gnused
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
    mangohud
    mpv
    networkmanagerapplet
    networkmanager
    noto-fonts
    noto-fonts-color-emoji
    nwg-look
    oh-my-posh
    papirus-icon-theme
    playerctl
    lxqt.pavucontrol-qt
    polkit
    procps
    power-profiles-daemon
    qt6Packages.qt6ct
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

  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono nerd-fonts.symbols-only noto-fonts noto-fonts-color-emoji ];
  services.dbus.enable = true;
  programs.dconf.enable = true;

  system.stateVersion = "26.05";
}

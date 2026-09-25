{ pkgs, ... }:
let
  repo = ../.;
  configTree = pkgs.runCommand "dotfiles-home-config" { } ''
    mkdir -p "$out"
    cp -r ${repo}/config/. "$out/"
    chmod u+w "$out/Kvantum"
    mkdir -p "$out/Kvantum/gruvbox-kvantum"
    cp -r ${repo}/themes/kvantum/gruvbox-kvantum/. "$out/Kvantum/gruvbox-kvantum/"
  '';
in {
  home.username = "zayed";
  home.homeDirectory = "/home/zayed";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  home.file = {
    ".config" = {
      source = configTree;
      recursive = true;
    };
    ".themes/gruvbox-dark-gtk".source = "${repo}/themes/gruvbox-dark-gtk";
    ".themes/torii-zayed.omp.json".source = "${repo}/themes/oh-my-posh/torii-zayed.omp.json";
    ".local/share/fonts".source = "${repo}/fonts/fonts/ttf";
    ".local/share/icons".source = "${repo}/icons";
    ".local/bin/volume-toggle".source = "${repo}/scripts/volume-toggle";
  };

  home.sessionVariables = {
    XCURSOR_THEME = "Bibata-Modern-Amber";
    XCURSOR_SIZE = "24";
  };

  xdg.enable = true;
}

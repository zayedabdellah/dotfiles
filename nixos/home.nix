{ ... }:
let
  repo = ../.;
in {
  home.username = "zayed";
  home.homeDirectory = "/home/zayed";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  home.file = {
    ".config" = {
      source = "${repo}/config";
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
    QT_QPA_PLATFORMTHEME = "qt6ct";
  };

  xdg.enable = true;
}

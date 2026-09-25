# ~/.config/fish/config.fish

if status is-interactive
    set -U fish_color_command ff6a00
    set -U fish_color_error 458588
    set -U fish_color_param e2e2e9
    fastfetch
end

# Keep these global exports
set -gx XDG_CURRENT_DESKTOP Hyprland
set -gx XDG_SESSION_TYPE wayland

# Standard defaults (Native apps look normal)
set -gx QT_AUTO_SCREEN_SCALE_FACTOR 0

set -U fish_greeting ""

fish_add_path ~/go/bin
fish_add_path ~/.local/bin
fish_add_path ~/.cargo/bin
alias dolphin-emu="env QT_SCALE_FACTOR=2 dolphin-emu"
alias ff="fastfetch"

oh-my-posh init fish --config ~/.themes/torii-zayed.omp.json | source

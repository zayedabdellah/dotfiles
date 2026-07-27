#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-installer-test.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT

make_mock_bin() {
    local bin="$1" command_name
    mkdir -p "$bin"
    for command_name in Hyprland hyprland waybar swaync fish kitty rofi hyprlock hypridle \
        awww awww-daemon pipewire wireplumber wpctl hyprpolkitagent thunar mpv btop \
        mangohud cava grim slurp wl-copy brightnessctl playerctl pavucontrol-qt nmtui \
        nmcli blueman-applet powerprofilesctl xrdb notify-send xsettingsd fc-cache ip \
        curl unzip pacman fastfetch gsettings xdg-user-dirs-update; do
        ln -s /bin/true "$bin/$command_name"
    done
    cat > "$bin/sudo" <<'EOF'
#!/bin/sh
printf '%s\n' "sudo $*" >> "$DOTFILES_TEST_LOG"
if [ "${DOTFILES_SUDO_FAIL_TEE:-0}" = 1 ] && [ "$1" = tee ]; then exit 76; fi
exec "$@"
EOF
    chmod +x "$bin/sudo"
    cat > "$bin/getent" <<'EOF'
#!/bin/sh
[ "$1" = passwd ] || exit 2
shell=/bin/bash
[ ! -r "$DOTFILES_ACCOUNT_SHELL" ] || shell=$(cat "$DOTFILES_ACCOUNT_SHELL")
printf '%s:x:1000:1000:Test User:%s:%s\n' "$2" "$HOME" "$shell"
EOF
    cat > "$bin/chsh" <<'EOF'
#!/bin/sh
printf '%s\n' "chsh $*" >> "$DOTFILES_TEST_LOG"
[ "${DOTFILES_CHSH_FAIL:-0}" != 1 ] || exit 72
if [ "${DOTFILES_CHSH_MISMATCH:-0}" != 1 ]; then printf '%s\n' "$2" > "$DOTFILES_ACCOUNT_SHELL"; fi
EOF
    cat > "$bin/systemctl" <<'EOF'
#!/bin/sh
case "$1" in
    is-enabled|is-active)
        [ -e "$DOTFILES_SERVICE_STATE/$2" ]
        ;;
    enable)
        service="${4:-$3}"
        mkdir -p "$DOTFILES_SERVICE_STATE"
        : > "$DOTFILES_SERVICE_STATE/$service"
        printf '%s\n' "systemctl $*" >> "$DOTFILES_TEST_LOG"
        ;;
    *)
        printf '%s\n' "systemctl $*" >> "$DOTFILES_TEST_LOG"
        ;;
esac
EOF
    rm -f "$bin/gsettings" "$bin/xdg-user-dirs-update" "$bin/fastfetch"
    cat > "$bin/gsettings" <<'EOF'
#!/bin/sh
printf '%s\n' "gsettings $*" >> "$DOTFILES_TEST_LOG"
exit 0
EOF
    cat > "$bin/xdg-user-dirs-update" <<'EOF'
#!/bin/sh
printf '%s\n' "xdg-user-dirs-update $*" >> "$DOTFILES_TEST_LOG"
exit 0
EOF
    cat > "$bin/fastfetch" <<'EOF'
#!/bin/sh
printf '%s\n' "fastfetch $*" >> "$DOTFILES_TEST_LOG"
[ "${DOTFILES_FASTFETCH_FAIL:-0}" != 1 ]
EOF
    chmod +x "$bin/getent" "$bin/chsh" "$bin/systemctl" "$bin/gsettings" \
        "$bin/xdg-user-dirs-update" "$bin/fastfetch"
}

make_mock_curl() {
    local bin="$1"
    rm -f "$bin/curl"
    cat > "$bin/curl" <<'EOF'
#!/bin/sh
if [ "${DOTFILES_CURL_FAIL:-0}" = 1 ]; then
    printf '%s\n' "curl $*" >> "$DOTFILES_TEST_LOG"
    exit 77
fi
cat <<'INSTALLER'
#!/bin/bash
destination="$HOME/.local/bin"
while (($# > 0)); do
    if [[ "$1" == "-d" ]]; then destination="$2"; shift 2; else shift; fi
done
mkdir -p "$destination"
printf '%s\n' '#!/bin/sh' 'exit 0' > "$destination/oh-my-posh"
chmod +x "$destination/oh-my-posh"
INSTALLER
EOF
    chmod +x "$bin/curl"
}

make_mock_pacman() {
    local bin="$1"
    rm -f "$bin/pacman"
    cat > "$bin/pacman" <<'EOF'
#!/bin/sh
printf '%s\n' "pacman $*" >> "$DOTFILES_TEST_LOG"
if [ "${DOTFILES_PACMAN_FAIL:-0}" = 1 ]; then exit 77; fi
exit 0
EOF
    chmod +x "$bin/pacman"
}

run_installer() {
    local home="$1" bin="$2"
    shift 2
    mkdir -p "$home"
    if [[ "${DOTFILES_NO_SHELLS_FILE:-0}" != 1 && ! -e "$home/etc-shells" ]]; then
        printf '%s\n' /bin/bash > "$home/etc-shells"
    fi
    [[ -e "$home/account-shell" ]] || printf '%s\n' /bin/bash > "$home/account-shell"
    HOME="$home" \
    PATH="$bin:/usr/bin:/bin" \
    XDG_CONFIG_HOME="$home/.config" \
    DOTFILES_DISTRO_ID=arch \
    DOTFILES_TEST_LOG="$TEST_ROOT/commands.log" \
    DOTFILES_SHELLS_FILE="$home/etc-shells" \
    DOTFILES_ACCOUNT_SHELL="$home/account-shell" \
    DOTFILES_SERVICE_STATE="$home/service-state" \
    bash "$ROOT/install.sh" "$@"
}

assert_no_write_commands() {
    [[ ! -s "$TEST_ROOT/commands.log" ]] || {
        echo "read-only mode invoked a write-capable command:" >&2
        cat "$TEST_ROOT/commands.log" >&2
        return 1
    }
}

readonly_home="$TEST_ROOT/readonly-home"
readonly_bin="$TEST_ROOT/readonly-bin"
mkdir -p "$readonly_home"
make_mock_bin "$readonly_bin"
for command_name in chsh gsettings emerge dnf dnf5; do
    rm -f "$readonly_bin/$command_name"
    cat > "$readonly_bin/$command_name" <<'EOF'
#!/bin/sh
printf '%s\n' "$0 $*" >> "$DOTFILES_TEST_LOG"
exit 99
EOF
    chmod +x "$readonly_bin/$command_name"
done
: > "$TEST_ROOT/commands.log"
run_installer "$readonly_home" "$readonly_bin" --dry-run --profile generic \
    --set-default-shell --apply-desktop-settings --enable-optional dolphin-emu >/dev/null
assert_no_write_commands
[[ ! -e "$readonly_home/.config/hypr/machine.local.lua" ]]

if command -v script >/dev/null 2>&1; then
    menu_output="$(printf '1\n' | HOME="$readonly_home" PATH="$readonly_bin:/usr/bin:/bin" \
        DOTFILES_DISTRO_ID=arch DOTFILES_TEST_LOG="$TEST_ROOT/commands.log" \
        script -qec "bash '$ROOT/install.sh' --dry-run" /dev/null 2>&1)"
    grep -q '1) Generic' <<<"$menu_output"
    grep -q '2) Zayed laptop' <<<"$menu_output"
    grep -q 'Selected machine profile: generic' <<<"$menu_output"
fi
: > "$TEST_ROOT/commands.log"
run_installer "$readonly_home" "$readonly_bin" --audit --profile generic \
    --set-default-shell --apply-desktop-settings >/dev/null
assert_no_write_commands
[[ ! -e "$readonly_home/.config/hypr/machine.local.lua" ]]

full_home="$TEST_ROOT/full-home"
full_bin="$TEST_ROOT/full-bin"
mkdir -p "$full_home"
make_mock_bin "$full_bin"
make_mock_curl "$full_bin"
make_mock_pacman "$full_bin"
: > "$TEST_ROOT/commands.log"
run_installer "$full_home" "$full_bin" --non-interactive --profile generic >/dev/null
grep -q 'pacman .*hyprland' "$TEST_ROOT/commands.log"
grep -q 'xdg-desktop-portal-hyprland' "$TEST_ROOT/commands.log"
grep -q 'fastfetch' "$TEST_ROOT/commands.log"
grep -q 'util-linux' "$TEST_ROOT/commands.log"
[[ -x "$full_home/.local/bin/oh-my-posh" ]]
[[ -f "$full_home/.config/hypr/wallpapers/torii.jpg" ]]
[[ -f "$full_home/.config/fastfetch/config.jsonc" ]]
[[ -f "$full_home/.config/fastfetch/claude.txt" ]]
[[ -f "$full_home/.config/Kvantum/gruvbox-kvantum/gruvbox-kvantum.svg" ]]
[[ -f "$full_home/.config/btop/themes/gruvbox_dark_v2.theme" ]]
[[ -f "$full_home/.themes/torii-zayed.omp.json" ]]
[[ ! -e "$full_home/.themes/gruvbox-kvantum" ]]
grep -Fxq 'style=kvantum' "$full_home/.config/qt6ct/qt6ct.conf"
grep -Fxq 'alias ff="/usr/bin/fastfetch"' "$full_home/.config/fish/config.fish"
[[ "$(grep -Fc fastfetch "$full_home/.config/fish/config.fish")" == 2 ]]
grep -q 'persistent-workspaces.*\[1, 2, 3, 4, 5\]' "$full_home/.config/waybar/config.jsonc"
! grep -q '"interface": "wlp3s0"' "$full_home/.config/waybar/config.jsonc"
grep -q 'profile = "generic"' "$full_home/.config/hypr/machine.local.lua"

if command -v script >/dev/null 2>&1; then
    noarg_home="$TEST_ROOT/noarg-home"
    noarg_bin="$TEST_ROOT/noarg-bin"
    mkdir -p "$noarg_home"
    make_mock_bin "$noarg_bin"
    make_mock_curl "$noarg_bin"
    make_mock_pacman "$noarg_bin"
    printf '%s\n' /bin/bash > "$noarg_home/etc-shells"
    printf '%s\n' /bin/bash > "$noarg_home/account-shell"
    : > "$TEST_ROOT/commands.log"
    noarg_output="$(
        printf '1\n\n\n\ny\n\n' |
            HOME="$noarg_home" PATH="$noarg_bin:/usr/bin:/bin" \
            XDG_CONFIG_HOME="$noarg_home/.config" DOTFILES_DISTRO_ID=arch \
            DOTFILES_TEST_LOG="$TEST_ROOT/commands.log" \
            DOTFILES_SHELLS_FILE="$noarg_home/etc-shells" \
            DOTFILES_ACCOUNT_SHELL="$noarg_home/account-shell" \
            DOTFILES_SERVICE_STATE="$noarg_home/service-state" \
            script -qec "bash '$ROOT/install.sh'" /dev/null 2>&1
    )"
    grep -q "Make Fish the default shell for $(id -un)? \\[Y/n\\]" <<<"$noarg_output"
    grep -q 'Optional module names, separated by spaces' <<<"$noarg_output"
    grep -q 'Enable required system services' <<<"$noarg_output"
    grep -q 'Final installation checklist' <<<"$noarg_output"
    grep -q 'Log out and back in, or reboot' <<<"$noarg_output"
    grep -q 'Remaining manual steps' <<<"$noarg_output"
    grep -q '  None.' <<<"$noarg_output"
    grep -q 'gsettings set org.gnome.desktop.interface gtk-theme gruvbox-dark-gtk' "$TEST_ROOT/commands.log"
    grep -q 'xdg-user-dirs-update' "$TEST_ROOT/commands.log"
    grep -q 'systemctl enable --now NetworkManager.service' "$TEST_ROOT/commands.log"
    grep -q "chsh -s $noarg_bin/fish $(id -un)" "$TEST_ROOT/commands.log"
    grep -Fxq "$noarg_bin/fish" "$noarg_home/etc-shells"
    [[ "$(grep -Fxc "$noarg_bin/fish" "$noarg_home/etc-shells")" == 1 ]]
    [[ "$(cat "$noarg_home/account-shell")" == "$noarg_bin/fish" ]]
    [[ -f "$noarg_home/.config/fastfetch/config.jsonc" ]]
    [[ -f "$noarg_home/.themes/torii-zayed.omp.json" ]]
    [[ -f "$noarg_home/.config/Kvantum/gruvbox-kvantum/gruvbox-kvantum.svg" ]]

    decline_home="$TEST_ROOT/decline-home"
    decline_bin="$TEST_ROOT/decline-bin"
    mkdir -p "$decline_home"
    make_mock_bin "$decline_bin"
    make_mock_curl "$decline_bin"
    make_mock_pacman "$decline_bin"
    printf '%s\n' /bin/bash > "$decline_home/etc-shells"
    printf '%s\n' /bin/bash > "$decline_home/account-shell"
    : > "$TEST_ROOT/commands.log"
    printf '1\n\nn\nn\ny\n' |
        HOME="$decline_home" PATH="$decline_bin:/usr/bin:/bin" \
        XDG_CONFIG_HOME="$decline_home/.config" DOTFILES_DISTRO_ID=arch \
        DOTFILES_TEST_LOG="$TEST_ROOT/commands.log" \
        DOTFILES_SHELLS_FILE="$decline_home/etc-shells" \
        DOTFILES_ACCOUNT_SHELL="$decline_home/account-shell" \
        DOTFILES_SERVICE_STATE="$decline_home/service-state" \
        script -qec "bash '$ROOT/install.sh'" /dev/null >/dev/null 2>&1
    [[ "$(cat "$decline_home/account-shell")" == /bin/bash ]]
    ! grep -q '^chsh ' "$TEST_ROOT/commands.log"
    ! grep -q 'systemctl enable' "$TEST_ROOT/commands.log"
fi

rm -f "$full_bin/awww"
cat > "$full_bin/awww" <<'EOF'
#!/bin/sh
if [ "$1" = query ]; then
    count=0
    [ ! -r "$DOTFILES_AWWW_COUNT" ] || count=$(cat "$DOTFILES_AWWW_COUNT")
    count=$((count + 1))
    printf '%s\n' "$count" > "$DOTFILES_AWWW_COUNT"
    [ "$count" -ge "${DOTFILES_AWWW_READY_AFTER:-1}" ]
    exit
fi
if [ "$1" = img ]; then
    printf '%s\n' "$*" >> "$DOTFILES_WALLPAPER_LOG"
    [ "${DOTFILES_AWWW_IMG_FAIL:-0}" != 1 ]
    exit
fi
exit 2
EOF
chmod +x "$full_bin/awww"
rm -f "$full_bin/awww-daemon"
cat > "$full_bin/awww-daemon" <<'EOF'
#!/bin/sh
printf '%s\n' "daemon $*" >> "$DOTFILES_WALLPAPER_LOG"
EOF
chmod +x "$full_bin/awww-daemon"
rm -f "$full_bin/sleep"
ln -s /bin/true "$full_bin/sleep"
: > "$TEST_ROOT/wallpaper.log"
for wallpaper_profile in generic zayed-laptop; do
    count_file="$TEST_ROOT/awww-$wallpaper_profile.count"
    HOME="$full_home" PATH="$full_bin:/usr/bin:/bin" \
        DOTFILES_MACHINE_PROFILE="$wallpaper_profile" DOTFILES_WALLPAPER_LOG="$TEST_ROOT/wallpaper.log" \
        DOTFILES_AWWW_COUNT="$count_file" DOTFILES_AWWW_READY_AFTER=3 \
        bash "$full_home/.config/hypr/scripts/wallpaper.sh"
done
grep -q 'torii.jpg' "$TEST_ROOT/wallpaper.log"
[[ "$(grep -c '^daemon ' "$TEST_ROOT/wallpaper.log")" == 2 ]]
! rg -n 'awww-daemon' "$full_home/.config/hypr/modules" "$full_home/.config/hypr/profiles"

never_ready_error="$TEST_ROOT/never-ready.err"
if HOME="$full_home" PATH="$full_bin:/usr/bin:/bin" \
    DOTFILES_WALLPAPER_LOG="$TEST_ROOT/wallpaper.log" \
    DOTFILES_AWWW_COUNT="$TEST_ROOT/never-ready.count" DOTFILES_AWWW_READY_AFTER=999 \
    bash "$full_home/.config/hypr/scripts/wallpaper.sh" 2>"$never_ready_error"; then
    echo "wallpaper daemon readiness failure unexpectedly succeeded" >&2
    exit 1
fi
grep -q 'did not become ready within 10 seconds' "$never_ready_error"

img_error="$TEST_ROOT/img-failure.err"
if HOME="$full_home" PATH="$full_bin:/usr/bin:/bin" \
    DOTFILES_WALLPAPER_LOG="$TEST_ROOT/wallpaper.log" \
    DOTFILES_AWWW_COUNT="$TEST_ROOT/img-failure.count" DOTFILES_AWWW_READY_AFTER=1 \
    DOTFILES_AWWW_IMG_FAIL=1 \
    bash "$full_home/.config/hypr/scripts/wallpaper.sh" 2>"$img_error"; then
    echo "wallpaper image failure unexpectedly succeeded" >&2
    exit 1
fi
grep -q 'failed to apply Torii wallpaper' "$img_error"

missing_command_error="$TEST_ROOT/missing-awww.err"
if HOME="$full_home" PATH="$TEST_ROOT/empty-path" \
    /usr/bin/bash "$full_home/.config/hypr/scripts/wallpaper.sh" 2>"$missing_command_error"; then
    echo "missing awww unexpectedly succeeded" >&2
    exit 1
fi
grep -q 'awww client is unavailable' "$missing_command_error"
client_only_bin="$TEST_ROOT/client-only-bin"
mkdir -p "$client_only_bin"
ln -s "$full_bin/awww" "$client_only_bin/awww"
if HOME="$full_home" PATH="$client_only_bin" \
    DOTFILES_AWWW_COUNT="$TEST_ROOT/client-only.count" \
    /usr/bin/bash "$full_home/.config/hypr/scripts/wallpaper.sh" 2>"$TEST_ROOT/missing-daemon.err"; then
    echo "missing awww-daemon unexpectedly succeeded" >&2
    exit 1
fi
grep -q 'awww-daemon is unavailable' "$TEST_ROOT/missing-daemon.err"

wallpaper_path="$full_home/.config/hypr/wallpapers/torii.jpg"
mv "$wallpaper_path" "$wallpaper_path.missing"
HOME="$full_home" PATH="$TEST_ROOT/empty-path" \
    /usr/bin/bash "$full_home/.config/hypr/scripts/wallpaper.sh" >/dev/null 2>&1
mv "$wallpaper_path.missing" "$wallpaper_path"

rm -f "$full_bin/hyprlock"
cat > "$full_bin/hyprlock" <<'EOF'
#!/bin/sh
config=""
while [ "$#" -gt 0 ]; do
    if [ "$1" = --config ]; then config="$2"; shift 2; else shift; fi
done
grep -q 'path = .*torii.jpg' "$config" || exit 1
EOF
chmod +x "$full_bin/hyprlock"
runtime_dir="$TEST_ROOT/hyprlock-runtime"
mkdir -p "$runtime_dir"
for lock_profile in generic zayed-laptop; do
    HOME="$full_home" XDG_RUNTIME_DIR="$runtime_dir" PATH="$full_bin:/usr/bin:/bin" \
        DOTFILES_MACHINE_PROFILE="$lock_profile" bash "$full_home/.config/hypr/scripts/hyprlock.sh"
done
chmod 000 "$wallpaper_path"
if HOME="$full_home" XDG_RUNTIME_DIR="$runtime_dir" PATH="$full_bin:/usr/bin:/bin" \
    bash "$full_home/.config/hypr/scripts/hyprlock.sh" 2>"$TEST_ROOT/unreadable-wallpaper.err"; then
    echo "unreadable Torii wallpaper unexpectedly used a fallback" >&2
    exit 1
fi
chmod 644 "$wallpaper_path"
grep -q 'exists but is unreadable' "$TEST_ROOT/unreadable-wallpaper.err"
mv "$wallpaper_path" "$wallpaper_path.missing"
sed -i 's/path = .*torii.jpg/path = screenshot/' "$full_bin/hyprlock"
HOME="$full_home" XDG_RUNTIME_DIR="$runtime_dir" PATH="$full_bin:/usr/bin:/bin" \
    DOTFILES_MACHINE_PROFILE=generic bash "$full_home/.config/hypr/scripts/hyprlock.sh" >/dev/null 2>&1
mv "$wallpaper_path.missing" "$wallpaper_path"

zayed_home="$TEST_ROOT/zayed-home"
mkdir -p "$zayed_home"
run_installer "$zayed_home" "$full_bin" --non-interactive --profile zayed-laptop >/dev/null
grep -q 'profile = "zayed-laptop"' "$zayed_home/.config/hypr/machine.local.lua"
grep -q 'wlp3s0' "$zayed_home/.config/waybar/profiles/zayed-laptop.json"
grep -q '"interface": "wlp3s0"' "$zayed_home/.config/waybar/config.jsonc"
grep -q 'output = "eDP-1"' "$zayed_home/.config/hypr/profiles/zayed-laptop.lua"
grep -q 'mode = "2560x1600@165"' "$zayed_home/.config/hypr/profiles/zayed-laptop.lua"
grep -q 'scale = 2' "$zayed_home/.config/hypr/profiles/zayed-laptop.lua"
! grep -q 'zayed-laptop' "$ROOT/config/hypr/scripts/hyprlock.sh" || true

failure_home="$TEST_ROOT/failure-home"
failure_bin="$TEST_ROOT/failure-bin"
mkdir -p "$failure_home"
make_mock_bin "$failure_bin"
make_mock_curl "$failure_bin"
make_mock_pacman "$failure_bin"
: > "$TEST_ROOT/commands.log"
if DOTFILES_PACMAN_FAIL=1 run_installer "$failure_home" "$failure_bin" --non-interactive --profile generic >/dev/null 2>&1; then
    echo "mandatory package failure unexpectedly succeeded" >&2
    exit 1
fi
[[ ! -e "$failure_home/.config/hypr/hyprland.lua" ]]

packages_only_home="$TEST_ROOT/packages-only-home"
mkdir -p "$packages_only_home"
: > "$TEST_ROOT/commands.log"
run_installer "$packages_only_home" "$full_bin" --non-interactive --profile generic --packages-only >/dev/null
[[ ! -e "$packages_only_home/.config/hypr/hyprland.lua" ]]
[[ ! -e "$packages_only_home/.local/bin/oh-my-posh" ]]
[[ ! -e "$packages_only_home/.config/fastfetch/config.jsonc" ]]
! grep -q '^chsh ' "$TEST_ROOT/commands.log"

config_only_home="$TEST_ROOT/config-only-home"
mkdir -p "$config_only_home"
: > "$TEST_ROOT/commands.log"
run_installer "$config_only_home" "$full_bin" --non-interactive --profile generic --config-only >/dev/null
[[ -f "$config_only_home/.config/fastfetch/config.jsonc" ]]
! grep -q '^chsh ' "$TEST_ROOT/commands.log"

shell_home="$TEST_ROOT/shell-home"
mkdir -p "$shell_home"
: > "$TEST_ROOT/commands.log"
USER=root LOGNAME=misleading SUDO_USER=root \
    run_installer "$shell_home" "$full_bin" --non-interactive --profile generic \
    --config-only --set-default-shell >/dev/null
target_user="$(id -un)"
grep -q "chsh -s $full_bin/fish $target_user" "$TEST_ROOT/commands.log"
! grep -q 'chsh .* root$' "$TEST_ROOT/commands.log"
grep -Fxq "$full_bin/fish" "$shell_home/etc-shells"
[[ "$(cat "$shell_home/account-shell")" == "$full_bin/fish" ]]
chsh_count="$(grep -c '^chsh ' "$TEST_ROOT/commands.log")"
run_installer "$shell_home" "$full_bin" --non-interactive --profile generic \
    --config-only --set-default-shell >/dev/null
[[ "$(grep -c '^chsh ' "$TEST_ROOT/commands.log")" == "$chsh_count" ]]
[[ "$(grep -Fxc "$full_bin/fish" "$shell_home/etc-shells")" == 1 ]]

shell_fail_home="$TEST_ROOT/shell-fail-home"
mkdir -p "$shell_fail_home"
if DOTFILES_CHSH_FAIL=1 run_installer "$shell_fail_home" "$full_bin" \
    --non-interactive --profile generic --config-only --set-default-shell \
    >"$TEST_ROOT/chsh-fail.out" 2>&1; then
    echo "chsh failure unexpectedly succeeded" >&2
    exit 1
fi
grep -q 'chsh failed' "$TEST_ROOT/chsh-fail.out"

shell_mismatch_home="$TEST_ROOT/shell-mismatch-home"
mkdir -p "$shell_mismatch_home"
if DOTFILES_CHSH_MISMATCH=1 run_installer "$shell_mismatch_home" "$full_bin" \
    --non-interactive --profile generic --config-only --set-default-shell \
    >"$TEST_ROOT/chsh-mismatch.out" 2>&1; then
    echo "post-change shell mismatch unexpectedly succeeded" >&2
    exit 1
fi
grep -q 'Login-shell verification failed' "$TEST_ROOT/chsh-mismatch.out"

shell_append_home="$TEST_ROOT/shell-append-home"
mkdir -p "$shell_append_home"
if DOTFILES_SUDO_FAIL_TEE=1 run_installer "$shell_append_home" "$full_bin" \
    --non-interactive --profile generic --config-only --set-default-shell \
    >"$TEST_ROOT/shell-append.out" 2>&1; then
    echo "/etc/shells append failure unexpectedly succeeded" >&2
    exit 1
fi
grep -q 'Failed to add .*etc-shells' "$TEST_ROOT/shell-append.out"

shells_missing_home="$TEST_ROOT/shells-missing-home"
mkdir -p "$shells_missing_home"
if DOTFILES_NO_SHELLS_FILE=1 run_installer "$shells_missing_home" "$full_bin" \
    --non-interactive --profile generic --config-only --set-default-shell \
    >"$TEST_ROOT/shells-missing.out" 2>&1; then
    echo "missing shells file unexpectedly succeeded" >&2
    exit 1
fi
grep -q 'is missing or unreadable' "$TEST_ROOT/shells-missing.out"

for missing_shell_command in fish chsh; do
    isolated_bin="$TEST_ROOT/missing-$missing_shell_command-bin"
    isolated_home="$TEST_ROOT/missing-$missing_shell_command-home"
    make_mock_bin "$isolated_bin"
    rm -f "$isolated_bin/$missing_shell_command"
    for utility in dirname id grep find sort jq awk sed mktemp mkdir cp cmp date tee; do
        [[ -e "$isolated_bin/$utility" ]] || ln -s "$(command -v "$utility")" "$isolated_bin/$utility"
    done
    mkdir -p "$isolated_home"
    if HOME="$isolated_home" PATH="$isolated_bin" XDG_CONFIG_HOME="$isolated_home/.config" \
        DOTFILES_DISTRO_ID=arch DOTFILES_TEST_LOG="$TEST_ROOT/commands.log" \
        DOTFILES_SHELLS_FILE="$isolated_home/etc-shells" \
        /usr/bin/bash "$ROOT/install.sh" --non-interactive --profile generic \
        --config-only --set-default-shell >"$TEST_ROOT/missing-$missing_shell_command.out" 2>&1; then
        echo "missing $missing_shell_command unexpectedly succeeded" >&2
        exit 1
    fi
    grep -qi "$missing_shell_command" "$TEST_ROOT/missing-$missing_shell_command.out"
done

repeat_home="$TEST_ROOT/repeat-home"
mkdir -p "$repeat_home"
run_installer "$repeat_home" "$full_bin" --non-interactive --profile generic >/dev/null
printf '%s\n' 'user change' >> "$repeat_home/.config/kitty/kitty.conf"
printf '%s\n' 'changed Fastfetch config' > "$repeat_home/.config/fastfetch/config.jsonc"
printf '%s\n' 'changed Fastfetch logo' > "$repeat_home/.config/fastfetch/claude.txt"
printf '%s\n' 'changed prompt theme' > "$repeat_home/.themes/torii-zayed.omp.json"
printf '%s\n' 'changed wallpaper' > "$repeat_home/.config/hypr/wallpapers/torii.jpg"
printf '%s\n' 'changed Kvantum config' > "$repeat_home/.config/Kvantum/gruvbox-kvantum/gruvbox-kvantum.kvconfig"
run_installer "$repeat_home" "$full_bin" --non-interactive --profile generic >/dev/null
backup_count="$(find "$repeat_home/.local/state/dotfiles/backups" -name manifest.tsv -type f 2>/dev/null | wc -l)"
(( backup_count >= 1 ))
backup_manifest="$(find "$repeat_home/.local/state/dotfiles/backups" -name manifest.tsv -type f | sort | tail -1)"
grep -q '/.config/fastfetch/config.jsonc' "$backup_manifest"
grep -q '/.config/fastfetch/claude.txt' "$backup_manifest"
grep -q '/.themes/torii-zayed.omp.json' "$backup_manifest"
grep -q '/.config/hypr/wallpapers/torii.jpg' "$backup_manifest"
grep -q '/.config/Kvantum/gruvbox-kvantum/gruvbox-kvantum.kvconfig' "$backup_manifest"
backup_count_before_repeat="$(find "$repeat_home/.local/state/dotfiles/backups" -name manifest.tsv -type f | wc -l)"
run_installer "$repeat_home" "$full_bin" --non-interactive --profile generic >/dev/null
backup_count_after_repeat="$(find "$repeat_home/.local/state/dotfiles/backups" -name manifest.tsv -type f | wc -l)"
[[ "$backup_count_before_repeat" == "$backup_count_after_repeat" ]]

kvantum_home="$TEST_ROOT/kvantum-home"
mkdir -p "$kvantum_home/.config/Kvantum"
cat > "$kvantum_home/.config/Kvantum/kvantum.kvconfig" <<'EOF'
[General]
theme=old-theme

[Applications]
KeepThis=example-app
EOF
run_installer "$kvantum_home" "$full_bin" --non-interactive --profile generic --config-only >/dev/null
grep -Fxq 'theme=gruvbox-kvantum' "$kvantum_home/.config/Kvantum/kvantum.kvconfig"
grep -Fxq 'KeepThis=example-app' "$kvantum_home/.config/Kvantum/kvantum.kvconfig"
kvantum_files="$(find "$kvantum_home/.config/Kvantum/gruvbox-kvantum" -maxdepth 1 -type f -printf '%f\n' | sort)"
[[ "$kvantum_files" == $'gruvbox-kvantum.kvconfig\ngruvbox-kvantum.svg' ]]
[[ ! -e "$kvantum_home/.themes/gruvbox-kvantum" ]]
grep -Fxq 'style=kvantum' "$kvantum_home/.config/qt6ct/qt6ct.conf"
grep -Fq '[fastfetch]=app-misc/fastfetch' "$ROOT/install.sh"
grep -Fq '[fastfetch]=fastfetch' "$ROOT/install.sh"
grep -Fq '[chsh]=util-linux' "$ROOT/install.sh"

cmp "$full_home/.config/fastfetch/config.jsonc" "$zayed_home/.config/fastfetch/config.jsonc"
cmp "$full_home/.config/fastfetch/claude.txt" "$zayed_home/.config/fastfetch/claude.txt"
cmp "$full_home/.config/Kvantum/gruvbox-kvantum/gruvbox-kvantum.kvconfig" \
    "$zayed_home/.config/Kvantum/gruvbox-kvantum/gruvbox-kvantum.kvconfig"
cmp "$full_home/.config/Kvantum/gruvbox-kvantum/gruvbox-kvantum.svg" \
    "$zayed_home/.config/Kvantum/gruvbox-kvantum/gruvbox-kvantum.svg"

invalid_fastfetch="$TEST_ROOT/invalid-fastfetch.jsonc"
printf '%s\n' '{ invalid' > "$invalid_fastfetch"
if jq empty "$invalid_fastfetch" >/dev/null 2>&1; then
    echo "invalid Fastfetch JSON unexpectedly parsed" >&2
    exit 1
fi
jq empty "$ROOT/config/fastfetch/config.jsonc"
logo_source="$(jq -r '.logo.source' "$ROOT/config/fastfetch/config.jsonc")"
[[ "$logo_source" == '~/.config/fastfetch/claude.txt' ]]
resolved_logo="$full_home/${logo_source#\~/}"
[[ -r "$resolved_logo" ]]
chmod 000 "$resolved_logo"
if [[ -r "$resolved_logo" ]]; then
    echo "unreadable Fastfetch logo unexpectedly validated" >&2
    exit 1
fi
chmod 644 "$resolved_logo"
mv "$resolved_logo" "$resolved_logo.missing"
if [[ -r "$full_home/${logo_source#\~/}" ]]; then
    echo "missing Fastfetch logo unexpectedly validated" >&2
    exit 1
fi
mv "$resolved_logo.missing" "$resolved_logo"
! rg -n '/home/zayed|torii-fastfetch|password|token|api[_-]?key|private[_-]?key|"type"[[:space:]]*:[[:space:]]*"Command"' \
    "$ROOT/config/fastfetch" "$ROOT/themes/oh-my-posh/torii-zayed.omp.json"
grep -Fq '<transparent,background>\ue0b0</>' "$ROOT/themes/oh-my-posh/torii-zayed.omp.json"
[[ "$(find "$ROOT/themes/oh-my-posh" -maxdepth 1 -name '*.bk' -type f | wc -l)" == 0 ]]
[[ ! -d "$ROOT/themes/oh-my-posh/oh-my-posh" ]]
grep -q 'OH_MY_POSH_VERSION:-v29.31.1' "$ROOT/install.sh"
find "$ROOT/fonts/fonts/ttf" -maxdepth 1 -name '*NerdFont*.ttf' -print -quit | grep -q .
fish -n "$ROOT/config/fish/config.fish"
awk '
    /^if status is-interactive$/ { interactive = 1; next }
    interactive && /^end$/ { exit found ? 0 : 1 }
    interactive && /^[[:space:]]*fastfetch$/ { found++ }
    END { if (!found) exit 1 }
' "$ROOT/config/fish/config.fish"

for waybar_config in "$full_home/.config/waybar/config.jsonc" "$zayed_home/.config/waybar/config.jsonc"; do
    grep -q 'persistent-workspaces.*\[1, 2, 3, 4, 5\]' "$waybar_config"
    grep -Fq '"on-click": "hyprctl dispatch workspace {name}"' "$waybar_config"
    grep -Fq '"modules-left": ["hyprland/workspaces", "hyprland/window", "power-profiles-daemon", "tray"]' "$waybar_config"
    [[ "$(grep -Fc '"hyprland/window"' "$waybar_config")" == 2 ]]
done
! grep -q '"interface": "wlp3s0"' "$full_home/.config/waybar/config.jsonc"
grep -q '"interface": "wlp3s0"' "$zayed_home/.config/waybar/config.jsonc"
grep -Fq '"modules-center": ["custom/media"]' "$full_home/.config/waybar/config-top.jsonc"
grep -Fq '"on-click-right": "kitty -e cava"' "$full_home/.config/waybar/config-top.jsonc"
cmp "$ROOT/config/waybar/style.css" "$full_home/.config/waybar/style.css"

echo "installer safety/full-install/profile/idempotence tests: OK"

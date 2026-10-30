-- Neovim uses its native Wayland provider through wl-clipboard locally.
-- On an SSH session, force the built-in OSC 52 provider so local Wayland
-- environment variables or forwarded sockets cannot shadow the terminal.
if vim.env.SSH_TTY or vim.env.SSH_CONNECTION or vim.env.SSH_CLIENT then
    vim.g.clipboard = "osc52"
end

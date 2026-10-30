local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local output = vim.fn.system({
        "git", "clone", "--filter=blob:none", "--branch=stable",
        "https://github.com/folke/lazy.nvim.git", lazypath,
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Could not bootstrap lazy.nvim. Check network access and Git.\n", "ErrorMsg" },
            { output, "WarningMsg" },
        }, true, {})
        return
    end
end

vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
    spec = { { import = "plugins" } },
    lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json",
    defaults = { lazy = true, version = false },
    install = { colorscheme = { "inari", "habamax" } },
    checker = { enabled = false },
    change_detection = { notify = false },
    performance = {
        rtp = { disabled_plugins = { "gzip", "matchit", "matchparen", "tarPlugin", "tohtml", "tutor", "zipPlugin" } },
    },
    ui = {
        border = "single",
        icons = { cmd = "⌘", config = "⚙", event = "◉", ft = "", init = "⚡", keys = "", plugin = "", runtime = "", source = "", start = "", task = "✔", lazy = "󰒲" },
    },
})

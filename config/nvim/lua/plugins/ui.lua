return {
    {
        "nvim-tree/nvim-web-devicons",
        lazy = true,
        opts = { default = true },
    },
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = function()
            local p = require("config.theme").palette
            local theme = {
                normal = {
                    a = { fg = p.bg, bg = p.accent, gui = "bold" },
                    b = { fg = p.fg, bg = p.black },
                    c = { fg = p.white, bg = p.bg },
                },
                insert = { a = { fg = p.bg, bg = p.green_bright, gui = "bold" } },
                visual = { a = { fg = p.bg, bg = p.magenta_bright, gui = "bold" } },
                replace = { a = { fg = p.bg, bg = p.red_bright, gui = "bold" } },
                command = { a = { fg = p.bg, bg = p.yellow_bright, gui = "bold" } },
                inactive = {
                    a = { fg = p.white, bg = p.bg },
                    b = { fg = p.white, bg = p.bg },
                    c = { fg = p.grey, bg = p.bg },
                },
            }
            return {
                options = {
                    theme = theme,
                    globalstatus = true,
                    section_separators = { left = "", right = "" },
                    component_separators = { left = "│", right = "│" },
                    disabled_filetypes = { statusline = { "alpha", "dashboard" } },
                },
                sections = {
                    lualine_a = { { "mode", fmt = function(mode) return " " .. mode .. " " end } },
                    lualine_b = {
                        { "branch", icon = "" },
                        { "diff", symbols = { added = "+", modified = "~", removed = "-" } },
                        { "diagnostics", sources = { "nvim_diagnostic" }, sections = { "error", "warn", "info", "hint" }, symbols = { error = "E ", warn = "W ", info = "I ", hint = "H " }, colored = true },
                    },
                    lualine_c = { { "filename", path = 1, symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" } } },
                    lualine_x = { "encoding", "fileformat", { "filetype", icon = { align = "left" } } },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
                extensions = { "quickfix" },
            }
        end,
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            delay = 350,
            preset = "helix",
            spec = {
                { "<leader>f", group = "Find" },
                { "<leader>b", group = "Buffers" },
                { "<leader>c", group = "Code" },
                { "<leader>r", group = "Refactor" },
                { "<leader>s", group = "Save" },
                { "w", desc = "Move to previous word" },
                { "b", desc = "Move to next word" },
                { "r", desc = "Redo change" },
            },
            win = { border = "single" },
        },
    },
}

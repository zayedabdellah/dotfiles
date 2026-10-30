return {
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre", "BufReadPre", "BufNewFile" },
        cmd = { "ConformInfo" },
        opts = {
            formatters_by_ft = {
                lua = { "stylua" },
                c = { "clang_format" },
                cpp = { "clang_format" },
                python = { "ruff_format" },
                javascript = { "prettier" },
                javascriptreact = { "prettier" },
                typescript = { "prettier" },
                typescriptreact = { "prettier" },
                json = { "prettier" },
                jsonc = { "prettier" },
                html = { "prettier" },
                css = { "prettier" },
                scss = { "prettier" },
                yaml = { "prettier" },
                markdown = { "prettier" },
                sh = { "shfmt" },
                bash = { "shfmt" },
                fish = { "fish_indent" },
                rust = { "rustfmt" },
            },
            format_on_save = function(bufnr)
                if #require("conform").list_formatters(bufnr) == 0 then return nil end
                return { timeout_ms = 1800, lsp_format = "never" }
            end,
            default_format_opts = { lsp_format = "never" },
            notify_on_error = true,
        },
    },
}

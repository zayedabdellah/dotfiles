local languages = {
    "bash", "c", "cpp", "css", "diff", "fish", "gitcommit", "html", "javascript",
    "json", "lua", "markdown", "markdown_inline", "python", "rust", "sql", "toml",
    "tsx", "typescript", "vim", "vimdoc", "yaml",
}

return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        dependencies = { "neovim-treesitter/treesitter-parser-registry" },
        config = function()
            local ts = require("nvim-treesitter")
            vim.api.nvim_create_user_command("TSInstallRecommended", function()
                ts.install(languages)
            end, { desc = "Install the recommended Treesitter parsers" })
            local group = vim.api.nvim_create_augroup("InariTreesitter", { clear = true })
            vim.api.nvim_create_autocmd("FileType", {
                group = group,
                callback = function()
                    local ok = pcall(vim.treesitter.start)
                    if ok then
                        vim.wo.foldmethod = "expr"
                        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
                        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
                desc = "Enable Treesitter highlighting and folds when a parser is installed",
            })
        end,
    },
}

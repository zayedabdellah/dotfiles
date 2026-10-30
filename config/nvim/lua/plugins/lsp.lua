return {
    {
        "mason-org/mason.nvim",
        lazy = false,
        opts = {
            PATH = "prepend",
            ui = {
                border = "single",
                icons = { package_installed = "✓", package_pending = "◌", package_uninstalled = "×" },
            },
        },
    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            {
                "mason-org/mason-lspconfig.nvim",
                opts = { ensure_installed = {}, automatic_enable = true },
            },
        },
        config = function()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            local servers = {
                "lua_ls", "clangd", "pyright", "rust_analyzer", "ts_ls", "html",
                "cssls", "jsonls", "bashls", "fish_lsp",
            }
            for _, server in ipairs(servers) do
                vim.lsp.config(server, { capabilities = capabilities })
            end
            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT" },
                        diagnostics = { globals = { "vim" } },
                        workspace = { checkThirdParty = false },
                    },
                },
            })
            vim.lsp.enable(servers)

            vim.diagnostic.config({
                underline = true,
                virtual_text = { spacing = 2, source = "if_many", prefix = "●" },
                signs = true,
                severity_sort = true,
                update_in_insert = false,
                float = { border = "single", source = "if_many", header = "", prefix = "" },
            })

            local group = vim.api.nvim_create_augroup("InariLsp", { clear = true })
            vim.api.nvim_create_autocmd("LspAttach", {
                group = group,
                callback = function(event)
                    local buf = event.buf
                    local mapopts = { buffer = buf, silent = true }
                    vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", mapopts, { desc = "Go to definition" }))
                    vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", mapopts, { desc = "Find references" }))
                    vim.keymap.set("n", "K", function() vim.lsp.buf.hover({ border = "single" }) end,
                        vim.tbl_extend("force", mapopts, { desc = "Hover documentation" }))
                    vim.keymap.set("n", "<C-k>", function() vim.lsp.buf.signature_help({ border = "single" }) end,
                        vim.tbl_extend("force", mapopts, { desc = "Signature help" }))
                    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", mapopts, { desc = "Code action" }))
                    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", mapopts, { desc = "Rename symbol" }))
                end,
                desc = "Set buffer-local LSP keybindings",
            })
        end,
    },
}

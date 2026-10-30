local group = vim.api.nvim_create_augroup("InariConfig", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
    group = group,
    callback = function() vim.hl.on_yank({ higroup = "IncSearch", timeout = 180 }) end,
    desc = "Briefly highlight yanked text",
})

vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "lua", "vim", "vimdoc", "json", "jsonc", "javascript", "typescript", "typescriptreact", "html", "css", "yaml", "markdown" },
    callback = function(event)
        local two_space = { lua = true, vim = true, vimdoc = true, json = true, jsonc = true,
            javascript = true, typescript = true, typescriptreact = true, html = true, css = true,
            yaml = true, markdown = true }
        if two_space[vim.bo[event.buf].filetype] then
            vim.bo[event.buf].expandtab = true
            vim.bo[event.buf].shiftwidth = 2
            vim.bo[event.buf].tabstop = 2
            vim.bo[event.buf].softtabstop = 2
        end
    end,
    desc = "Apply common filetype indentation",
})

vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "c", "cpp", "rust", "python", "sh", "bash", "fish" },
    callback = function(event)
        vim.bo[event.buf].expandtab = true
        vim.bo[event.buf].shiftwidth = 4
        vim.bo[event.buf].tabstop = 4
        vim.bo[event.buf].softtabstop = 4
    end,
    desc = "Use four-space indentation for systems and scripting languages",
})

vim.api.nvim_create_autocmd("BufWinEnter", {
    group = group,
    callback = function(event)
        if vim.bo[event.buf].buftype == "" and vim.api.nvim_buf_get_name(event.buf) ~= "" then
            pcall(vim.cmd, "silent! loadview")
        end
    end,
    desc = "Restore saved cursor and fold view",
})

vim.api.nvim_create_autocmd("BufWinLeave", {
    group = group,
    callback = function(event)
        if vim.bo[event.buf].buftype == "" and vim.api.nvim_buf_get_name(event.buf) ~= "" then
            pcall(vim.cmd, "silent! mkview")
        end
    end,
    desc = "Save cursor and fold view",
})

vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "help",
    callback = function(event)
        vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true, desc = "Close help" })
    end,
    desc = "Make help windows easy to close",
})

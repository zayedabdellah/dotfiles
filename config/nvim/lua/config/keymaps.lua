local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Keep the familiar keys, while reversing the two basic word motions in
-- Normal and Visual mode. Operator-pending mode deliberately keeps native
-- w/b so commands such as dw, cw, and db retain their standard meanings.
map({ "n", "x" }, "w", "b", vim.tbl_extend("force", opts, { desc = "Move to previous word" }))
map({ "n", "x" }, "b", "w", vim.tbl_extend("force", opts, { desc = "Move to next word" }))

-- r is intentionally repurposed as redo. Ctrl-r remains native redo too.
map("n", "r", "<C-r>", vim.tbl_extend("force", opts, { desc = "Redo change" }))

map("n", "<Esc>", "<cmd>nohlsearch<CR>", vim.tbl_extend("force", opts, { desc = "Clear search highlight" }))
map("n", "<leader>e", "<cmd>Explore<CR>", vim.tbl_extend("force", opts, { desc = "Open netrw file explorer" }))
map("n", "<leader>bd", "<cmd>confirm bdelete<CR>", vim.tbl_extend("force", opts, { desc = "Close buffer (confirm unsaved changes)" }))
map("n", "<leader>cw", "<cmd>confirm close<CR>", vim.tbl_extend("force", opts, { desc = "Close current window" }))

map("n", "<leader>ff", function() require("telescope.builtin").find_files() end, { desc = "Find files" })
map("n", "<leader>fg", function() require("telescope.builtin").live_grep() end, { desc = "Search project text" })
map("n", "<leader>fb", function() require("telescope.builtin").buffers() end, { desc = "Find open buffers" })
map("n", "<leader>fh", function() require("telescope.builtin").help_tags() end, { desc = "Search Neovim help" })

map("n", "<leader>cf", function() require("conform").format({ async = false, lsp_format = "never" }) end,
    { desc = "Format current file" })

return {
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
        opts = function()
            return {
                defaults = {
                    prompt_prefix = "  ",
                    selection_caret = "▏ ",
                    path_display = { "truncate" },
                    sorting_strategy = "ascending",
                    layout_strategy = "horizontal",
                    layout_config = { width = 0.88, height = 0.82, prompt_position = "top", preview_width = 0.56 },
                    border = true,
                    borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
                    color_devicons = true,
                    winblend = 0,
                    prompt_title = "Find",
                    results_title = "Matches",
                    preview_title = "Preview",
                    file_ignore_patterns = { "%.git/", "node_modules/", "target/", "%.lock$" },
                    mappings = {
                        i = { ["<C-j>"] = "move_selection_next", ["<C-k>"] = "move_selection_previous" },
                        n = { ["q"] = "close" },
                    },
                },
                pickers = { find_files = { hidden = true }, git_files = { show_untracked = true } },
                extensions = {},
            }
        end,
    },
}

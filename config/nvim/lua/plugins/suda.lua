return {
    {
        "lambdalisue/vim-suda",
        cmd = { "SudaRead", "SudaWrite" },
        keys = {
            { "<leader>sw", "<cmd>SudaWrite<CR>", desc = "Save current file with sudo" },
        },
    },
}

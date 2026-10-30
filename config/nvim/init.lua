vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.suda_smart_edit = 0

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.clipboard")
vim.cmd.colorscheme("inari")
require("config.lazy")

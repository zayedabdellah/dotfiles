local opt = vim.opt

vim.cmd("syntax on")

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.showmode = false
opt.termguicolors = true
opt.wrap = false
opt.breakindent = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.mouse = "a"

opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true
opt.shiftround = true

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"
opt.laststatus = 3
opt.cmdheight = 1
opt.updatetime = 250
opt.timeout = true
opt.timeoutlen = 400
opt.ttimeoutlen = 10
opt.completeopt = { "menu", "menuone", "noselect" }
opt.shortmess:append("cI")

opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.fixendofline = true
opt.endofline = true
opt.undofile = true
opt.undodir = vim.fn.stdpath("state") .. "/undo//"
vim.fn.mkdir(vim.fn.stdpath("state") .. "/undo", "p", 448)

opt.viewdir = vim.fn.stdpath("state") .. "/view"
opt.viewoptions = { "cursor", "folds", "slash", "unix" }
vim.fn.mkdir(opt.viewdir:get(), "p", 448)
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true
opt.foldmethod = "manual"

opt.clipboard = "unnamedplus"
opt.fillchars = { eob = " ", fold = " ", foldopen = "⌄", foldclose = "›", foldsep = " " }
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.g.have_nerd_font = true

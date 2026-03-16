vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true

opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartindent = true

opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8

opt.ignorecase = true
opt.smartcase = true

opt.splitbelow = true
opt.splitright = true

opt.termguicolors = true
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.updatetime = 250
opt.timeoutlen = 300

opt.completeopt = "menuone,noselect"

-- disable netrw (using nvim-tree instead)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

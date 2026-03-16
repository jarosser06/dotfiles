local map = vim.keymap.set

-- better window navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- move lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- keep cursor centered when scrolling
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- clear search highlight (Esc still does its normal job first)
map("n", "<Esc>", "<Esc><cmd>noh<CR>")

-- buffer navigation
map("n", "<S-h>", "<cmd>bprevious<CR>")
map("n", "<S-l>", "<cmd>bnext<CR>")

-- better paste in visual mode (don't yank replaced text)
map("v", "p", '"_dP')

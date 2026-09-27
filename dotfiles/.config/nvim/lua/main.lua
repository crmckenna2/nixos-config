------------------
---- KEYBINDS ----
------------------

local map = vim.keymap.set

-- Leader key
vim.g.mapleader = ' '

-- Global copy and paste
map({ 'n', 'v' }, '<leader>y', '"+y')
map({ 'n', 'v' }, '<leader>p', '"+p')


-----------------
---- OPTIONS ----
-----------------

local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.statuscolumn = "%s%l  "
opt.wrap = false

-- Tab configuration
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- Search settings
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false


--------------------------
---- LANGUAGE SERVERS ----
--------------------------

vim.lsp.enable("lua_ls")
vim.lsp.enable("nixd")
vim.lsp.enable("qmlls")

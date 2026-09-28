------------------
---- KEYBINDS ----
------------------

--local map = vim.keymap.set

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

-- Clipboard config
opt.clipboard = "unnamedplus"


--------------------------
---- LANGUAGE SERVERS ----
--------------------------

vim.lsp.enable("lua_ls")
vim.lsp.enable("nixd")
vim.lsp.enable("qmlls")

---------------------
---- TREE SITTER ----
---------------------

-- Declare the languages to use treesitter for
local treesitter_languages = {
  "lua",
  "nix",
  "qmljs",
  "markdown",
  "json",
  "csv"
}

-- Enable tree sitter features in the above filetypes
vim.api.nvim_create_autocmd("Filetype", {
  pattern = treesitter_languages,
  callback = function()

    -- Enable highlighting
    vim.treesitter.start()

    -- Enable treesitter folding
    vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.wo[0][0].foldmethod = 'expr'

    -- Enable treesitter indenting
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

  end
})

------------------
---- KEYBINDS ----
------------------

local map = vim.keymap.set
local g = vim.g

-- Key to use in all custom keybinds
g.mapleader = " "

-- TODO


-------------------------
---- GENERAL OPTIONS ----
-------------------------

local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.statuscolumn = "%s%l  "
opt.wrap = false

-- Set reference column
-- vim.opt.colorcolumn = '80'

-- Tab configuration
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- Search settings
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false

-- Use the system clipboard
opt.clipboard = "unnamedplus"

-- Do not fold an entire file upon opening it
opt.foldenable = false
opt.foldlevel = 20

-- Enable mouse mode
opt.mouse = "a"


---------------------
---- DIAGNOSTICS ----
---------------------

vim.diagnostic.config {

  -- General settings
  update_in_insert = false,
  underline = true,
  severity_sort = true,

  -- Start each error message with a ● for each error
  virtual_text = {
    prefix = "●",
  },

  -- Floating error message when using [d and ]d
  float = { source = 'if_many' },
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float {
        bufnr = bufnr,
        scope = 'cursor',
        focus = false,
      }
    end,
  },

}


-------------------------
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


-------------------
---- TELESCOPE ----
-------------------

local telescope = require("telescope")
local actions = require("telescope.actions")

telescope.setup({

  defaults = {

    -- Use sharp corners instead of rounded ones
    borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },

    -- Close telescope on escape, instead of entering normal mode
    mappings = {
      i = {
        ["<esc>"] = actions.close
      }
    },

  },

  -- Include hidden files, but not .git files
  pickers = {
    find_files = {
      find_command = { "rg", "--ignore-case", "--files", "--hidden", "--glob", "!.git" },
    },
    live_grep = {
      additional_args = function()
        return { "--ignore-case", "--hidden", "--glob", "!.git" }
      end
    }
  }

})

-- Telescope keymaps
map('n', '<leader>ff', "<CMD>Telescope find_files<CR>", { desc = 'Telescope find files' })
map('n', '<leader>fg', "<CMD>Telescope live_grep<CR>", { desc = 'Telescope live grep' })
map('n', '<leader>fb', "<CMD>Telescope buffers<CR>", { desc = 'Telescope buffers' })
map('n', '<leader>fh', "<CMD>Telescope help_tags<CR>", { desc = 'Telescope help tags' })


-------------
---- OIL ----
-------------

require("oil").setup()
map("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory." })


-------------------
---- ASTHETICS ----
-------------------

-- Use full color display
opt.termguicolors = true

-- Display the colors of hex codes inside of neovim
require("colorizer").setup({
  RRGGBBAA = true
})

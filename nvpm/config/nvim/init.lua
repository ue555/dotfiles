vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.nvpm")
require("config.options")
require("config.keymaps")
require("config.autocmds")

require("plugins.colorscheme")
require("plugins.telescope")
require("plugins.treesitter")
require("plugins.gitsigns")
require("plugins.which-key")
require("plugins.lualine")
require("plugins.completion")
require("plugins.lsp")

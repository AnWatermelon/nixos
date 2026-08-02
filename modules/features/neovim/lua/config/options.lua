-- Leader has to be set before anything defines a <leader> mapping.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true

-- Treesitter-backed folding. Grammars are installed by Nix; for a buffer with
-- no parser vim.treesitter.foldexpr() returns 0, so this degrades gracefully.
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- Open files unfolded rather than fully collapsed.
vim.opt.foldlevelstart = 99

-- Built-in plugins we do not use.
vim.g.loaded_gzip = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_tutor_mode_plugin = 1

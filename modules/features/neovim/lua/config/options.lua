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

-- Neovim 0.12 sources init.lua *before* loading plugins, so netrw's
-- `FileExplorer` augroup does not exist yet when mini.files' setup() runs
-- `silent! autocmd! FileExplorer *` to disable netrw. That command fills
-- v:errmsg with "E216: No such group or event: FileExplorer *" whenever the
-- group is absent. Pre-create the group so mini.files finds one to clear
-- instead of erroring (its VimEnter autocmd still clears netrw's autocmds
-- once netrw loads).
vim.api.nvim_create_augroup("FileExplorer", {})

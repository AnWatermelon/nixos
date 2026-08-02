-- Grammars are compiled and pinned by Nix, so there is nothing to install at
-- runtime. Just turn highlighting on wherever a parser exists; pcall keeps
-- filetypes without a grammar quiet.
vim.api.nvim_create_autocmd("FileType", {
  desc = "Start treesitter highlighting when a parser is available",
  callback = function(ev)
    pcall(vim.treesitter.start, ev.buf)
  end,
})

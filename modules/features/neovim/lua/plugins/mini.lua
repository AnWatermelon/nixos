require("mini.files").setup({})

vim.keymap.set("n", "<leader>e", function()
  MiniFiles.open()
end, { desc = "File Explorer" })

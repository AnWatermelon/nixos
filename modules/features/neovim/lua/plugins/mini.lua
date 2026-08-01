return {
  "nvim-mini/mini.nvim",
  version = false,
  config = function()
    require("mini.files").setup({})
  end,
  keys = {
    { "<leader>e", function() MiniFiles.open() end, desc = "File Explorer" },
  },
}

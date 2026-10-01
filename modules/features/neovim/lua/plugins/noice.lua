require("noice").setup({
  lsp = {
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
  },
  presets = {
    bottom_search = true,
    command_palette = true,
    long_message_to_split = true,
    inc_rename = false,
    lsp_doc_border = true,
  },
  views = {
    hover = {
      anchor = "SW",
      position = { row = -1, col = 1 },
    },
    signature = {
      anchor = "SW",
      position = { row = -1, col = 1 },
    },
  },

})

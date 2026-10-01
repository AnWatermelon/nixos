require("blink.cmp").setup({
  keymap = { preset = "default" },

  appearance = {
    use_nvim_cmp_as_default = true,
    nerd_font_variant = "mono",
  },

  completion = {
    menu = {
      border = "rounded",
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
      window = {
        border = "rounded",
      },
    },
  },

  signature = {
    enabled = true,
    window = {
      border = "rounded",
    },
  },
})

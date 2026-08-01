return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    dashboard = { enabled = true },
    explorer = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    picker = { enabled = true },
  },
  keys = {
    {
      "<leader> ",
      function()
        Snacks.picker.files({ cwd = Snacks.git.get_root() or vim.fn.expand("~") })
      end,
      desc = "Find Files",
    },
    {
      "<leader>b",
      function()
        Snacks.picker.smart({ cwd = vim.fn.expand("~") })
      end,
      desc = "Global Search",
    },
  },
  init = function()
    -- Prune bad oldfiles that crash fnamemodify (Neovim bug: ~ without / triggers
    -- wildcard expansion → shell → abort in Neovim C internals)
    vim.api.nvim_create_autocmd("VimEnter", {
      once = true,
      callback = function()
        local clean = {}
        for _, f in ipairs(vim.v.oldfiles) do
          -- Paths with bare ~ not followed by / or end-of-string hit Neovim crash
          if not f:match("^~[^/]") then
            clean[#clean + 1] = f
          end
        end
        if #clean ~= #vim.v.oldfiles then
          vim.v.oldfiles = clean
          vim.cmd("wshada!")
        end
      end,
    })
  end,
}

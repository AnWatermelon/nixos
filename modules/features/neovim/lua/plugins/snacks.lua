require("snacks").setup({
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
})

vim.keymap.set("n", "<leader> ", function()
  Snacks.picker.files({ cwd = Snacks.git.get_root() or vim.fn.expand("~") })
end, { desc = "Find Files" })

vim.keymap.set("n", "<leader>b", function()
  Snacks.picker.smart({ cwd = vim.fn.expand("~") })
end, { desc = "Global Search" })

-- Prune bad oldfiles that crash fnamemodify (Neovim bug: a bare ~ not followed
-- by / triggers wildcard expansion → shell → abort in Neovim C internals).
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  desc = "Drop oldfiles entries that crash fnamemodify",
  callback = function()
    local clean = {}
    for _, f in ipairs(vim.v.oldfiles) do
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

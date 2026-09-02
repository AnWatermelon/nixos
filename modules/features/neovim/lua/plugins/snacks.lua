require("snacks").setup({
  bigfile = { enabled = true },
  dashboard = {
    enabled = true,
    preset = {
      keys = {
        { icon = " ", key = "f", desc = "Find File", action = "<leader> " },
        { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
        { icon = " ", key = "g", desc = "Find Text", action = "<leader>g" },
        { icon = "",  key = "l", desc = "Open lazygit", action = "lg" },
        { icon = " ", key = "s", desc = "Restore Session", section = "session" },
        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      },
    },
    sections = {
      { section = "header" },
      { section = "keys", gap = 1, padding = 1 },
    },
  },
  explorer = { enabled = true },
  indent = { enabled = true },
  input = { enabled = true },
  notifier = { enabled = true },
  quickfile = { enabled = true },
  scroll = { enabled = true },
  statuscolumn = { enabled = true },
  words = { enabled = true },
  picker = { enabled = true },
  win = { style = "terminal", },
  lazygit = { enabled = true },
})

vim.keymap.set("n", "<leader> ", function()
  Snacks.picker.files({ cwd = Snacks.git.get_root() or vim.fn.expand("~"), hidden = true, })
end, { desc = "Find Files" })

vim.keymap.set("n", "<leader>b", function()
  Snacks.picker.smart({ cwd = vim.fn.expand("~") })
end, { desc = "Global Search" })

vim.keymap.set("n", "<leader>g", function()
  Snacks.picker.grep({ cwd = Snacks.git.get_root() or vim.fn.expand("~") })
end, { desc = "Global Search" })

vim.keymap.set("n", "<A-`>", function()
  Snacks.terminal.toggle()
end, { desc = "Toggle terminal" })

vim.keymap.set("n", "lg", function()
  Snacks.lazygit.open()
end, { desc = "Open lazygit" })

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

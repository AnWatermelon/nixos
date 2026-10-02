local capabilities = require("blink.cmp").get_lsp_capabilities()

local servers = {
  "bashls",
  "clangd",
  "dockerls",
  "gopls",
  "html",
  "cssls",
  "jsonls",
  "eslint",
  "marksman",
  "pyright",
  "rust_analyzer",
  "taplo",
  "ts_ls",
  "yamlls",
}

for _, lsp in ipairs(servers) do
  vim.lsp.config(lsp, {
    capabilities = capabilities,
  })
  vim.lsp.enable(lsp)
end

vim.lsp.config("nixd", {
  capabilities = capabilities,
  settings = {
    nixd = {
      formatting = {
        command = { "nixfmt" },
      },
    },
  },
})
vim.lsp.enable("nixd")

-- Lua LS configuration
local hypr_stub_dirs = {}
for _, dir in ipairs({
  "/usr/share/hypr/stubs", -- Arch
  "/run/current-system/sw/share/hypr/stubs", -- NixOS
}) do
  if vim.uv.fs_stat(dir) then
    table.insert(hypr_stub_dirs, dir)
  end
end

local has_lazydev, lazydev = pcall(require, "lazydev")
if has_lazydev then
  lazydev.setup({
    library = hypr_stub_dirs,
  })
end

vim.lsp.config("lua_ls", {
  capabilities = capabilities,
  settings = {
    Lua = {
      completion = {
        callSnippet = "Replace",
      },
    },
  },
})
vim.lsp.enable("lua_ls")

vim.diagnostic.config({
  virtual_text = false,
  float = { border = "rounded" },
  signs = true,
  underline = true,
  update_in_insert = false,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
  callback = function(args)
    local buf = args.buf
    local map = vim.keymap.set

    map("n", "gd", vim.lsp.buf.definition, { buffer = buf, desc = "Go to definition" })
    map("n", "gD", vim.lsp.buf.declaration, { buffer = buf, desc = "Go to declaration" })
    map("n", "gr", vim.lsp.buf.references, { buffer = buf, desc = "List references" })
    map("n", "gi", vim.lsp.buf.implementation, { buffer = buf, desc = "Go to implementation" })
    map("n", "gy", vim.lsp.buf.type_definition, { buffer = buf, desc = "Go to type definition" })

    map("n", "K", function()
      vim.lsp.buf.hover({ border = "rounded" })
    end, { buffer = buf, desc = "Hover" })

    map("n", "<leader>rn", vim.lsp.buf.rename, { buffer = buf, desc = "Rename symbol" })
    map("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = buf, desc = "Code action" })
    map("n", "<leader>fm", function()
      vim.lsp.buf.format({ async = true })
    end, { buffer = buf, desc = "Format buffer" })

    map("n", "[d", vim.diagnostic.goto_prev, { buffer = buf, desc = "Previous diagnostic" })
    map("n", "]d", vim.diagnostic.goto_next, { buffer = buf, desc = "Next diagnostic" })
    map("n", "<leader>de", function()
      vim.diagnostic.open_float({ scope = "cursor", border = "rounded" })
    end, { buffer = buf, desc = "Show diagnostic float" })
  end,
})

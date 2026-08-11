vim.lsp.enable("bashls")

vim.lsp.enable("clangd")

vim.lsp.enable("dockerls")

vim.lsp.enable("gopls")

vim.lsp.enable("html")
vim.lsp.enable("cssls")
vim.lsp.enable("jsonls")
vim.lsp.enable("eslint")

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
})
vim.lsp.enable("lua_ls")

vim.lsp.enable("marksman")

vim.lsp.enable("nil_ls")
vim.lsp.enable("nixd")

vim.lsp.enable("pyright")

vim.lsp.enable("rust_analyzer")

vim.lsp.enable("taplo")

vim.lsp.enable("ts_ls")

vim.lsp.enable("yamlls")

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

    map("n", "K", vim.lsp.buf.hover, { buffer = buf, desc = "Hover" })

    map("n", "<leader>rn", vim.lsp.buf.rename, { buffer = buf, desc = "Rename symbol" })
    map("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = buf, desc = "Code action" })
    map("n", "<leader>fm", function()
      vim.lsp.buf.format({ async = true })
    end, { buffer = buf, desc = "Format buffer" })

    map("n", "[d", vim.diagnostic.goto_prev, { buffer = buf, desc = "Previous diagnostic" })
    map("n", "]d", vim.diagnostic.goto_next, { buffer = buf, desc = "Next diagnostic" })
    map("n", "<leader>de", vim.diagnostic.open_float, { buffer = buf, desc = "Show diagnostic float" })
  end,
})

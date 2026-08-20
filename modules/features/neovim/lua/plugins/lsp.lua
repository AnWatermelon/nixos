vim.lsp.enable("bashls")

vim.lsp.enable("clangd")

vim.lsp.enable("dockerls")

vim.lsp.enable("gopls")

vim.lsp.enable("html")
vim.lsp.enable("cssls")
vim.lsp.enable("jsonls")
vim.lsp.enable("eslint")

local hypr_stub_dirs = {}
for _, dir in ipairs({
  "/usr/share/hypr/stubs", -- Arch
  "/run/current-system/sw/share/hypr/stubs", -- NixOS
}) do
  if vim.uv.fs_stat(dir) then
    table.insert(hypr_stub_dirs, dir)
  end
end

local lua_ls_library = vim.list_extend(vim.api.nvim_get_runtime_file("", true), hypr_stub_dirs)

local vim_opt_meta = vim.fn.stdpath("cache") .. "/lua_ls/vim-opt-meta.lua"
vim.fn.mkdir(vim.fn.fnamemodify(vim_opt_meta, ":h"), "p")
local options_gen = vim.api.nvim_get_runtime_file("lua/vim/_meta/options.gen.lua", false)[1]
if options_gen then
  local out = { "--- @meta _", "--- @class vim.opt.Options" }
  local seen = {}
  for line in io.lines(options_gen) do
    local name = line:match("^vim%.o%.([a-z_][a-z0-9_]*)")
    if name and not seen[name] then
      seen[name] = true
      out[#out + 1] = "--- @field " .. name .. " vim.Option"
    end
  end
  out[#out + 1] = "vim.opt = vim.opt"
  out[#out + 1] = "vim.opt_local = vim.opt"
  out[#out + 1] = "vim.opt_global = vim.opt"
  local f = assert(io.open(vim_opt_meta, "w"))
  f:write(table.concat(out, "\n"), "\n")
  f:close()
  table.insert(lua_ls_library, vim.fn.fnamemodify(vim_opt_meta, ":h"))
end

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim", "hl" } },
      workspace = {
        library = lua_ls_library,
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

    local client = vim.lsp.get_client_by_id(args.data.client_id)

    vim.lsp.completion.enable(true, client.id, buf, { autotrigger = true })

    map("i", "<C-Space>", function()
      vim.lsp.completion.get()
    end, { buffer = buf, desc = "Trigger LSP completion" })

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

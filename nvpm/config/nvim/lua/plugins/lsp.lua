local mason_ok, mason = pcall(require, "mason")
local mason_lsp_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if not mason_ok or not mason_lsp_ok then
  return
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
local cmp_lsp_ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if cmp_lsp_ok then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

vim.lsp.config("*", {
  capabilities = capabilities,
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        checkThirdParty = false,
        library = vim.api.nvim_get_runtime_file("", true),
      },
    },
  },
})

mason.setup({})

local servers = {
  "bashls",
  "gopls",
  "lua_ls",
  "pyright",
  "rust_analyzer",
  "ts_ls",
}

mason_lspconfig.setup({
  ensure_installed = vim.env.NVPM_SETUP == "1" and {} or servers,
  automatic_enable = true,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("dotfiles-lsp", { clear = true }),
  callback = function(args)
    local function map(lhs, rhs, description)
      vim.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = description })
    end

    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("gD", vim.lsp.buf.declaration, "Go to declaration")
    map("gr", vim.lsp.buf.references, "Find references")
    map("gi", vim.lsp.buf.implementation, "Go to implementation")
    map("K", vim.lsp.buf.hover, "Hover documentation")
    map("<leader>lr", vim.lsp.buf.rename, "Rename symbol")
    map("<leader>la", vim.lsp.buf.code_action, "Code action")
    map("<leader>lf", function()
      vim.lsp.buf.format({ async = true })
    end, "Format buffer")
  end,
})

vim.diagnostic.config({
  severity_sort = true,
  float = { border = "rounded", source = true },
  signs = true,
  underline = true,
  virtual_text = true,
})

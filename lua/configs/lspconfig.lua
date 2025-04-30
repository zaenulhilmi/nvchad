-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"

-- EXAMPLE
local servers = { "html", "cssls", "gopls", "ts_ls", "lua_ls", "pyright", "rust_analyzer", "dartls" }
local nvlsp = require "nvchad.configs.lspconfig"

-- Define custom on_attach to include formatting keybind
local function on_attach(client, bufnr)
  -- Run NvChad's default on_attach
  if nvlsp.on_attach then
    nvlsp.on_attach(client, bufnr)
  end

  -- Enable formatting keybind if the LSP supports it
  if client.server_capabilities.documentFormattingProvider then
    vim.api.nvim_buf_set_keymap(
      bufnr,
      "n",
      "<leader>fc",
      "<cmd>lua vim.lsp.buf.format({ async = true })<CR>",
      { noremap = true, silent = true }
    )
  end

  vim.api.nvim_buf_set_keymap(
    bufnr,
    "n",
    "<leader>ca",
    "<cmd>lua vim.lsp.buf.code_action()<CR>",
    { noremap = true, silent = true }
  )


  vim.api.nvim_buf_set_keymap(
    bufnr,
    "v",
    "<C-k>",
    "<cmd>lua vim.lsp.buf.code_action()<CR>",
    { noremap = true, silent = true }
  )

  vim.api.nvim_buf_set_keymap(
    bufnr,
    "n",
    "<C-k>",
    "<cmd>lua vim.lsp.buf.code_action()<CR>",
    { noremap = true, silent = true }
  )
end

-- lsps with default config
for _, lsp in ipairs(servers) do
  if lsp == "lua_ls" then
    lspconfig[lsp].setup {
      on_attach = on_attach,
      on_init = nvlsp.on_init,
      capabilities = nvlsp.capabilities,
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false,
          },
        },
      },
    }
  else
    lspconfig[lsp].setup {
      on_attach = on_attach,
      on_init = nvlsp.on_init,
      capabilities = nvlsp.capabilities,
    }
  end
end




-- configuring single server, example: typescript
-- lspconfig.ts_ls.setup {
--   on_attach = nvlsp.on_attach,
--   on_init = nvlsp.on_init,
--   capabilities = nvlsp.capabilities,
-- }


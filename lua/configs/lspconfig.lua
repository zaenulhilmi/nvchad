local nv = require("nvchad.configs.lspconfig")
nv.defaults()

-- Enable common servers via the built-in helper
vim.lsp.enable({ "html", "cssls", "gopls", "pyright", "rust_analyzer", "dartls" })

-- Configure TypeScript (ts_ls) using the new API (no require('lspconfig'))
-- This avoids the upstream root_dir path-join issue.
vim.lsp.config('ts_ls', {
  -- Use new signature: function(bufnr, on_dir)
  root_dir = function(bufnr, on_dir)
    local markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' }
    local root = vim.fs.root(bufnr, markers) or vim.fn.getcwd()
    on_dir(root)
  end,
  single_file_support = true,
})

-- Enable TypeScript after configuring it
vim.lsp.enable('ts_ls')

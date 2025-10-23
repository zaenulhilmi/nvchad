require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
--
--

vim.g.clipboard = {
  name = 'WslClipboard',
  copy = {
    ['+'] = 'clip.exe',
    ['*'] = 'clip.exe',
  },
  paste = {
    ['+'] = 'pwsh.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    ['*'] = 'pwsh.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
  },
  cache_enabled = 0,
}

-- Neovim only mappings
map("n", "<leader>1", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle NvimTree" })

map({ "n", "t" }, "<leader>0", function()
  require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" }
end, { desc = "Toggle Terminal" })

-- LSP: navigation + actions
map("n", "gd", function()
  vim.lsp.buf.definition()
end, { desc = "LSP: Go to definition", silent = true })

map("n", "gi", function()
  vim.lsp.buf.implementation()
end, { desc = "LSP: Go to implementation", silent = true })

map("n", "<leader>ca", function()
  vim.lsp.buf.code_action()
end, { desc = "LSP: Code actions", silent = true })

-- LSP formatting
map("n", "<leader>cf", function()
  vim.lsp.buf.format { async = false }
end, { desc = "LSP: Format file", silent = true })

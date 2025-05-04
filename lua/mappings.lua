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


if vim.g.vscode then
  -- VSCode extension
  map("n", "<leader>1", "<cmd>lua require('vscode').action('workbench.action.toggleSidebarVisibility')<CR>",
    { desc = "Toggle Vscode Explorer" })

  map({ "n", "t" }, "<leader>0", "<cmd>lua require('vscode').action('workbench.action.terminal.toggleTerminal')<CR>",
    { desc = "Toggle Terminal" })

  map({ "n", "t" }, "<M>0", "<cmd>lua require('vscode').action('workbench.action.terminal.toggleTerminal')<CR>",
    { desc = "Toggle Terminal" })

  map("n", "<leader>fc", "<cmd>lua require('vscode').action('editor.action.formatDocument')<CR>",
    { desc = "Quick Open File" }
  )

  map("n", "<leader>ff", "<cmd>lua require('vscode').action('find-it-faster.findFiles')<CR>",
    { desc = "Open File Folder" })

  map("n", "<leader>fw", "<cmd>lua require('vscode').action('find-it-faster.findWithinFiles')<CR>",
    { desc = "Open File Folder" })

  map("n", "<leader>x", "<cmd>lua require('vscode').action('workbench.action.closeActiveEditor')<CR>",
    { desc = "Close Active Editor" })
else
  map("n", "<leader>1", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle NvimTree" })

  map({ "n", "t" }, "<leader>0", function()
    require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" }
  end, { desc = "terminal toggleable horizontal term" })
end

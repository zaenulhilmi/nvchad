-- ~/.config/nvim/lua/rakit/init.lua
local M = {}

-- Import modules
local picker = require("rakit.picker")
local ghost = require("rakit.ghost")
local window = require("rakit.window")

function M.setup()
  -- Basic commands and keymaps
  vim.api.nvim_create_user_command("RakitHi", function()
    vim.notify("🚀 Hello from rakit.nvim!", vim.log.levels.INFO)
  end, {})

  -- Action picker keymaps
  vim.keymap.set("n", "<leader>m", picker.action_picker, { desc = "Open action picker" })
  vim.keymap.set("v", "<leader>m", picker.action_picker, { desc = "Open action picker" })

  vim.keymap.set("n", "<leader>rr", function()
    package.loaded["rakit"] = nil
    require("rakit").setup()
    print("Reloaded rakit")
  end, { desc = "Reload rakit.nvim" })

  vim.keymap.set("n", "<leader>tt", function()
    window.open_chat_window()
  end, { desc = "Reload rakit.nvim" })

  -- Visual mode keymaps
  vim.keymap.set("v", "<C-r>", function()
    local visual = vim.fn.getreg('"')
    vim.notify("Selected content:\n" .. visual, vim.log.levels.INFO)
  end, { noremap = true, silent = true })

  vim.keymap.set("v", "<C-t>", function()
    ghost.stream_ghost("why is the sky blue?")
  end, { noremap = true, silent = true })

  -- Setup ghost text functionality
  ghost.setup()
end

return M

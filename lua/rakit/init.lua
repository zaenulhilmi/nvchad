-- ~/.config/nvim/lua/rakit/init.lua
local M = {}

-- Import modules
local picker = require("rakit.picker")
local ghost = require("rakit.ghost")
local window = require("rakit.window")
local text = require("rakit.text")
local config = require("rakit.config")
local core = require("rakit.core")

function M.setup()
  -- Basic commands and keymaps
  vim.api.nvim_create_user_command("RakitHi", function()
    vim.notify("🚀 Hello from rakit.nvim!", vim.log.levels.INFO)
  end, {})

  -- Action picker keymaps
  vim.keymap.set("n", "<leader>m", function()
    picker.action_picker(function()
      local current_buf = vim.api.nvim_get_current_buf()
      local text_content = text.get_file_content(current_buf)
      if not text_content or text_content == "" then
        vim.notify("No text found in the buffer", vim.log.levels.WARN)
        return
      end
      -- vim.notify("Selected content:\n" .. text_content, vim.log.levels.INFO)
      core.explain(text_content)
    end)
  end, { desc = "Open action picker" })


  vim.keymap.set("v", "<leader>m", function()
    text.get_visual_selection(function(selected_text)
      if not selected_text or selected_text == "" then
        vim.notify("No text found in the buffer", vim.log.levels.WARN)
        return
      end

      picker.action_picker(function()
        core.explain(selected_text)
      end)
    end)
  end, { desc = "Open action picker" })


  vim.keymap.set("n", "<leader>rr", function()
    package.loaded["rakit"] = nil
    require("rakit").setup()
    print("Reloaded rakit")
  end, { desc = "Reload rakit.nvim" })

  vim.keymap.set("n", "<leader>tt", function()
    window.open_chat_window()
  end, { desc = "Reload rakit.nvim" })

  vim.keymap.set("n", "<CR>", function()
    local buf = window.get_buffer_by_name(config.window_name)
    if not buf or not vim.api.nvim_buf_is_valid(buf) then
      vim.notify("no buffer found", vim.log.levels.WARN)
      return
    end

    core.chat()
  end, { desc = "Reload rakit.nvim" })



  vim.keymap.set("n", "<leader>ts", function()
    local current_buf = vim.api.nvim_get_current_buf()
    local text_content = text.get_file_content(current_buf)
    if not text_content or text_content == "" then
      vim.notify("No text found in the buffer", vim.log.levels.WARN)
      return
    end
    -- vim.notify("Selected content:\n" .. text_content, vim.log.levels.INFO)
    core.explain(text_content)
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

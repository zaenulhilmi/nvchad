-- ~/.config/nvim/lua/rakit/init.lua
local M = {}

-- Import modules
local picker = require("rakit.picker")
local ghost = require("rakit.ghost")
local window = require("rakit.window")
local text = require("rakit.text")
local config = require("rakit.config")
local core = require("rakit.core")

local function get_visual_selection(callback)
  vim.schedule(function()
    -- Reselect the last visual selection
    vim.cmd("normal! gv")

    local bufnr = 0
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")

    local lines = vim.api.nvim_buf_get_lines(bufnr, start_pos[2] - 1, end_pos[2], false)

    if #lines == 0 then
      vim.notify("No selection", vim.log.levels.WARN)
      return
    end

    -- Trim based on columns
    if #lines == 1 then
      lines[1] = lines[1]:sub(start_pos[3], end_pos[3])
    else
      lines[1] = lines[1]:sub(start_pos[3])
      lines[#lines] = lines[#lines]:sub(1, end_pos[3])
    end

    local selected_text = table.concat(lines, "\n")
    callback(selected_text)
  end)
end

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
    get_visual_selection(function(selected_text)
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

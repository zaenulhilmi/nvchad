-- ~/.config/nvim/lua/rakit/init.lua
local M = {}

-- Import modules
local picker = require("rakit.picker")
local ghost = require("rakit.ghost")
local window = require("rakit.window")
local text = require("rakit.text")
local config = require("rakit.config")
local core = require("rakit.core")
local http = require("rakit.http")


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

local function get_text_before_cursor_with_context(context_lines)
  context_lines = context_lines or 3 -- default to 3 lines

  local cur_row, cur_col = unpack(vim.api.nvim_win_get_cursor(0))
  local start_line = math.max(cur_row - context_lines, 1)
  local end_line = cur_row

  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  -- Trim the current line to cursor column
  lines[#lines] = lines[#lines]:sub(1, cur_col)

  return table.concat(lines, "\n")
end

local function get_text_after_cursor_with_context(context_lines)
  context_lines = context_lines or 3 -- default to 3 lines

  local cur_row, cur_col = unpack(vim.api.nvim_win_get_cursor(0))
  local start_line = cur_row + 1
  local end_line = math.min(cur_row + context_lines, vim.api.nvim_buf_line_count(0))

  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  -- Trim the current line to cursor column
  lines[1] = lines[1]:sub(cur_col + 1)

  return table.concat(lines, "\n")
end

local debounce_timer = vim.loop.new_timer()

local time = 0
-- This is the function that will be run after a delay
local function on_stopped_typing()
  print("User stopped typing for 1 second.")
  time = time + 1
  local text_before_cursor = get_text_before_cursor_with_context()
  local text_after_cursor = get_text_after_cursor_with_context()
  local ghost_text = ""

  http.stream_ollama_response(config.model.code, text_before_cursor, text_after_cursor, function(response, done)
    if response then
      ghost_text = ghost_text .. response
      ghost.update_ghost(ghost_text)
    else
      vim.notify("Failed to fetch URL", vim.sts.levels.ERROR)
    end
  end)
end

-- Set up autocommand
vim.api.nvim_create_autocmd({ "InsertEnter", "InsertCharPre" }, {
  callback = function()
    -- Stop any previous timer
    debounce_timer:stop()

    -- Start a new one with 1-second delay
    debounce_timer:start(1000, 0, vim.schedule_wrap(function()
      on_stopped_typing()
    end))
  end
})

return M

local config = require("rakit.config")

local M = {}

local window_name = config.window_name


--- Check if any window is showing the buffer
local function is_window_open_for_buffer(buf)
  if not buf then return false end
  local wins = vim.fn.win_findbuf(buf)
  return #wins > 0, wins
end

--- Focus an existing window that contains the buffer
local function focus_buffer_window(buf)
  local wins = vim.fn.win_findbuf(buf)
  for _, win in ipairs(wins) do
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_set_current_win(win)
      return true
    end
  end
  return false
end

--- Create and show a new scratch buffer in a vertical split
local function create_scratch_buffer(name)
  vim.cmd("vsplit")
  local buf = vim.api.nvim_create_buf(false, true) -- scratch, unlisted
  vim.api.nvim_buf_set_name(buf, name)
  vim.api.nvim_win_set_buf(0, buf)
  return buf
end


--- Get a buffer by its short (tail) name
function M.get_buffer_by_name(name)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local buf_name = vim.api.nvim_buf_get_name(buf)
    if vim.fn.fnamemodify(buf_name, ":t") == name then
      return buf
    end
  end
  return nil
end

--- Public: Open or focus the chat window
function M.open_chat_window()
  local buf = M.get_buffer_by_name(window_name)

  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    vim.notify("Creating new chat window", vim.log.levels.INFO)
    create_scratch_buffer(window_name)
    return
  end

  if is_window_open_for_buffer(buf) then
    vim.notify("Chat window already exists", vim.log.levels.INFO)
    focus_buffer_window(buf)
    return
  end

  vim.notify("Showing existing chat buffer", vim.log.levels.INFO)
  vim.cmd("vsplit")
  vim.api.nvim_win_set_buf(0, buf)
end

return M

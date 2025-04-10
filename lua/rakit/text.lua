local config = require("rakit.config")
local window = require("rakit.window")

local M = {}

function M.get_latest_text()
  local buf = window.get_buffer_by_name(config.window_name)
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return nil
  end

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  return table.concat(lines, "\n")
end

function M.append_text(text)
  local buf = window.get_buffer_by_name(config.window_name)
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  local lines = vim.split(text, "\n", { plain = true })
  local line_count = vim.api.nvim_buf_line_count(buf)
  local last_line_idx = line_count - 1

  local current_line = vim.api.nvim_buf_get_lines(buf, last_line_idx, last_line_idx + 1, false)[1] or ""

  if #lines == 1 then
    -- No newlines in input, just append to current line
    vim.api.nvim_buf_set_lines(buf, last_line_idx, last_line_idx + 1, false, { current_line .. lines[1] })
  else
    -- Append first line to current line
    local new_lines = {}
    new_lines[1] = current_line .. lines[1]
    for i = 2, #lines do
      table.insert(new_lines, lines[i])
    end
    vim.api.nvim_buf_set_lines(buf, last_line_idx, last_line_idx + 1, false, new_lines)
  end
end


return M

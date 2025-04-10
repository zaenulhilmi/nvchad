local config = require("rakit.config")
local window = require("rakit.window")

local M = {}

local function extract_last_prompt(text)
  local last_end = 0

  -- Look for the last '####### End of Response'
  for _start, _end in text:gmatch("()####### End of Response()") do
    last_end = _end
  end

  local prompt = ""
  if last_end > 0 then
    -- Get everything after the last End of Response
    prompt = text:sub(last_end):match("^%s*(.-)%s*$") or ""
  else
    -- No End of Response found, use the full text as prompt
    prompt = vim.trim(text)
  end

  return prompt
end


function M.get_latest_text()
  local buf = window.get_buffer_by_name(config.window_name)
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return nil
  end

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local text = table.concat(lines, "\n")
  if text == "" then
    return nil
  end

  text = extract_last_prompt(text)
  if text == "" then
    return nil
  end


  return text
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

function M.get_file_content(buf)
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return nil
  end

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local text = table.concat(lines, "\n")
  if text == "" then
    return nil
  end

  return text
end

function M.get_visual_selection(callback)
  vim.schedule(function()
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


return M

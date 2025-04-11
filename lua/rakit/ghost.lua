local uv = vim.loop
local M = {}

-- Create namespace for ghost text
local ns = vim.api.nvim_create_namespace("ghost-text")
local extmark_id = nil
function M.update_ghost(text)
  -- Clear previous extmark
  if extmark_id then
    pcall(vim.api.nvim_buf_del_extmark, 0, ns, extmark_id)
  end

  local row = vim.fn.line('.') - 1
  local lines = vim.split(text, "\n", { plain = true })

  -- Convert lines into the format virt_lines expects
  local virt_lines = {}
  for _, line in ipairs(lines) do
    table.insert(virt_lines, { { line, "Comment" } })
  end

  extmark_id = vim.api.nvim_buf_set_extmark(0, ns, row, 0, {
    id = extmark_id,
    virt_lines = virt_lines,
    virt_lines_above = false, -- set to true to show above current line
    hl_mode = "combine",
  })
end

function M.append_ghost(text)
  local row = vim.fn.line('.') - 1
  local col = vim.fn.col('.') - 1

  -- Append ghost text to the current line
  vim.api.nvim_buf_set_lines(0, row, row + 1, false, { text })
end

function M.clear_ghost()
  if extmark_id then
    vim.api.nvim_buf_del_extmark(0, ns, extmark_id)
    extmark_id = nil
  end
end

function M.stream_ghost(prompt)
  local stdout = uv.new_pipe(false)
  local stderr = uv.new_pipe(false)

  print("🚀 Generating...")

  local handle
  handle = uv.spawn("curl", {
    args = {
      "--silent",
      "--no-buffer",
      "--location",
      "http://localhost:11434/api/generate",
      "--header", "Content-Type: application/json",
      "--data", vim.fn.json_encode({
      model = "codegemma",
      prompt = prompt,
    }),
    },
    stdio = { nil, stdout, stderr },
  }, function(code)
    stdout:read_stop()
    stderr:read_stop()
    stdout:close()
    stderr:close()
    handle:close()
  end)

  local buffer = ""

  stdout:read_start(function(err, chunk)
    print("🚀 Reading stdout...")
    print("🚀 Chunk: ", chunk)
    assert(not err, err)
    if chunk then
      buffer = buffer .. chunk

      for line in buffer:gmatch("([^\n]*)\n") do
        if line and line ~= "" then
          local ok, data = pcall(vim.fn.json_decode, line)
          if ok and data and data.response then
            vim.schedule(function()
              M.update_ghost(data.response)
            end)
          end
        end
      end

      buffer = buffer:match("[^\n]*$") or ""
    end
  end)

  stderr:read_start(function(_, chunk)
    if chunk then
      vim.schedule(function()
        vim.notify("stderr: " .. chunk, vim.log.levels.ERROR)
      end)
    end
  end)
end

-- Setup autocmds for ghost text
function M.setup()
  -- Autocmd to show ghost text as you type
  vim.api.nvim_create_autocmd({ "InsertCharPre", "TextChangedI" }, {
    callback = function()
      -- M.stream_ghost("why is the sky blue?")
    end,
  })

  -- Autocmd to clear ghost text when leaving insert mode
  vim.api.nvim_create_autocmd("InsertLeave", {
    callback = function()
      vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    end,
  })
end

return M

local M = {}

function M.get_request(url)
  local response = vim.fn.system("curl -s " .. url)
  if vim.v.shell_error ~= 0 then
    vim.notify("Error fetching URL: " .. url, vim.log.levels.ERROR)
    return nil
  end
  return response
end

function M.fetch_url_async(url, callback)
  vim.notify("Fetching URL: " .. url, vim.log.levels.INFO)
  local stdout = vim.loop.new_pipe(false)
  local stderr = vim.loop.new_pipe(false)

  local handle
  handle = vim.loop.spawn("curl", {
    -- post request
    args = { "-s", url },
    stdio = { nil, stdout, stderr },
  }, function(code)
    stdout:read_stop()
    stderr:read_stop()
    stdout:close()
    stderr:close()
    handle:close()

    if code ~= 0 then
      vim.schedule(function()
        vim.notify("Error fetching URL: " .. url, vim.log.levels.ERROR)
        callback(nil)
      end)
      return
    end
  end)

  local data_chunks = {}

  vim.loop.read_start(stdout, function(err, chunk)
    assert(not err, err)
    if chunk then
      table.insert(data_chunks, chunk)
    else
      vim.schedule(function()
        local response = table.concat(data_chunks)
        callback(response)
      end)
    end
  end)
end

function M.stream_ollama_response(prompt, on_response)
  local cmd = {
    "curl",
    "--no-buffer", -- important to stream line by line
    "--location", "http://localhost:11434/api/generate",
    "--header", "Content-Type: application/json",
    "--data", vim.fn.json_encode({
    model = "codellama:7b",
    prompt = prompt,
  }),
  }

  local start = 1
  vim.fn.jobstart(cmd, {
    stdout_buffered = false,
    on_stdout = function(_, data, _)
      for _, line in ipairs(data) do
        if line ~= "" then
          local ok, decoded = pcall(vim.json.decode, line)
          if ok and decoded and decoded.response and on_response then
            vim.schedule(function()
              on_response(decoded.response, decoded.done, start == 1)
              start = start + 1
            end)
          end
        end
      end
    end,
    on_stderr = function(_, data, _)
      for _, line in ipairs(data) do
        if line ~= "" then
          vim.schedule(function()
            --     vim.notify("[stderr] " .. line, vim.log.levels.ERROR)
          end)
        end
      end
    end,
    on_exit = function(_, code, _)
      vim.schedule(function()
        vim.notify("Stream ended with exit code: " .. code)
      end)
    end,
  })
end

return M


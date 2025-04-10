
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


return M 

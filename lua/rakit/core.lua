local text = require("rakit.text")
local http = require("rakit.http")

local M = {}

function M.chat()
  local text_content = text.get_latest_text()
  if text_content then
    http.stream_ollama_response(text_content, function(response, done, start)
      if response then
        text.append_text(response)
      else
        vim.notify("Failed to fetch URL", vim.sts.levels.ERROR)
      end
      if start then
        text.append_text("\n\n####### Start of Response\n\n")
      end
      if done then
        text.append_text("\n\n####### End of Response\n")
      end
    end)
  else
    vim.notify("No text found in the buffer", vim.log.levels.WARN)
  end
end

return M

local text = require("rakit.text")
local http = require("rakit.http")

local M = {}

function M.chat()
  local text_content = text.get_latest_text()

  if text_content then
    text.append_text("\n\n####### Start of Response\n")
    http.stream_ollama_response(text_content, function(response, done)
      if response then
        text.append_text(response)
      else
        vim.notify("Failed to fetch URL", vim.sts.levels.ERROR)
      end
      if done then
        text.append_text("\n\n####### End of Response\n")
      end
    end)
  else
    vim.notify("No text found in the buffer", vim.log.levels.WARN)
  end
end

function M.explain(text_content)
  if text_content then
    text_content =
        "Explain this code snippet give a big picture of the code and how it works, keep it simple and easy to understand: " ..
        text_content
    text.append_text("\n\n####### Start of Response\n")
    http.stream_ollama_response(text_content, function(response, done)
      if response then
        text.append_text(response)
      else
        vim.notify("Failed to fetch URL", vim.sts.levels.ERROR)
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

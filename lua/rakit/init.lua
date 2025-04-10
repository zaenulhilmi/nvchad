-- ~/.config/nvim/lua/rakit/init.lua
local M = {}

-- Import modules
local picker = require("rakit.picker")
local ghost = require("rakit.ghost")
local window = require("rakit.window")
local text = require("rakit.text")
local http = require("rakit.http")
local config = require("rakit.config")


local function stream_ollama_response(prompt, on_response)
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

function M.setup()
  -- Basic commands and keymaps
  vim.api.nvim_create_user_command("RakitHi", function()
    vim.notify("🚀 Hello from rakit.nvim!", vim.log.levels.INFO)
  end, {})

  -- Action picker keymaps
  vim.keymap.set("n", "<leader>m", picker.action_picker, { desc = "Open action picker" })
  vim.keymap.set("v", "<leader>m", picker.action_picker, { desc = "Open action picker" })

  vim.keymap.set("n", "<leader>rr", function()
    package.loaded["rakit"] = nil
    require("rakit").setup()
    print("Reloaded rakit")
  end, { desc = "Reload rakit.nvim" })

  vim.keymap.set("n", "<leader>tt", function()
    window.open_chat_window()
  end, { desc = "Reload rakit.nvim" })

  vim.keymap.set("n", "<leader>ts", function()
    local text_content = text.get_latest_text()
    if text_content then
      --vim.notify("Latest text:\n" .. text_content, vim.log.levels.INFO)

      stream_ollama_response(text_content, function(response, done, start)
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

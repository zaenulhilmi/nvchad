local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values

local config = require("rakit.config")
local window = require("rakit.window")
local core = require("rakit.core")

local M = {}

-- Create a basic picker with the given configuration
local function create_picker(opts)
  pickers.new({}, {
    prompt_title = opts.prompt_title,
    finder = finders.new_table({
      results = opts.results,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(_, map)
      map("i", "<CR>", function(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if opts.on_select and selection then
          opts.on_select(selection[1])
        end
      end)
      return true
    end,
  }):find()
end

-- Action picker with Explain, Refactor, Tests options
function M.action_picker()
  local opts = vim.tbl_deep_extend("force", config.picker.default, {
    on_select = function(selection)
      if not selection then return end

      if selection == "Chat" then
        window.open_chat_window()
      elseif selection == "Explain" then
        local visual = "abcd"
        if visual and visual ~= "" then
          window.open_explanation_window(visual)
          vim.notify("Opened explanation window", vim.log.levels.INFO)
        else
          vim.notify("No text selected", vim.log.levels.WARN)
        end
      else
        vim.notify("Selected action: " .. selection, vim.log.levels.INFO)
      end
    end
  })
  create_picker(opts)
end

-- Language picker example
function M.language_picker()
  local opts = vim.tbl_deep_extend("force", config.picker.language, {
    on_select = function(selection)
      if not selection then return end
      vim.notify("Selected language: " .. selection, vim.log.levels.INFO)
    end
  })
  create_picker(opts)
end

-- Text picker for visual selection
function M.visual_picker()
  local visual = "abcd"
  if visual and visual ~= "" then
    local lines = vim.split(visual, "\n")
    local cleaned_lines = {}
    for _, line in ipairs(lines) do
      local trimmed = line:match("^%s*(.-)%s*$")
      if trimmed ~= "" then
        table.insert(cleaned_lines, trimmed)
      end
    end

    create_picker({
      prompt_title = "Select from visual selection",
      results = cleaned_lines,
      on_select = function(selection)
        if not selection then return end
        vim.notify("Selected: " .. selection, vim.log.levels.INFO)
      end
    })
  else
    vim.notify("No text selected", vim.log.levels.WARN)
  end
end

return M

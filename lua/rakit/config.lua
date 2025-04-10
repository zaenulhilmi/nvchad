local M = {}

-- Picker configurations
M.picker = {
  default = {
    prompt_title = "Choose an action",
    results = { "Explain", "Refactor", "Tests" },
  },
  language = {
    prompt_title = "Select a programming language",
    results = { "Lua", "Python", "JavaScript", "Rust", "Go" },
  }
}

-- Window configurations
M.window = {
  explanation = {
    filetype = "markdown",
    name = "Explanation",
    options = {
      wrap = true,
      number = false,
      relativenumber = false,
      cursorline = true,
    }
  }
}

M.window_name = "Rakit Chat"

-- API configurations
M.api = {
  ghost = {
    url = "http://localhost:11434/api/generate",
    model = "codegemma",
  }
}

return M 

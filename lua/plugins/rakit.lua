return {
  "rakit.nvim",
  dir = "~/.config/nvim/lua/rakit", -- or wherever you store it
  lazy = false,
  dev = true,
  enabled = false,
  config = function()
    require("rakit").setup()
  end,
}


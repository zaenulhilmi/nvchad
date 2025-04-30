return {
  cmd = {
    "dart",
    "language-server",
    "--client-id", "my-editor.my-plugin",
    "--client-version", "1.2",
  },
  filetypes = { "dart" },
  init_options = {
    closingLabels = true,
    outline = true,
    flutterOutline = true,
  },
  settings = {},
}


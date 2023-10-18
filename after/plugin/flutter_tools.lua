require("flutter-tools").setup {
  decorations = {
    statusline = {
      app_version = true,
      device = true
    },
  },
  widget_guides = {
    enabled = true
  },
  debugger = {
    enabled = true,
    run_via_dap = false,
  },
  lsp = {
    color = {enabled = true},
    settings = {
      showTodos = false,
      completeFunctionCalls = true,
      renameFilesWithClasses = "prompt",
      enableSnippets = true,
    },
  }
} -- use defaults

-- C# LSP extended plugin
return {
  "Decodetalkers/csharpls-extended-lsp.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
  },
  config = function()
    local lspconfig = require("lspconfig")

    require 'lspconfig'.csharp_ls.setup(lspconfig)
    require("csharpls_extended").buf_read_cmd_bind()
  end,
}

-- C# LSP extended plugin
return {
  "Decodetalkers/csharpls-extended-lsp.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
  },
  config = function()
    local lspconfig = require("lspconfig")

    lspconfig.csharp_ls.setup({
      handlers = {
        ["textDocument/definition"] = require("csharpls_extended").handler,
        ["textDocument/typeDefinition"] = require("csharpls_extended").handler,
      },
      -- Optional: Add custom keymaps for enhanced navigation
      on_attach = function(client, bufnr)
        vim.keymap.set("n", "gd", function()
          require("csharpls_extended").lsp_definitions()
        end, { noremap = true, desc = "Go to extended definition", buffer = bufnr })
      end,
    })

    -- For Neovim 0.11+
    if vim.fn.has("nvim-0.11") == 1 then
      require("csharpls_extended").buf_read_cmd_bind()
    end
  end,
}

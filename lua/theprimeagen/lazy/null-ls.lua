return {
  "nvimtools/none-ls.nvim", -- fork di null-ls
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  event = "BufReadPre",
  config = function()
    local null_ls = require("null-ls")

    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

    local b = null_ls.builtins

    local sources = {

      -- webdev stuff
      b.formatting.prettier.with {
        command = "node_modules/.bin/prettier",
        filetypes = { "html", "markdown", "css", "typescript" },
      },

      -- Lua
      b.formatting.stylua,

      -- cpp
      b.formatting.clang_format,
      null_ls.builtins.formatting.prettier,
      null_ls.builtins.formatting.stylua,

      -- Diagnostica
      null_ls.builtins.diagnostics.eslint,

      -- Completamento
      null_ls.builtins.completion.spell,

    }

    null_ls.setup {
      debug = true,
      sources = sources,
      on_attach = function(client, bufnr)
        if client.supports_method "textDocument/formatting" then
          vim.api.nvim_clear_autocmds {
            group = augroup,
            buffer = bufnr,
          }
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format { bufnr = bufnr }
            end,
          })
        end
      end,
    }
  end,
}

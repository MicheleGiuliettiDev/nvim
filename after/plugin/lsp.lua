local lsp = require("lsp-zero")

lsp.preset("recommended")

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<UP>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<DOWN>'] = cmp.mapping.select_next_item(cmp_select),
  ['<cr>'] = cmp.mapping.confirm({ select = true }),
  ["<C-Space>"] = cmp.mapping.complete(),
  ['<Esc>'] = cmp.mapping.abort(),
})

cmp.setup({
  mapping = cmp_mappings
})

lsp.set_preferences({
  suggest_lsp_servers = false,
  sign_icons = {
    error = 'E',
    warn = 'W',
    hint = 'H',
    info = 'I'
  }
})

lsp.on_attach(function(client, bufnr)
  local opts = { buffer = bufnr, remap = false }

  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
  vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
  vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
  vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
  vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

lsp.setup()

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = { 'tsserver', 'rust_analyzer' },
  handlers = {
    lsp.default_setup,
  }
})

vim.diagnostic.config({
  virtual_text = false, -- Turn off inline diagnostics
})

-- Use this if you want it to automatically show all diagnostics on the
-- current line in a floating window. Personally, I find this a bit
-- distracting and prefer to manually trigger it (see below). The
-- CursorHold event happens when after `updatetime` milliseconds. The
-- default is 4000 which is much too long
vim.o.updatetime = 300

-- Show all diagnostics on current line in floating window
vim.api.nvim_set_keymap(
  'n', '<Leader>df', ':lua vim.diagnostic.open_float()<CR>', 
  { noremap = true, silent = true }
)
-- Go to next diagnostic (if there are multiple on the same line, only shows
-- one at a time in the floating window)
vim.api.nvim_set_keymap(
  'n', '<Leader>n', ':lua vim.diagnostic.goto_next()<CR>',
  { noremap = true, silent = true }
)
-- Go to prev diagnostic (if there are multiple on the same line, only shows
-- one at a time in the floating window)
vim.api.nvim_set_keymap(
  'n', '<Leader>p', ':lua vim.diagnostic.goto_prev()<CR>',
  { noremap = true, silent = true }
)

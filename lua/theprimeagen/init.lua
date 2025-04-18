require("theprimeagen.set")
require("theprimeagen.remap")

require("theprimeagen.lazy_init")

-- do.not
-- do not include this

-- if i want to keep doing lsp debugging
-- function restart_htmx_lsp()
--     require("lsp-debug-tools").restart({ expected = {}, name = "htmx-lsp", cmd = { "htmx-lsp", "--level", "debug" }, root_dir = vim.loop.cwd(), });
-- end

-- do not include this
-- do.not

local augroup = vim.api.nvim_create_augroup
local ThePrimeagenGroup = augroup('ThePrimeagen', {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

function R(name)
  require("plenary.reload").reload_module(name)
end

vim.filetype.add({
  extension = {
    templ = 'templ',
  }
})

vim.filetype.add({
  extension = {
    arb = "json",
  },
})

autocmd('TextYankPost', {
  group = yank_group,
  pattern = '*',
  callback = function()
    vim.highlight.on_yank({
      higroup = 'IncSearch',
      timeout = 40,
    })
  end,
})

autocmd({ "BufWritePre" }, {
  group = ThePrimeagenGroup,
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

autocmd('LspAttach', {
  group = ThePrimeagenGroup,
  callback = function(e)
    local opts = { buffer = e.buf }
    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
  end
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

-- undotree section
-- Undotree Persistent Configuration with path length fix
-- Function to create hash-based undo file paths for long paths
local function get_undo_dir()
  local undodir = vim.fn.expand('~/.undodir')
  if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, 'p', 448)
  end

  -- Get current file path
  local path = vim.fn.expand('%:p')
  if path == '' then
    return undodir
  end

  -- Use hash for long paths to avoid "Cannot open undo file for writing" errors
  local safe_path = string.gsub(path, '/', '%%')
  if string.len(safe_path) > 250 then
    -- Use a simple hash function for long paths
    local hash = 0
    for i = 1, #path do
      hash = (hash * 31 + string.byte(path, i)) % 1000000007
    end
    return undodir .. '/' .. hash
  end

  return undodir .. '/' .. safe_path
end

-- Enable persistent undo
vim.opt.undofile = true

-- Set undodir dynamically on buffer load/save to handle long paths
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufWritePre" }, {
  group = ThePrimeagenGroup, -- Fixed variable name capitalization
  pattern = "*",
  callback = function()
    vim.opt_local.undodir = get_undo_dir()
  end,
})

-- Configure undotree options
vim.g.undotree_SetFocusWhenToggle = 1
vim.g.undotree_WindowLayout = 2
vim.g.undotree_DiffAutoOpen = 1
vim.g.undotree_ShortIndicators = 1
vim.g.undotree_SplitWidth = 35
vim.g.undotree_DiffpanelHeight = 10
-- end undotree section

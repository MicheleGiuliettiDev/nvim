-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  if packer_bootstrap then
    require('packer').sync()
  end
  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.4',
    -- or                            , branch = '0.1.x',
    requires = { { 'nvim-lua/plenary.nvim' } }
  }

  use {
    'folke/tokyonight.nvim',
    config = function()
      -- Optionally configure the theme here
      vim.cmd('colorscheme tokyonight')
    end
  }

  use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })
  use('nvim-treesitter/playground')
  use('ThePrimeagen/harpoon')
  use 'mbbill/undotree'
  use('tpope/vim-fugitive')
  use('f-person/git-blame.nvim')
  use { "rcarriga/nvim-dap-ui", requires = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"} }

  -- LSP --
  use {
    'VonHeikemen/lsp-zero.nvim',
    requires = {
      --- Uncomment these if you want to manage LSP servers from neovim
      { 'williamboman/mason.nvim' },
      { 'williamboman/mason-lspconfig.nvim' },

      -- LSP Support
      { 'neovim/nvim-lspconfig' },
      -- Autocompletion
      { 'hrsh7th/nvim-cmp' },
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'L3MON4D3/LuaSnip' },
    }
  }

  -- Codeium --
  use 'Exafunction/codeium.vim'

  -- LSP Flutter --
  use {
    'akinsho/flutter-tools.nvim',
    requires = {
      'nvim-lua/plenary.nvim',
      'stevearc/dressing.nvim', -- optional for vim.ui.select
    },
  }

  use('dart-lang/dart-vim-plugin')
  use('thosakwe/vim-flutter')
  use 'mfussenegger/nvim-dap'
  use 'https://github.com/adelarsq/image_preview.nvim'
  use('junegunn/gv.vim')
end)

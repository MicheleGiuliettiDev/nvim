return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")

      -- List of languages to enable Tree-sitter for
      local langs = {
        "vimdoc", "javascript", "typescript", "c", "lua", "rust",
        "jsdoc", "bash", "go", "luadoc", "vim", "markdown"
      }

      -- Track parsers that failed or are already loaded
      local parsers_loaded = {}
      local parsers_pending = {}

      -- Auto-install missing parsers
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        callback = function(event)
          local ft = event.match
          if ft == "" then return end

          -- Get the language name from filetype
          local lang = vim.treesitter.language.get_lang(ft) or ft

          if not parsers_loaded[lang] then
            -- Try to install parser (no-op if already installed)
            ts.install({ lang })
            parsers_loaded[lang] = true
          end
        end,
      })

      -- Enable Tree-sitter highlighting and indentation
      local group = vim.api.nvim_create_augroup("TreesitterSetup", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = langs,
        callback = function(args)
          local buf = args.buf
          local ft = args.match

          -- Skip HTML files
          if ft == "html" then
            return
          end

          -- Skip large files
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            vim.notify(
              "File larger than 100KB treesitter disabled for performance",
              vim.log.levels.WARN,
              { title = "Treesitter" }
            )
            return
          end

          -- Get language from filetype
          local lang = vim.treesitter.language.get_lang(ft) or ft

          -- Try to add/load the language
          local lang_available = vim.treesitter.language.add(lang)

          if lang_available then
            -- Enable Tree-sitter highlighting
            vim.treesitter.start(buf, lang)

            -- Enable indentation if query exists
            if vim.treesitter.query.get(lang, "indents") then
              vim.bo[buf].indentexpr = "v:lua.vim.treesitter.indentexpr()"
            end
          end
        end,
      })

      -- Enable additional vim regex highlighting for markdown
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function(args)
          vim.bo[args.buf].syntax = "ON"
        end,
      })

      -- Register custom templ filetype
      vim.filetype.add({
        extension = {
          templ = "templ",
        },
      })

      -- Register templ language
      vim.treesitter.language.register("templ", "templ")

      -- Handle templ files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "templ",
        callback = function(args)
          local buf = args.buf

          -- Try to install templ parser
          ts.install({ "templ" })

          -- Try to load and start templ highlighting
          if vim.treesitter.language.add("templ") then
            vim.treesitter.start(buf, "templ")
          end
        end,
      })
    end
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("treesitter-context").setup({
        enable = true,
        multiwindow = false,
        max_lines = 0,
        min_window_height = 0,
        line_numbers = true,
        multiline_threshold = 20,
        trim_scope = "outer",
        mode = "cursor",
        separator = nil,
        zindex = 20,
        on_attach = nil,
      })
    end
  }
}


return {
	"stevearc/conform.nvim",
	opts = {},
	config = function()
		require("conform").setup({
			format_on_save = {
				timeout_ms = 5000,
				lsp_format = "fallback",
			},
			formatters_by_ft = {
				c = { "clang-format" },
				cpp = { "clang-format" },
				cs = { "csharpier" },
				csproj = { "csharpier" },
				lua = { "stylua" },
				dart = { "dart_format" },
				go = { "gofmt" },
				javascript = { "eslint_d", "prettierd", "prettier" },
				typescript = { "eslint_d", "prettierd", "prettier" },
				javascriptreact = { "eslint_d", "prettierd", "prettier" },
				typescriptreact = { "eslint_d", "prettierd", "prettier" },
				json = { "prettierd", "prettier" },
				markdown = { "prettierd", "prettier" },
				html = { "prettierd", "prettier" },
				css = { "prettierd", "prettier" },
				yaml = { "prettierd", "prettier" },
				elixir = { "mix" },
			},
			formatters = {
				["clang-format"] = {
					prepend_args = { "-style=file", "-fallback-style=LLVM" },
				},
			},
		})

		vim.keymap.set("n", "<leader>f", function()
			require("conform").format({ bufnr = 0, async = true, lsp_fallback = true })
		end)
	end,
}

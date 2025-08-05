return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken",
    opts = {
      model = 'gpt-4.1', -- AI model to use (corrected model name)
      temperature = 0.1, -- Lower = focused, higher = creative
      headers = {
        user = '👤 You: ',
        assistant = '🤖 Copilot: ',
        tool = '🔧 Tool: ',
      },
      separator = '━━',
      show_folds = false,
      auto_insert_mode = true, -- Enter insert mode when opening
    },
    keys = {
      { '<leader>cc', "<cmd>CopilotChatToggle<cr>", desc = "Toggle Copilot Chat" }
    }
  },
}

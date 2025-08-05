return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken",
    opts = {
      model = 'gpt-4',   -- AI model to use (corrected model name)
      temperature = 0.1, -- Lower = focused, higher = creative
      window = {
        layout = 'float',
        width = 80,         -- Fixed width in columns
        height = 20,        -- Fixed height in rows
        border = 'rounded', -- 'single', 'double', 'rounded', 'solid'
        title = '🤖 AI Assistant',
        zindex = 100,       -- Ensure window stays on top
      },
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

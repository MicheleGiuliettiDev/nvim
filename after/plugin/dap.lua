local dap = require('dap')

-- Dart / Flutter
dap.adapters.dart = {
  type = 'executable',
  command = vim.fn.stdpath('data')..'/mason/bin/dart-debug-adapter',
  args = {'dart'}
}
dap.adapters.flutter = {
  type = 'executable',
  command = vim.fn.stdpath('data')..'/mason/bin/dart-debug-adapter',
  args = {'flutter'}
}
dap.configurations.dart = {
  {
    type = "dart",
    request = "launch",
    name = "Launch dart",
    dartSdkPath = "/home/teamdev/snap/flutter/common/flutter/bin/cache/dart-sdk", -- ensure this is correct
    flutterSdkPath = "/home/teamdev/snap/flutter/common/flutter/bin",                  -- ensure this is correct
    program = "${workspaceFolder}/lib/main.dart",     -- ensure this is correct
    cwd = "${workspaceFolder}",
  },
  {
    type = "flutter",
    request = "launch",
    name = "Launch flutter",
    dartSdkPath = "/home/teamdev/snap/flutter/common/flutter/bin/cache/dart-sdk", -- ensure this is correct
    flutterSdkPath = "/home/teamdev/snap/flutter/common/flutter/bin",                  -- ensure this is correct
    program = "${workspaceFolder}/lib/main.dart",     -- ensure this is correct
    cwd = "${workspaceFolder}",
  } 
}

-- dotnet configuration --
dap.adapters.coreclr = {
  type = 'executable',
  command = os.getenv("HOME") .. "/.local/share/nvim/mason/packages/netcoredbg/netcoredbg",
  args = { '--interpreter=vscode' },
}

dap.configurations.cs = {
  {
    type = 'coreclr',
    name = 'launch - netcoredbg',
    request = 'launch',
    program = function()
      return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/Debug/', 'file')
    end,
    env = {
      DOTNET_ENVIRONMENT = "Development",
      ASPNETCORE_ENVIRONMENT = "Development",
    }
  },
}

dap.adapters["pwa-node"] = {
  type = "server",
  host = "localhost",
  port = "${port}",
  executable = {
    command = "node",
    -- 💀 Make sure to update this path to point to your installation
    args = {"/home/teamdev/.config/dap/js-debug/src/dapDebugServer.js", "${port}"},
  }
}

dap.configurations.javascript = {
  {
    type = "pwa-node",
    request = "launch",
    name = "Launch file",
    program = "${file}",
    cwd = "${workspaceFolder}",
  },
}


-- Set symbols for debugger
vim.api.nvim_set_hl(0, 'DapBreakpoint', { ctermbg = 0, fg = '#993939', bg = '#181622' })
vim.api.nvim_set_hl(0, 'DapLogPoint', { ctermbg = 0, fg = '#61afef', bg = '#181622' })
vim.api.nvim_set_hl(0, 'DapStopped', { ctermbg = 0, fg = '#98c379', bg = '#31353f' })

vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'DapBreakpoint' })
vim.fn.sign_define('DapBreakpointCondition', { text = 'ﳁ', texthl = 'DapBreakpoint' })
vim.fn.sign_define('DapBreakpointRejected', { text = '', texthl = 'DapBreakpoint' })
vim.fn.sign_define('DapLogPoint', { text = '', texthl = 'DapLogPoint' })
vim.fn.sign_define('DapStopped', { text = '', texthl = 'DapStopped', linehl = 'DapStopped', numhl = 'DapStopped' })

-- Debugger UI configurations
local dapui = require('dapui')

dapui.setup({
  icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
  mappings = {
    -- Use a table to apply multiple mappings
    expand = { "<CR>", "<2-LeftMouse>" },
    open = "o",
    remove = "d",
    edit = "e",
    repl = "r",
    toggle = "t",
  },
  -- Use this to override mappings for specific elements
  element_mappings = {
    -- Example:
    -- stacks = {
    --   open = "<CR>",
    --   expand = "o",
    -- }
  },
  -- Expand lines larger than the window
  -- Requires >= 0.7
  expand_lines = vim.fn.has("nvim-0.7") == 1,
  -- Layouts define sections of the screen to place windows.
  -- The position can be "left", "right", "top" or "bottom".
  -- The size specifies the height/width depending on position. It can be an Int
  -- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
  -- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
  -- Elements are the elements shown in the layout (in order).
  -- Layouts are opened in order so that earlier layouts take priority in window sizing.
  layouts = {
    {
      elements = {
        -- Elements can be strings or table with id and size keys.
        { id = "scopes", size = 0.25 },
        "breakpoints",
        "stacks",
        "watches",
      },
      size = 40, -- 40 columns
      position = "right",
    },
    {
      elements = {
        -- "console",
        "repl",
      },
      size = 0.25, -- 25% of total lines
      position = "bottom",
    },
  },
  controls = {
    -- Requires Neovim nightly (or 0.8 when released)
    enabled = true,
    -- Display controls in this element
    element = "repl",
    icons = {
      pause = "",
      play = "",
      step_into = "",
      step_over = "",
      step_out = "",
      step_back = "",
      run_last = "↻",
      terminate = "□",
    },
  },
  floating = {
    max_height = nil,  -- These can be integers or a float between 0 and 1.
    max_width = nil,   -- Floats will be treated as percentage of your screen.
    border = "single", -- Border style. Can be "single", "double" or "rounded"
    mappings = {
      close = { "q", "<Esc>" },
    },
  },
  windows = { indent = 1 },
  render = {
    max_type_length = nil, -- Can be integer or nil.
    max_value_lines = 100, -- Can be integer or nil.
  }
})

dap.listeners.before['initialize']['dapui_config'] = function()
  print("Starting debug session");
end

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  --dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  --dapui.close()
end


-- Some mappings to ease dap Use
vim.keymap.set('n', '<F5>', function() dap.continue() end)
vim.keymap.set('n', '<F3>', function() dap.restart() end)
vim.keymap.set('n', '<F4>', function() dap.run_last() end)
vim.keymap.set('n', '<F10>', function() dap.step_over() end)
vim.keymap.set('n', '<F11>', function() dap.step_into() end)
vim.keymap.set('n', '<F12>', function() dap.step_out() end)
vim.keymap.set('n', '<F9>', function() dap.toggle_breakpoint() end)
vim.keymap.set('n', '<leader>B', function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end)
vim.keymap.set('n', '<leader>lp', function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)

vim.keymap.set('n', '<F6>', function()
  dap.close()
  dapui.close()
end)
vim.keymap.set('n', '<leader>K', function()
  dapui.eval()
  dapui.eval()
end)

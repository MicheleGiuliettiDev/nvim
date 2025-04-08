return {
  "mfussenegger/nvim-dap", -- Required for debugging
  dependencies = {
    "theHamsta/nvim-dap-virtual-text",
    "rcarriga/nvim-dap-ui",
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    dapui.setup({})
    -- Eval var under cursor
    vim.keymap.set("n", "<leader>?", function()
      require("dapui").eval(nil, { enter = true })
    end)
    --
    vim.keymap.set('n', '<F5>', function() dap.continue() end)
    vim.keymap.set('n', '<F10>', function() dap.step_over() end)
    vim.keymap.set('n', '<F11>', function() dap.step_into() end)
    vim.keymap.set('n', '<F12>', function() dap.step_out() end)
    vim.keymap.set('n', '<leader>db', function() dap.toggle_breakpoint() end)

    dap.listeners.before.attach["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.launch["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end

    -- Enable virtual text
    vim.g.dap_virtual_text = true

    -- Dart Debug Adapter
    dap.adapters.dart = {
      type = "executable",
      command = vim.fn.stdpath("data") .. "/mason/bin/dart-debug-adapter", -- Ensure Mason installs this
      args = { "flutter" },                                                -- Use 'flutter' here for Flutter-specific debugging
    }

    dap.adapters.flutter = {
      type = "executable",
      command = vim.fn.stdpath("data") .. "/mason/bin/dart-debug-adapter", -- Ensure Mason installs this
      args = { "flutter" },                                                -- Use 'flutter' here for Flutter-specific debugging
    }

    -- Dart Debug Configurations
    dap.configurations.dart = {
      {
        type = "dart",
        request = "launch",
        name = "Launch Dart",
        dartSdkPath = vim.fn.expand("~") .. "/flutter/bin/cache/dart-sdk/", -- Update with your Flutter SDK path
        flutterSdkPath = vim.fn.expand("~") .. "/flutter",                  -- Update with your Flutter SDK path
        program = "${workspaceFolder}/lib/main.dart",                       -- Entry point of your Flutter app
        cwd = "${workspaceFolder}",                                         -- Project root directory
      },
      {
        type = "flutter",
        request = "launch",
        name = "Launch Flutter",
        dartSdkPath = vim.fn.expand("~") .. "/flutter/bin/cache/dart-sdk/", -- Update with your Flutter SDK path
        flutterSdkPath = vim.fn.expand("~") .. "/flutter",                  -- Update with your Flutter SDK path
        program = "${workspaceFolder}/lib/main.dart",                       -- Entry point of your Flutter app
        cwd = "${workspaceFolder}",                                         -- Project root directory
      }
    }

    dap.adapters.coreclr = {
      type = 'executable',
      command = vim.fn.expand("~") .. '/netcoredbg/netcoredbg',
      args = { '--interpreter=vscode' }
    }

    dap.configurations.cs = {
      {
        type = "coreclr",
        name = "launch - netcoredbg",
        request = "launch",
        program = function()
          return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/Debug/', 'file')
        end,
      },
    }
    -- Optional: Load `.vscode/launch.json` if available
    require("dap.ext.vscode").load_launchjs(nil, { dart = { "dart" } })
  end,
}

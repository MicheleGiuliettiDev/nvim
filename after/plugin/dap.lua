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

-- Dotnet --
dap.adapters.coreclr = {
  type = 'executable',
  command = '/home/m.giulietti@teamdev.it/.local/share/nvim/mason/packages/netcoredbg/netcoredbg',
  args = {'--interpreter=vscode'}
}

dap.configurations.cs = {
  {  
    type = 'coreclr',
    name = 'launch - netcoredbg',
    request = 'launch',
    program = function()
      return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/debug', 'file')
    end,
  }
}

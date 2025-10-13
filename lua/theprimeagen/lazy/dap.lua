return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "theHamsta/nvim-dap-virtual-text",
    "rcarriga/nvim-dap-ui",
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    -- ---------- Utils: resolve Flutter/Dart SDK via FVM or global ----------
    local function path_exists(p)
      return vim.loop.fs_stat(p) ~= nil
    end

    local function join(...)
      return table.concat({ ... }, package.config:sub(1,1))
    end

    local function expand(p) return vim.fn.expand(p) end

    local function get_flutter_roots()
      local cwd = vim.fn.getcwd()
      local fvm_flutter = join(cwd, ".fvm", "flutter_sdk")

      -- 1) Project-local FVM
      if path_exists(fvm_flutter) then
        return {
          flutter = fvm_flutter,
          dart = join(fvm_flutter, "bin", "cache", "dart-sdk")
        }
      end

      -- 2) Global (from PATH)
      local flutter_exe = vim.fn.exepath("flutter")
      if flutter_exe ~= nil and flutter_exe ~= "" then
        -- ex: /.../flutter/bin/flutter  -> go up two dirs to SDK root
        local flutter_bin = vim.fn.fnamemodify(flutter_exe, ":h")
        local flutter_root = vim.fn.fnamemodify(flutter_bin, ":h")
        return {
          flutter = flutter_root,
          dart = join(flutter_root, "bin", "cache", "dart-sdk")
        }
      end

      -- 3) Fallback to ~/flutter
      local home_flutter = join(expand("~"), "flutter")
      return {
        flutter = home_flutter,
        dart = join(home_flutter, "bin", "cache", "dart-sdk")
      }
    end

    local function dart_sdk_path() return get_flutter_roots().dart end
    local function flutter_sdk_path() return get_flutter_roots().flutter end
    -- ----------------------------------------------------------------------

    dapui.setup({})
    vim.keymap.set("n", "<leader>?", function() require("dapui").eval(nil, { enter = true }) end)
    vim.keymap.set('n', '<F5>', function() dap.continue() end)
    vim.keymap.set('n', '<F10>', function() dap.step_over() end)
    vim.keymap.set('n', '<F11>', function() dap.step_into() end)
    vim.keymap.set('n', '<F12>', function() dap.step_out() end)
    vim.keymap.set('n', '<leader>db', function() dap.toggle_breakpoint() end)

    dap.listeners.before.attach["dapui_config"] = function() dapui.open() end
    dap.listeners.before.launch["dapui_config"] = function() dapui.open() end
    dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
    dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
    dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

    vim.g.dap_virtual_text = true

    -- Dart/Flutter adapters via Mason's dart-debug-adapter
    local adapter_cmd = vim.fn.stdpath("data") .. "/mason/bin/dart-debug-adapter"
    dap.adapters.dart = { type = "executable", command = adapter_cmd, args = { "flutter" } }
    dap.adapters.flutter = { type = "executable", command = adapter_cmd, args = { "flutter" } }

    -- Use functions so paths are resolved at launch time per-project
    dap.configurations.dart = {
      {
        type = "dart",
        request = "launch",
        name = "Launch Dart",
        dartSdkPath = dart_sdk_path,        -- <- FVM or global
        flutterSdkPath = flutter_sdk_path,  -- <- FVM or global
        program = "${workspaceFolder}/lib/main.dart",
        cwd = "${workspaceFolder}",
      },
      {
        type = "flutter",
        request = "launch",
        name = "Launch Flutter",
        dartSdkPath = dart_sdk_path,        -- <- FVM or global
        flutterSdkPath = flutter_sdk_path,  -- <- FVM or global
        program = "${workspaceFolder}/lib/main.dart",
        cwd = "${workspaceFolder}",
      },
    }

    -- .NET (unchanged)
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

    -- Load launch.json if present
    require("dap.ext.vscode").load_launchjs(nil, { dart = { "dart" } })
  end,
}


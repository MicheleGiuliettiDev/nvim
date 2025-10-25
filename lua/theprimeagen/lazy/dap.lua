return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "theHamsta/nvim-dap-virtual-text",
    "rcarriga/nvim-dap-ui",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    -- ---------- Utils: resolve Flutter/Dart SDK via FVM or global ----------
    local function path_exists(p)
      return vim.loop.fs_stat(p) ~= nil
    end

    local function join(...)
      return table.concat({ ... }, package.config:sub(1, 1))
    end

    local function expand(p)
      return vim.fn.expand(p)
    end

    local function get_flutter_roots()
      local cwd = vim.fn.getcwd()
      local fvm_flutter = join(cwd, ".fvm", "flutter_sdk")

      if path_exists(fvm_flutter) then
        return {
          flutter = fvm_flutter,
          dart = join(fvm_flutter, "bin", "cache", "dart-sdk"),
        }
      end

      local flutter_exe = vim.fn.exepath("flutter")
      if flutter_exe ~= nil and flutter_exe ~= "" then
        local flutter_bin = vim.fn.fnamemodify(flutter_exe, ":h")
        local flutter_root = vim.fn.fnamemodify(flutter_bin, ":h")
        return {
          flutter = flutter_root,
          dart = join(flutter_root, "bin", "cache", "dart-sdk"),
        }
      end

      local home_flutter = join(expand("~"), "flutter")
      return {
        flutter = home_flutter,
        dart = join(home_flutter, "bin", "cache", "dart-sdk"),
      }
    end

    local function dart_sdk_path()
      return get_flutter_roots().dart
    end

    local function flutter_sdk_path()
      return get_flutter_roots().flutter
    end
    -- ----------------------------------------------------------------------

    -- DAP UI Setup
    dapui.setup({})

    -- Keymaps
    vim.keymap.set("n", "<leader>?", function()
      require("dapui").eval(nil, { enter = true })
    end)
    vim.keymap.set("n", "<F5>", function() dap.continue() end)
    vim.keymap.set("n", "<F10>", function() dap.step_over() end)
    vim.keymap.set("n", "<F11>", function() dap.step_into() end)
    vim.keymap.set("n", "<F12>", function() dap.step_out() end)
    vim.keymap.set("n", "<leader>db", function() dap.toggle_breakpoint() end)

    -- DAP UI auto-open/close listeners
    dap.listeners.before.attach["dapui_config"] = function() dapui.open() end
    dap.listeners.before.launch["dapui_config"] = function() dapui.open() end
    dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
    dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
    dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

    vim.g.dap_virtual_text = true

    -- ======================== DART/FLUTTER CONFIG ========================
    local adapter_cmd = vim.fn.stdpath("data") .. "/mason/bin/dart-debug-adapter"

    dap.adapters.dart = {
      type = "executable",
      command = adapter_cmd,
      args = { "flutter" },
    }

    dap.adapters.flutter = {
      type = "executable",
      command = adapter_cmd,
      args = { "flutter" },
    }

    dap.configurations.dart = {
      {
        type = "dart",
        request = "launch",
        name = "Launch Dart",
        dartSdkPath = dart_sdk_path,
        flutterSdkPath = flutter_sdk_path,
        program = "${workspaceFolder}/lib/main.dart",
        cwd = "${workspaceFolder}",
      },
      {
        type = "flutter",
        request = "launch",
        name = "Launch Flutter",
        dartSdkPath = dart_sdk_path,
        flutterSdkPath = flutter_sdk_path,
        program = "${workspaceFolder}/lib/main.dart",
        cwd = "${workspaceFolder}",
      },
    }

    -- ======================== .NET CONFIG ========================
    dap.adapters.coreclr = {
      type = "executable",
      command = "/usr/bin/netcoredbg",
      args = { "--interpreter=vscode" },
    }

    -- --- Get ALL project names from every *.sln under repo; fallback to *.csproj
    local function get_project_tokens()
      local cwd = vim.fn.getcwd()
      local tokens = {}

      local function add_token(s)
        if not s or s == "" then return end
        tokens[s:lower()] = true
      end

      -- read every solution in tree
      local slns = vim.fn.globpath(cwd, "**/*.sln", false, true)
      for _, sln in ipairs(slns) do
        local ok, lines = pcall(vim.fn.readfile, sln)
        if ok and lines then
          for _, line in ipairs(lines) do
            -- Project("{GUID}") = "Name", "path/Name.csproj", "{GUID}"
            local pname, ppath = line:match('^%s*Project%(%b()%s*=%s*"([^"]+)"%s*,%s*"([^"]+)"')
            if pname then
              add_token(pname)
              add_token((vim.fn.fnamemodify(ppath, ":t") or ""):gsub("%.csproj$", ""))
              add_token(vim.fn.fnamemodify(ppath, ":h:t"))
            end
          end
        end
      end

      -- fallback: scan csproj files if no tokens yet
      if next(tokens) == nil then
        local csprojs = vim.fn.globpath(cwd, "**/*.csproj", false, true)
        for _, p in ipairs(csprojs) do
          add_token((vim.fn.fnamemodify(p, ":t") or ""):gsub("%.csproj$", ""))
          add_token(vim.fn.fnamemodify(p, ":h:t"))
        end
      end

      return tokens
    end

    -- helper: plain-exec check
    local function has_exec(cmd) return vim.fn.executable(cmd) == 1 end

    -- helpers for matching “whole-ish” token pieces (dir/file boundaries or separators)
    local function escape_lua_pattern(s)
      return (s:gsub("(%W)","%%%1"))
    end

    local function contains_token_smart(path_lower, token_lower)
      -- treat separators as boundaries
      local sep = "[/\\._%-]"
      local t = escape_lua_pattern(token_lower)
      -- exact filename or directory already handled elsewhere; here do boundary-aware find
      local patterns = {
        sep .. t .. sep,      -- /Overflow/
        "^" .. t .. sep,      -- start with token/
        sep .. t .. "$",      -- /token end
        sep .. t .. "%.",     -- /token.ext
      }
      for _, pat in ipairs(patterns) do
        if path_lower:find(pat) then return true end
      end
      -- fallback: simple substring
      return path_lower:find(t, 1, true) ~= nil
    end

    dap.configurations.cs = {
      {
        type = "coreclr",
        name = "launch - netcoredbg",
        request = "launch",
        program = function()
          local pickers = require("telescope.pickers")
          local finders = require("telescope.finders")
          local conf = require("telescope.config").values
          local actions = require("telescope.actions")
          local action_state = require("telescope.actions.state")

          local root = vim.fn.getcwd()

          local search_roots = {
            root .. "/bin/Debug",
            root .. "/bin/Release",
            root .. "/bin",
            root,
          }

          local function collect_results()
            local all = {}

            for _, base in ipairs(search_roots) do
              if vim.fn.isdirectory(base) == 1 then
                if has_exec("fd") then
                  local cmd = string.format("fd --type f --extension dll --hidden --follow --absolute-path . '%s'", base)
                  local out = vim.fn.systemlist(cmd)
                  for _, p in ipairs(out or {}) do
                    if p ~= "" then table.insert(all, p) end
                  end
                elseif has_exec("find") then
                  local out = vim.fn.systemlist({ "find", base, "-type", "f", "-name", "*.dll" })
                  for _, p in ipairs(out or {}) do
                    if p ~= "" then table.insert(all, p) end
                  end
                else
                  local list = vim.fn.glob(base .. "/**/*.dll", true, true)
                  for _, p in ipairs(list or {}) do
                    table.insert(all, p)
                  end
                end
              end
            end

            -- dedupe
            local seen, unique = {}, {}
            for _, p in ipairs(all) do
              if not seen[p] then
                seen[p] = true
                table.insert(unique, p)
              end
            end
            return unique
          end

          local results = collect_results()
          if #results == 0 then
            vim.notify("No DLLs found. Did you run `dotnet build`?", vim.log.levels.WARN)
            return vim.fn.input("Path to dll: ", root .. "/bin/Debug/", "file")
          end

          -- --- PRIORITY SORT: all project-name matches first
          local tokens = get_project_tokens()

          local function score(path)
            local lower = path:lower()
            local file = vim.fn.fnamemodify(lower, ":t")
            local name = file:gsub("%.dll$", "")
            local dir  = vim.fn.fnamemodify(lower, ":h:t")

            local exact, parent, contains = 0, 0, 0
            for token, _ in pairs(tokens) do
              if token == name then
                exact = 1
              end
              if token == dir then
                parent = math.max(parent, 1)
              end
              if contains_token_smart(lower, token) then
                contains = 1
              end
            end

            -- Ensure “Overflow” (as a project token) truly floats to the very top:
            -- exact dll name match >> parent dir match >> boundary contains
            -- The tuple is sorted descending lexicographically.
            return exact, parent, contains, -#lower
          end

          table.sort(results, function(a, b)
            local ea, pa, ca, la = score(a)
            local eb, pb, cb, lb = score(b)
            if ea ~= eb then return ea > eb end
            if pa ~= pb then return pa > pb end
            if ca ~= cb then return ca > cb end
            if la ~= lb then return la > lb end
            return a < b
          end)

          -- Auto-pick single result
          if #results == 1 then
            vim.notify("Auto-selected: " .. results[1], vim.log.levels.INFO)
            return results[1]
          end

          -- Multiple DLLs: Telescope picker
          return coroutine.create(function(coro)
            pickers.new({}, {
              prompt_title = "Select DLL to Debug",
              finder = finders.new_table {
                results = results,
                entry_maker = function(entry)
                  return {
                    value = entry,
                    display = vim.fn.fnamemodify(entry, ":t") .. " (" .. vim.fn.fnamemodify(entry, ":h:t") .. ")",
                    ordinal = entry,
                  }
                end,
              },
              sorter = conf.generic_sorter({}),
              attach_mappings = function(prompt_bufnr, _)
                actions.select_default:replace(function()
                  actions.close(prompt_bufnr)
                  local selection = action_state.get_selected_entry()
                  coroutine.resume(coro, selection.value)
                end)
                return true
              end,
            }):find()
          end)
        end,
      },
    }

    -- Load launch.json if present
    require("dap.ext.vscode").load_launchjs(nil, { dart = { "dart" } })
  end,
}


-----------------------------------------------------------
-- AI Assistant Plugins
-----------------------------------------------------------

return {
  {
    "nickjvandyke/opencode.nvim",
    version = "*", -- Latest stable release
    dependencies = {
      {
        ---@module "snacks" <- Loads `snacks.nvim` types for configuration intellisense
        "folke/snacks.nvim",
        opts = {
          input = {}, -- Enhances `ask()`
          picker = { -- Enhances `select()`
            actions = {
              opencode_send = function(...) return require("opencode").snacks_picker_send(...) end,
            },
            win = {
              input = {
                keys = {
                  -- Snacks picker 中將選取項目送到 opencode
                  ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
                },
              },
            },
          },
        },
      },
    },
    keys = {
      {
        "<leader>oa",
        function() require("opencode").ask("@this: ", { submit = true }) end,
        mode = { "n", "x" },
        desc = "Ask opencode…",
      },
      {
        "<leader>os",
        function() require("opencode").select() end,
        mode = { "n", "x" },
        desc = "Select opencode action",
      },
    },
    init = function()
      -- :OpencodeStart - 在 Neovim 當前 cwd 開啟一個外部終端並執行 opencode
      -- 註冊在 init 區塊以確保開機後立即可用，不需先觸發 plugin lazy load
      vim.api.nvim_create_user_command("OpencodeStart", function()
        local platform = require("utils.platform")
        local cwd = vim.fn.getcwd()
        local port = 8299
        local args

        if platform.is_win then
          args = {
            "cmd", "/c",
            "start", "opencode (port " .. port .. ")",
            "cmd", "/k",
            string.format('cd /d "%s" && opencode --port %d', cwd, port),
          }
        elseif platform.is_mac then
          -- 透過 osascript 開啟一個新的 Terminal 視窗執行 opencode
          local script = string.format(
            'tell application "Terminal" to do script "cd \\"%s\\" && opencode --port %d"',
            cwd, port
          )
          args = { "osascript", "-e", script, "-e", 'tell application "Terminal" to activate' }
        else
          -- Linux：嘗試以常見終端機開啟（找得到哪個就用哪個）
          local term_candidates = {
            { "x-terminal-emulator", "-e" },
            { "gnome-terminal", "--" },
            { "konsole", "-e" },
            { "xterm", "-e" },
          }
          local cmd_str = string.format('cd "%s" && opencode --port %d; exec $SHELL', cwd, port)
          for _, t in ipairs(term_candidates) do
            if vim.fn.executable(t[1]) == 1 then
              args = { t[1], t[2], "sh", "-c", cmd_str }
              break
            end
          end
          if not args then
            MyNotify("OpencodeStart: 找不到可用的終端機（x-terminal-emulator/gnome-terminal/konsole/xterm）", "warn")
            return
          end
        end

        vim.fn.jobstart(args, { detach = true })
        MyNotify("已在外部終端啟動 opencode：" .. cwd)
      end, { desc = "Start opencode in external terminal at Neovim's cwd" })
    end,
    config = function()
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        port = 8299,
        -- 不在 Neovim 內開啟 opencode 終端，
        -- 改為連線到外部終端執行的 opencode（請使用 :OpencodeStart 啟動）
        server = {
          start  = function() end,
          stop   = function() end,
          toggle = function() end,
        },
      }
    end,
  },
}

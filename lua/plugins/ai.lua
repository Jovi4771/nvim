-----------------------------------------------------------
-- AI Assistant Plugins
-----------------------------------------------------------

-- 為每個 Neovim instance 算出一個獨立 port，讓多開的 nvim 不會搶同一個
-- opencode server。pid 取 mod 1000 撞號機率不高，但理論上仍可能撞，
-- 真有需要可改為探測 port 是否被占用後挑下一個。
-- 抽到模組層讓 init / config 兩塊共用同一個值，避免兩處重複計算且日後改不同步。
local pid = vim.fn.getpid()
local port = 4000 + (pid % 1000)
local opencode_cmd = "opencode --port " .. port

return {
  {
    -- Upstream owner 實際大小寫為 NickvanDyke（GitHub username 不分大小寫，
    -- 但寫法跟 upstream 一致，方便對 issue/release）
    "NickvanDyke/opencode.nvim",
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
    -----------------------------------------------------------
    -- 本檔案刻意保留兩種啟動模式，請勿合併：
    --
    -- 1. :OpencodeStart（init 區塊）
    --    在「外部終端」開一個獨立視窗跑 opencode。適合想把 opencode
    --    留在背景持續使用、或不希望佔用 Neovim 視窗 split 的情境。
    --
    -- 2. opencode.nvim 預設流程（config 區塊裡的 server.start/stop/toggle）
    --    透過 snacks.terminal 在「Neovim 內部 split」開 opencode。
    --    適合純 prompt → response 流程，跟編輯器整合度高。
    --
    -- 兩者用同一個 port，所以同一時間只啟動其中一種即可，否則第二個
    -- opencode process 會因為 port 被占用而起不來。
    -----------------------------------------------------------
    init = function()
      -- :OpencodeStart - 在 Neovim 當前 cwd 開啟一個外部終端並執行 opencode
      -- 註冊在 init 區塊以確保開機後立即可用，不需先觸發 plugin lazy load
      vim.api.nvim_create_user_command("OpencodeStart", function()
        local platform = require("utils.platform")
        local cwd = vim.fn.getcwd()
        local job_input -- 可為 list 或 string，jobstart 兩種都接受

        if platform.is_win then
          -- Windows: 用 string 形式呼叫 jobstart，避免 list 形式對 `&&` 與引號
          -- 的處理不確定（jobstart 在 Windows 會把含特殊字元的 list 元素加引號
          -- 並把內部 `"` 轉成 `\"`，但 cmd 不認 `\"`，會導致解析錯亂）。
          -- cmd 在 "..." 內用 "" 表示字面引號，不是 C runtime 的 \"
          local cwd_q = cwd:gsub('"', '""')
          job_input = string.format(
            'cmd /c start "opencode (port %d)" cmd /k "cd /d ""%s"" && opencode --port %d"',
            port, cwd_q, port
          )
        elseif platform.is_mac then
          -- 透過 osascript 開啟一個新的 Terminal 視窗執行 opencode
          local script = string.format(
            'tell application "Terminal" to do script "cd \\"%s\\" && opencode --port %d"',
            cwd, port
          )
          job_input = { "osascript", "-e", script, "-e", 'tell application "Terminal" to activate' }
        else
          -- Linux：嘗試以常見終端機開啟（找得到哪個就用哪個）
          --
          -- 不同終端對「-e + 命令」的解讀不一致：
          --   - x-terminal-emulator (Debian alt)：-e 通常只吃「單一字串」，
          --     底層連到不同 emulator 時對多 args 行為不同
          --   - gnome-terminal：用 `--` 結束參數，後面才是命令 + 多個 args
          --   - konsole / xterm：-e 後面可以接多個 args
          local cmd_str = string.format('cd "%s" && opencode --port %d; exec $SHELL', cwd, port)

          if vim.fn.executable("x-terminal-emulator") == 1 then
            -- 包成單一字串塞給 sh -c，避開 -e 多 args 的不一致
            local escaped = cmd_str:gsub("'", "'\\''")
            job_input = { "x-terminal-emulator", "-e", "sh -c '" .. escaped .. "'" }
          elseif vim.fn.executable("gnome-terminal") == 1 then
            job_input = { "gnome-terminal", "--", "sh", "-c", cmd_str }
          elseif vim.fn.executable("konsole") == 1 then
            job_input = { "konsole", "-e", "sh", "-c", cmd_str }
          elseif vim.fn.executable("xterm") == 1 then
            job_input = { "xterm", "-e", "sh", "-c", cmd_str }
          else
            MyNotify("OpencodeStart: 找不到可用的終端機（x-terminal-emulator/gnome-terminal/konsole/xterm）", "warn")
            return
          end
        end

        vim.fn.jobstart(job_input, { detach = true })
        MyNotify("已在外部終端啟動 opencode：" .. cwd, "info")
      end, { desc = "Start opencode in external terminal at Neovim's cwd" })
    end,
    config = function()
      ---@type snacks.terminal.Opts
      local snacks_terminal_opts = {
        win = {
          position = 'right',
          enter = false,
          on_win = function(win)
            require('opencode.terminal').setup(win.win)
          end,
        },
      }

      ---@type opencode.Opts
      -- 直接設定 vim.g，並確保 server 參數正確
      vim.g.opencode_opts = {
        server = {
          port = port, -- 告訴插件連線到哪個 Port

          -- 使用模組層預先計算好的 opencode_cmd 啟動
          start = function()
            require('snacks.terminal').open(opencode_cmd, snacks_terminal_opts)
          end,
          stop = function()
            -- 確保關閉時是用正確的 cmd 找回 terminal 實例
            local term = require('snacks.terminal').get(opencode_cmd, snacks_terminal_opts)
            if term then term:close() end
          end,
          toggle = function()
            require('snacks.terminal').toggle(opencode_cmd, snacks_terminal_opts)
          end,
        },
      }
    end,
  },
}

-----------------------------------------------------------
-- AI Assistant Plugins
-----------------------------------------------------------

local pid = vim.fn.getpid()
local uv = vim.uv or vim.loop
local port_lock_root = vim.fs.joinpath(vim.fn.stdpath("state"), "opencode", "ports")
vim.fn.mkdir(port_lock_root, "p")

local function lock_owner_alive(owner_pid)
  local ok, result, errname = pcall(uv.kill, owner_pid, 0)
  if not ok or result == 0 then return true end
  return errname ~= "ESRCH"
end

local function claim_port(candidate)
  local lock_path = vim.fs.joinpath(port_lock_root, tostring(candidate))
  local owner_path = vim.fs.joinpath(lock_path, "owner")

  local function create_lock()
    if vim.fn.mkdir(lock_path) ~= 1 then return false end
    if vim.fn.writefile({ tostring(pid) }, owner_path) ~= 0 then
      vim.fn.delete(lock_path, "rf")
      return false
    end

    vim.api.nvim_create_autocmd("VimLeavePre", {
      once = true,
      callback = function() vim.fn.delete(lock_path, "rf") end,
    })
    return true
  end

  if create_lock() then return true end

  local owner = tonumber(vim.fn.readfile(owner_path)[1])
  if not owner or lock_owner_alive(owner) then return false end

  vim.fn.delete(lock_path, "rf")
  return create_lock()
end

local function allocate_port()
  for _ = 1, 64 do
    local socket = uv.new_tcp()
    if socket then
      local bind_result = socket:bind("127.0.0.1", 0)
      local address = bind_result == 0 and socket:getsockname() or nil
      socket:close()

      if address and address.port > 0 and claim_port(address.port) then
        return address.port
      end
    end
  end

  error("無法為這個 Neovim instance 配置專屬 OpenCode port")
end

local port = allocate_port()
local opencode_url = string.format("http://127.0.0.1:%d", port)

-- 每個 Neovim instance 綁定自己的 session，避免 ask() 打進另一個 instance 的 TUI。
-- OpenCode 免費模型只接受 server 自行產生的 session ID；不能自訂 ID。
-- 用暫存檔在 Lua 與外部啟動器之間傳遞同一個官方 ID。
local opencode_session_file = vim.fn.tempname() .. ".opencode-session"
local opencode_session_title = "Neovim " .. pid
local opencode_session
local opencode_session_pending
local opencode_launcher_started = false

local function shell_quote(value)
  return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function ensure_opencode_password()
  local password = vim.env.OPENCODE_SERVER_PASSWORD
  if not password or password == "" then password = vim.env.OPENCODE_PASSWORD end

  if not password or password == "" then
    local uv = vim.uv or vim.loop
    if not uv or not uv.random then error("無法產生 OpenCode 密碼，請設定 OPENCODE_PASSWORD") end

    local ok, bytes = pcall(uv.random, 32)
    if not ok or not bytes then error("無法產生 OpenCode 密碼，請設定 OPENCODE_PASSWORD") end
    password = bytes:gsub(".", function(byte) return string.format("%02x", byte:byte()) end)
  end

  vim.env.OPENCODE_PASSWORD = password
  vim.env.OPENCODE_SERVER_PASSWORD = password
  return password
end

local function posix_password_file()
  local path = vim.fn.tempname() .. ".env"
  local result = vim.fn.writefile({}, path)
  if result ~= 0 or vim.fn.setfperm(path, "rw-------") ~= 0 then
    vim.fn.delete(path)
    error("無法建立 OpenCode 密碼暫存檔")
  end

  local password = ensure_opencode_password()
  result = vim.fn.writefile({
    "export OPENCODE_PASSWORD=" .. shell_quote(password),
    "export OPENCODE_SERVER_PASSWORD=" .. shell_quote(password),
  }, path)
  if result ~= 0 then
    vim.fn.delete(path)
    error("無法寫入 OpenCode 密碼暫存檔")
  end

  vim.defer_fn(function() vim.fn.delete(path) end, 300000)
  return path
end

local function posix_session_command(cwd, password_file)
  ensure_opencode_password()
  opencode_launcher_started = true
  local cd_command = cwd and ("cd " .. shell_quote(cwd) .. " || exit 1; ") or ""
  local password_command = ""
  if password_file then
    local quoted_path = shell_quote(password_file)
    password_command = string.format(
      "if [ -r %s ]; then . %s; rm -f %s; else echo 'OpenCode password file is unavailable'; exit 1; fi; ",
      quoted_path,
      quoted_path,
      quoted_path
    )
  end

  local create_body = '{"title":' .. vim.fn.json_encode(opencode_session_title) .. '}'
  return string.format(
    "%s%sopencode serve --hostname 127.0.0.1 --port %d >/dev/null 2>&1 & server_pid=$!; " ..
      "trap 'kill \"$server_pid\" 2>/dev/null || true' EXIT; " ..
      "url='%s'; auth=\"${OPENCODE_SERVER_USERNAME:-opencode}:$OPENCODE_PASSWORD\"; ready=0; attempt=0; " ..
      "while [ \"$attempt\" -lt 50 ]; do " ..
      "if curl -sS --max-time 1 --user \"$auth\" -o /dev/null \"$url/api/info\"; then ready=1; break; fi; " ..
      "attempt=$((attempt + 1)); sleep 0.2; done; " ..
      "if [ \"$ready\" -ne 1 ]; then echo 'OpenCode server did not start'; exit 1; fi; " ..
      "session_file=%s; session_id=''; " ..
      "if [ -s \"$session_file\" ]; then session_id=$(tr -d '\\r\\n' < \"$session_file\"); fi; " ..
      "if [ -n \"$session_id\" ] && ! curl -sS --max-time 2 --fail --user \"$auth\" -o /dev/null \"$url/api/session/$session_id\"; then session_id=''; fi; " ..
      "if [ -z \"$session_id\" ]; then " ..
      "response=$(curl -sS --max-time 5 --user \"$auth\" -H 'Content-Type: application/json' -H \"x-opencode-directory: $PWD\" -d %s \"$url/api/session\") || { printf '%%s\\n' \"$response\"; echo 'OpenCode session creation failed'; exit 1; }; " ..
      "session_id=$(printf '%%s' \"$response\" | sed -n 's/.*\"id\":[[:space:]]*\"\\(ses_[^\"]*\\)\".*/\\1/p'); " ..
      "if [ -z \"$session_id\" ]; then echo 'OpenCode session ID not found'; exit 1; fi; " ..
      "printf '%%s' \"$session_id\" > \"$session_file\"; " ..
      "fi; " ..
      "opencode --server \"$url\" --session \"$session_id\"",
    cd_command,
    password_command,
    port,
    opencode_url,
    shell_quote(opencode_session_file),
    shell_quote(create_body)
  )
end

local function windows_session_command(cwd, keep_open)
  ensure_opencode_password()
  opencode_launcher_started = true
  local script = [[
param([int]$Port, [string]$WorkingDirectory, [string]$SessionFile, [string]$Title)
$ErrorActionPreference = "Stop"
$server = $null
try {
  Set-Location -LiteralPath $WorkingDirectory
  $url = "http://127.0.0.1:$Port"
  $server = Start-Process -FilePath "cmd.exe" -ArgumentList "/c opencode serve --hostname 127.0.0.1 --port $Port" -WorkingDirectory $WorkingDirectory -WindowStyle Hidden -PassThru
  $username = $env:OPENCODE_SERVER_USERNAME
  if ([string]::IsNullOrEmpty($username)) { $username = "opencode" }
  $auth = "Basic " + [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("${username}:$($env:OPENCODE_PASSWORD)"))
  $headers = @{ Authorization = $auth; "x-opencode-directory" = $WorkingDirectory }
  $ready = $false
  for ($attempt = 0; $attempt -lt 50; $attempt++) {
    try {
      Invoke-WebRequest -Uri "$url/api/info" -Headers $headers -UseBasicParsing -TimeoutSec 2 | Out-Null
      $ready = $true
      break
    } catch {
      Start-Sleep -Milliseconds 200
    }
  }
  if (-not $ready) { throw "OpenCode server did not start on port $Port" }
  $sessionID = $null
  if (Test-Path -LiteralPath $SessionFile) {
    $sessionContent = Get-Content -LiteralPath $SessionFile -Raw -ErrorAction SilentlyContinue
    if ($null -ne $sessionContent) { $sessionID = $sessionContent.Trim() }
  }
  if (-not [string]::IsNullOrEmpty($sessionID)) {
    try {
      Invoke-RestMethod -Uri "$url/api/session/$sessionID" -Method Get -Headers $headers -TimeoutSec 2 | Out-Null
    } catch {
      $sessionID = $null
    }
  }
  if ([string]::IsNullOrEmpty($sessionID)) {
    $body = @{ title = $Title } | ConvertTo-Json -Compress
    $created = Invoke-RestMethod -Uri "$url/api/session" -Method Post -Headers $headers -ContentType "application/json" -Body $body
    $sessionID = $created.data.id
    if ([string]::IsNullOrEmpty($sessionID)) { throw "OpenCode session creation failed" }
    [IO.File]::WriteAllText($SessionFile, $sessionID)
  }
  opencode --server $url --session $sessionID
} finally {
  if ($server -and -not $server.HasExited) { taskkill.exe /PID $server.Id /T /F | Out-Null }
  Remove-Item -LiteralPath $PSCommandPath -Force -ErrorAction SilentlyContinue
}
]]
  local script_path = vim.fn.tempname() .. ".ps1"
  local write_result = vim.fn.writefile(vim.split(script, "\n"), script_path)
  if write_result ~= 0 then error("無法建立 OpenCode 啟動腳本：" .. script_path) end

  local no_exit = keep_open and "-NoExit " or ""
  local cwd_arg = cwd:gsub('"', '""')
  local session_file_arg = opencode_session_file:gsub('"', '""')
  return string.format(
    'powershell -NoProfile %s-ExecutionPolicy Bypass -File "%s" -Port %d -WorkingDirectory "%s" -SessionFile "%s" -Title "%s"',
    no_exit,
    script_path,
    port,
    cwd_arg,
    session_file_arg,
    opencode_session_title
  )
end

local function opencode_session_command(cwd)
  local platform = require("utils.platform")
  if platform.is_win then return windows_session_command(cwd, false) end
  return posix_session_command(cwd, posix_password_file())
end

local opencode_ask_pending = false
local opencode_server_pending

local function probe_opencode(url)
  local Promise = require("opencode.promise")
  local platform = require("utils.platform")
  local server_opts = require("opencode.config").opts.server
  local cmd = {
    "curl",
    "-sS",
    "--max-time",
    "1",
    "--output",
    platform.is_win and "NUL" or "/dev/null",
    "--write-out",
    "%{http_code}",
  }

  if server_opts.password and server_opts.password ~= "" then
    vim.list_extend(cmd, { "--user", (server_opts.username or "opencode") .. ":" .. server_opts.password })
  end
  table.insert(cmd, url .. "/api/info")

  return Promise.new(function(resolve)
    local response = {}
    local job = vim.fn.jobstart(cmd, {
      stdout_buffered = true,
      on_stdout = function(_, data)
        if data then
          for _, line in ipairs(data) do
            if line ~= "" then table.insert(response, line) end
          end
        end
      end,
      on_exit = function(_, code)
        resolve({ code = code, status = table.concat(response) })
      end,
    })

    if job <= 0 then resolve({ code = job, status = "000" }) end
  end)
end

local function ensure_opencode_session(server)
  local Promise = require("opencode.promise")
  if opencode_session then return Promise.resolve(opencode_session) end
  if opencode_session_pending then return opencode_session_pending end

  local function read_session_id()
    if vim.fn.filereadable(opencode_session_file) ~= 1 then return nil end
    local ok, lines = pcall(vim.fn.readfile, opencode_session_file)
    if not ok or not lines or not lines[1] then return nil end
    local id = vim.trim(lines[1])
    if id == "" then return nil end
    return id
  end

  local function write_session_id(id)
    local ok, result = pcall(vim.fn.writefile, { id }, opencode_session_file)
    if not ok or result ~= 0 then
      vim.notify("無法寫入 OpenCode session 暫存檔：" .. opencode_session_file, vim.log.levels.WARN, { title = "opencode" })
    end
  end

  local function fetch_session(id)
    return server:request("/api/session/" .. id, "GET"):next(function(response)
      return response and response.data or nil
    end)
  end

  local function create_session()
    -- 不要帶 id；OpenCode 免費模型只接受 server 自行產生的 session ID。
    return server:request("/api/session", "POST", {
      title = opencode_session_title,
      location = { directory = vim.fn.getcwd() },
    }):next(function(response)
      local session = response and response.data
      if not session or not session.id then
        return Promise.reject("OpenCode session 建立失敗")
      end
      write_session_id(session.id)
      return session
    end)
  end

  local function pin_session(session)
    if not session or not session.id then
      return Promise.reject("OpenCode session 建立失敗")
    end
    opencode_session = session

    -- 全域 default_agent 是 plan；從 nvim 開啟時固定改用 build agent。
    -- 只在首次 pin 時執行，之後使用者在 TUI 手動切的 agent 不會被蓋掉；
    -- 切換失敗不影響 session 繼續使用。
    return server:request("/api/session/" .. session.id .. "/agent", "POST", { agent = "build" })
      :catch(function() end)
      :next(function()
        return session
      end)
  end

  local function use_existing_or_create()
    local id = read_session_id()
    if not id then return create_session():next(pin_session) end

    return fetch_session(id)
      :catch(function() return nil end)
      :next(function(session)
        if session and session.id then return pin_session(session) end
        return create_session():next(pin_session)
      end)
  end

  local function wait_for_launcher(attempt)
    local id = read_session_id()
    if id then
      return fetch_session(id)
        :catch(function() return nil end)
        :next(function(session)
          if session and session.id then return pin_session(session) end
          return create_session():next(pin_session)
        end)
    end

    if attempt >= 100 then return use_existing_or_create() end

    return Promise.new(function(resolve)
      vim.defer_fn(function() resolve(wait_for_launcher(attempt + 1)) end, 100)
    end)
  end

  local pending = (opencode_launcher_started and wait_for_launcher(0) or use_existing_or_create())
    :finally(function()
      opencode_session_pending = nil
    end)

  opencode_session_pending = pending
  return pending
end

local function connect_opencode()
  local server_module = require("opencode.server")
  local Promise = require("opencode.promise")

  local function pin(server)
    return ensure_opencode_session(server):next(function(session)
      -- 所有 prompt/command 都固定回到這個 Neovim instance 的 session。
      server.resolve_session = function() return Promise.resolve(session) end
      return server
    end)
  end

  if server_module.connected and server_module.connected.url == opencode_url then
    return server_module.connected:connect():next(pin)
  end

  return server_module.new(opencode_url):next(function(server)
    return server:connect()
  end):next(pin)
end

local function resolve_opencode_server()
  if opencode_server_pending then return opencode_server_pending end

  local Promise = require("opencode.promise")
  local server_opts = require("opencode.config").opts.server

  local function wait_for_local_server(attempt)
    return probe_opencode(opencode_url):next(function(result)
      if result.code == 0 and result.status == "200" then
        return connect_opencode()
      end
      if result.status == "401" or result.status == "403" then
        return Promise.reject("OpenCode 認證失敗，請確認 OPENCODE_SERVER_PASSWORD")
      end
      if result.code == 0 and result.status ~= "000" and result.status ~= "" then
        return Promise.reject("OpenCode API 回傳 HTTP " .. result.status)
      end
      if attempt >= 30 then return Promise.reject("OpenCode server 啟動逾時") end

      return Promise.new(function(resolve)
        vim.defer_fn(function() resolve(wait_for_local_server(attempt + 1)) end, 500)
      end)
    end)
  end

  local pending = probe_opencode(opencode_url):next(function(result)
    if result.code == 0 and result.status == "200" then
      return connect_opencode()
    end

    if result.code == 0 and result.status ~= "000" and result.status ~= "" then
      local message = "OpenCode API 回傳 HTTP " .. result.status
      if result.status == "401" or result.status == "403" then
        message = "OpenCode 認證失敗，請確認 OPENCODE_SERVER_PASSWORD"
      end
      return Promise.reject(message)
    end

    local start = server_opts.start
    if type(start) ~= "function" then
      return Promise.reject("找不到這個 Neovim instance 配對的 OpenCode server")
    end
    local ok, start_err = pcall(start)
    if not ok then return Promise.reject("OpenCode 啟動失敗：" .. tostring(start_err)) end
    return wait_for_local_server(0)
  end)

  opencode_server_pending = pending:finally(function() opencode_server_pending = nil end)
  return opencode_server_pending
end

local function with_opencode_server(callback)
  return resolve_opencode_server()
    :next(callback)
    :catch(function(err)
      if err then vim.notify(err, vim.log.levels.ERROR, { title = "opencode" }) end
    end)
end

local function select_opencode()
  with_opencode_server(function(server)
    local context = require("opencode.context").new(server)
    return require("opencode.ui.select").select(context)
  end)
end

local function prompt_opencode(context, prompt)
  -- connect_opencode() 已把 resolve_session 固定到這個 Neovim instance 的 session。
  return require("opencode.api.prompt").prompt(prompt, context)
end

local function send_to_opencode(prompt)
  with_opencode_server(function(server)
    local context = require("opencode.context").new(server)
    return prompt_opencode(context, prompt)
  end)
end

local function ask_opencode()
  if opencode_ask_pending then return end
  opencode_ask_pending = true

  with_opencode_server(function(server)
    local context = require("opencode.context").new(server)
    return require("opencode.ui.ask").ask("@this: ", context):next(function(prompt)
      return prompt_opencode(context, prompt)
    end)
  end):finally(function() opencode_ask_pending = false end)
end

return {
  {
    -- Upstream owner 實際大小寫為 NickvanDyke（GitHub username 不分大小寫，
    -- 但寫法跟 upstream 一致，方便對 issue/release）
    "NickvanDyke/opencode.nvim",
    -- 預設追蹤 main，以支援 OpenCode 2
    dependencies = {
      {
        ---@module "snacks" <- Loads `snacks.nvim` types for configuration intellisense
        "folke/snacks.nvim",
        opts = {
          input = {}, -- Enhances `ask()`
          picker = { -- Enhances `select()`
            actions = {
              opencode_send = function(picker)
                local items = vim.tbl_map(function(item)
                  return item.file
                    and require("opencode").format({ path = item.file, from = item.pos, to = item.end_pos })
                    or item.text
                end, picker:selected({ fallback = true }))

                send_to_opencode(table.concat(items, ", ") .. " ")
              end,
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
        -- 先連既有 server；沒有時啟動內部 TUI，等 API 就緒後才開 ask UI。
        ask_opencode,
        mode = { "n", "x" },
        desc = "Ask opencode…",
      },
      {
        "<leader>os",
        select_opencode,
        mode = { "n", "x" },
        desc = "Select opencode action",
      },
    },
    -----------------------------------------------------------
    -- 本檔案保留兩種啟動方式：
    --
    -- 1. :OpencodeStart（init 區塊）
    --    在「外部終端」開一個獨立視窗跑 opencode。適合想把 opencode
    --    留在背景持續使用、或不希望佔用 Neovim 視窗 split 的情境。
    --
    -- 2. opencode.nvim 預設流程（config 區塊裡的 server.start）
    --    透過 snacks.terminal 在「Neovim 內部 split」開 opencode。
    --    適合純 prompt → response 流程，跟編輯器整合度高。
    --
    -- 兩者共用這個 Neovim instance 分配的 port；已啟動時直接連回同一個 server。
    -----------------------------------------------------------
    init = function()
      -- :OpencodeStart - 在 Neovim 當前 cwd 開啟一個外部終端並執行 opencode
      -- 註冊在 init 區塊以確保開機後立即可用，不需先觸發 plugin lazy load
      vim.api.nvim_create_user_command("OpencodeStart", function()
        local platform = require("utils.platform")
        local cwd = vim.fn.getcwd()
        local job_input -- 可為 list 或 string，jobstart 兩種都接受

        if platform.is_win then
          -- Windows：在外部 PowerShell 視窗中啟動獨立 server 和 TUI。
          job_input = string.format(
            'cmd /c start "opencode (port %d)" %s',
            port,
            windows_session_command(cwd, true)
          )
        elseif platform.is_mac then
          -- 透過 osascript 開啟一個新的 Terminal 視窗執行 opencode
          local password_file = posix_password_file()
          local command = posix_session_command(cwd, password_file)
          command = command:gsub("\\", "\\\\"):gsub('"', '\\"')
          local script = 'tell application "Terminal" to do script "' .. command .. '"'
          job_input = { "osascript", "-e", script, "-e", 'tell application "Terminal" to activate' }
        else
          -- Linux：嘗試以常見終端機開啟（找得到哪個就用哪個）
          --
          -- 不同終端對「-e + 命令」的解讀不一致：
          --   - x-terminal-emulator (Debian alt)：-e 通常只吃「單一字串」，
          --     底層連到不同 emulator 時對多 args 行為不同
          --   - gnome-terminal：用 `--` 結束參數，後面才是命令 + 多個 args
          --   - konsole / xterm：-e 後面可以接多個 args
          local password_file = posix_password_file()
          local cmd_str = posix_session_command(cwd, password_file)

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
            vim.fn.delete(password_file)
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
          width = 60, -- 固定 60 欄；想用比例可改成 <1 的數值（例如 0.3）
          keys = {
            -- 連按兩次 Ctrl-\ 離開 Terminal mode；第二次不會送給 opencode。
            -- 只映射兩鍵序列，所以 <C-\><C-n>、<C-\><C-o> 仍可正常使用。
            ['<C-\\><C-\\>'] = {
              '<C-\\><C-n><C-w>h',
              mode = 't',
              expr = true, -- snacks 會把字串包成 action 函式，需 expr 才會採用回傳值
              desc = '離開 Terminal mode（連按兩次 Ctrl-\\）',
            },
          },
        },
      }

      ---@type opencode.Opts
      -- 直接設定 vim.g，並確保 server 參數正確
      vim.g.opencode_opts = {
        server = {
          url = opencode_url, -- 將插件的其他 API 呼叫也限制在這個 Neovim instance 的 server
          connect = true,
          password = ensure_opencode_password(), -- 插件 API 也要用同一組 server 密碼

          -- 只有找不到既有 server 時，才啟動內部 TUI；TUI 與 prompt 都固定在這個 instance 的 session。
          start = function()
            require('snacks.terminal').open(opencode_session_command(vim.fn.getcwd()), snacks_terminal_opts)
          end,
        },
      }
    end,
  },
}

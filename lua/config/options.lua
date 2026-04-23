-----------------------------------------------------------
-- General Neovim settings and configuration
-----------------------------------------------------------

-- Default options are not included
-- See: https://neovim.io/doc/user/vim_diff.html
-- [2] Defaults - *nvim-defaults*

local g = vim.g       -- Global variables
local opt = vim.opt    -- Set options (global/buffer/windows-scoped)
local api = vim.api    --
local lsp = vim.lsp    --
local cmd = vim.cmd    --
local fn = vim.fn      --

-----------------------------------------------------------
-- General
-----------------------------------------------------------
opt.mouse = 'a'                                    -- Enable mouse support
--opt.clipboard = 'unnamedplus'                    -- Copy/paste to system clipboard
opt.swapfile = false                               -- Don't use swapfile
opt.shadafile = 'NONE'                             -- Disable ShaDa
opt.completeopt = 'menu,menuone,noinsert,noselect' -- Autocomplete options
opt.autoread = true                                -- 檔案被修改後自動讀取
opt.autochdir = false                              -- 不自動變更工作目錄
opt.path:remove("/usr/include")
opt.path:append("**")                              -- 設定搜尋路徑為當前目錄下的所有子目錄
opt.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,winpos,terminal"
opt.wildignorecase = true
opt.wildignore:append("**/.git/*")
opt.wildignore:append("**/build/*")
cmd([[set timeoutlen=1500]])                      -- 延長 timeout 時間為 1500 毫秒


-----------------------------------------------------------
-- Neovim UI
-----------------------------------------------------------
opt.number = true                -- Show line number
opt.relativenumber = true        -- 顯示相對行號
opt.showmatch = true             -- Highlight matching parenthesis
opt.foldmethod = 'marker'        -- Enable folding (default 'foldmarker')
--opt.colorcolumn = '80'         -- Line lenght marker at 80 columns
opt.wrap = false                 -- 不自動換行
opt.splitright = true            -- Vertical split to the right
opt.splitbelow = true            -- Horizontal split to the bottom
opt.ignorecase = false           -- Ignore case letters when search
opt.smartcase = true             -- Ignore lowercase for the whole pattern
opt.linebreak = true             -- Wrap on word boundary
opt.termguicolors = true         -- Enable 24-bit RGB colors
--vim.o.t_Co = 256               -- RGB-256
opt.laststatus = 3               -- Set global statusline
opt.showcmd = true               -- 顯示未完成的指令
opt.showmode = false             -- 不顯示當前模式
opt.scrolloff = 10               -- 捲動時保持游標靠近邊緣的距離
opt.signcolumn = 'yes'           -- 顯示符號欄
opt.incsearch = true             -- 啟用動態搜尋
opt.list = true                  -- 顯示空格、Tab 等特殊符號
--opt.listchars = 'tab:»»,trail:·' -- 定義特殊符號的顯示方式
opt.listchars:append({
  tab = "»»",
  trail = "·"
})
opt.cursorline = true            -- 顯示游標所在行
cmd([[syntax on]])               -- 啟用語法Highlight
g.c_syntax_for_h = 1             -- 讓 .h 檔案也啟用 C 語言的 Highlight
opt.guifont='Consolas:h12'

-----------------------------------------------------------
-- Tabs, indent
-----------------------------------------------------------
opt.expandtab = true             -- Use spaces instead of tabs
opt.shiftwidth = 4               -- Shift 4 spaces when tab
opt.softtabstop = 4              -- 按下退格時退回多少個空格
opt.tabstop = 4                  -- 1 tab == 4 spaces
opt.smartindent = true           -- Autoindent new lines
opt.autoindent = true            -- 在輸入新行時，自動將游標移動到縮排正確的位置
--cmd([[retab]])                   -- 將已經存在的 Tab 轉為空格

-----------------------------------------------------------
-- Memory, CPU
-----------------------------------------------------------
opt.hidden = false               -- Enable background buffers
opt.history = 20                 -- Remember N lines in history
opt.lazyredraw = true            -- Faster scrolling
opt.synmaxcol = 240              -- Max column for syntax highlight
opt.updatetime = 1000            -- ms to wait for trigger an event (used by LSP CursorHold diagnostic)


-----------------------------------------------------------
-- LSP
-----------------------------------------------------------
-- disable log
-- Levels by name: "TRACE", "DEBUG", "INFO", "WARN", "ERROR", "OFF"
lsp.set_level("OFF")
-- Hide all semantic highlights
for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
  api.nvim_set_hl(0, group, {})
end
-- 1. 全域禁用內建 Tag，防止沒 LSP 時按到噴紅字 (E433)
vim.keymap.set('n', '<C-]>', '<nop>')

-- 2. 設定 LSP Attach 自動指令
local fidget_ok, fidget = pcall(require, "fidget")

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    -- 檢查該 LSP 是否支援跳轉功能
    if client and client.server_capabilities.definitionProvider then
      vim.keymap.set('n', '<C-]>', function()
        local word = vim.fn.expand('<cword>')

        -- 1. 建立 Fidget 進度條 (英文提示)
        if fidget_ok then
          local handle = fidget.progress.handle.create({
            title = "LSP Searching...",
            message = "Finding definition of '" .. word .. "'",
            lsp_client = { name = client.name },
          })

          -- 2. 獲取參數並明確傳入編碼以消除警告
          local params = vim.lsp.util.make_position_params(0, client.offset_encoding)

          -- 3. 發送 LSP 請求
          client.request('textDocument/definition', params, function(err, result, ctx, _)
            -- 收到結果後立刻結束 Fidget
            handle:finish()

            -- 4. 處理錯誤與找不到的情況 (英文通知)
            if err then
              fidget.notify("LSP Error: " .. err.message, vim.log.levels.ERROR)
              return
            end

            if not result or vim.tbl_isempty(result) then
              fidget.notify("No definition found for '" .. word .. "'", vim.log.levels.WARN)
              return
            end

            -- 5. 執行跳轉
            -- 處理單個或多個結果 (If result is a list, take the first one)
            local location = vim.islist(result) and result[1] or result

            -- 使用新版函式跳轉，消除 Deprecated 警告
            vim.lsp.util.show_document(location, client.offset_encoding, { focus = true })

          end, ev.buf)
        else
          -- 如果 fidget 未載入，直接使用 vim.lsp.util.jump
          local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
          client.request('textDocument/definition', params, function(err, result, _, _)
            if err then
              vim.notify("LSP Error: " .. err.message, vim.log.levels.ERROR)
              return
            end
            if not result or vim.tbl_isempty(result) then
              vim.notify("No definition found for '" .. word .. "'", vim.log.levels.WARN)
              return
            end
            local location = vim.islist(result) and result[1] or result
            vim.lsp.util.show_document(location, client.offset_encoding, { focus = true })
          end, ev.buf)
        end
      end, { buffer = ev.buf, desc = "LSP Jump (English UI)" })
    end
  end,
})



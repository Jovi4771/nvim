-----------------------------------------------------------
-- General Neovim settings and configuration
-----------------------------------------------------------

-- Default options are not included
-- See: https://neovim.io/doc/user/vim_diff.html
-- [2] Defaults - *nvim-defaults*

local g   = vim.g       -- Global variables
local opt = vim.opt     -- Set options (global/buffer/windows-scoped)
local api = vim.api     --
local lsp = vim.lsp     --
local cmd = vim.cmd     --
local fn  = vim.fn      --

-----------------------------------------------------------
-- General
-----------------------------------------------------------
opt.mouse = 'a'                                    -- Enable mouse support
opt.clipboard = 'unnamedplus'                    -- Copy/paste to system clipboard
opt.swapfile = false                               -- Don't use swapfile
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
opt.updatetime = 250             -- ms to wait for trigger an event


-----------------------------------------------------------
-- LSP
-----------------------------------------------------------
-- disable log
-- Levels by name: "TRACE", "DEBUG", "INFO", "WARN", "ERROR", "OFF"
lsp.set_log_level("OFF")

-- Hide all semantic highlights
for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
  api.nvim_set_hl(0, group, {})
end







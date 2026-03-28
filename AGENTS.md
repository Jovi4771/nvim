# AGENTS.md - Neovim 配置指南

## 概述

這是一個使用 lazy.nvim 作為插件管理器的個人 Neovim 配置專案。配置使用 Lua 編寫，並按功能模組化組織。

## 專案結構

```
nvim/
├── init.lua                 # 入口點
├── lua/
│   ├── config/              # 核心配置
│   │   ├── options.lua       # Neovim 選項
│   │   ├── keymaps.lua      # 鍵位映射
│   │   ├── autocmds.lua     # 自動命令
│   │   └── functions.lua    # 自訂函數
│   ├── plugins/             # 插件配置
│   │   ├── init.lua         # 插件規格聚合器
│   │   ├── lsp.lua          # LSP 配置
│   │   ├── ui.lua           # UI 插件（主題、狀態列、alpha）
│   │   ├── telescope.lua    # 檔案搜尋
│   │   ├── tools.lua        # 編輯器工具
│   │   ├── ai.lua           # AI 輔助
│   │   └── misc.lua         # 其他插件
│   └── utils/               # 工具模組
│       └── clangd.lua
├── README.md
└── lazy-lock.json          # 鎖定的插件版本
```

## 建置/程式碼檢查/測試命令

這是 Neovim 配置，不是軟體專案。沒有傳統的建置/測試命令。

### 插件管理

```bash
# 同步插件（安裝/更新）
:LazySync

# 查看插件狀態
:Lazy

# 清理未使用的插件
:Lazy clean

# 分析插件載入效能
:Lazy profile

# 除錯插件問題
:Lazy debug
```

### 配置驗證

```bash
# 檢查 Neovim 配置
:checkhealth

# 檢查特定插件
:checkhealth telescope
:checkhealth lspconfig

# 重新載入配置
:source $MYVIMRC
```

### LSP 命令

```bash
# 啟動 LSP 伺服器
:LspStart

# 停止 LSP 伺服器
:LspStop

# LSP 資訊
:LspInfo
```

## 程式碼風格指南

### 檔案組織

1. **一個插件一個檔案**：每個插件在 `lua/plugins/` 下有自己的檔案
2. **功能分組**：將相關插件分組（例如 lsp.lua、ui.lua、tools.lua）
3. **使用 lazy.nvim 規格格式**：所有插件配置返回帶有 lazy.nvim 規格的表格

### 插件規格格式

```lua
-- lua/plugins/example.lua
return {
  {
    "owner/repo",           -- GitHub 倉庫（必填）
    event = "VimEnter",     -- 載入事件（可選）
    -- 或 cmd = "CommandName"
    -- 或 keys = { {"key", "map"} }
    
    dependencies = {         -- 可選依賴
      "other/plugin",
    },
    
    opts = {                -- 插件選項（傳遞給 setup()）
    },
    
    config = function()     -- 配置函數
    end,
    
    init = function()       -- 初始化（較早執行）
    end,
  },
}
```

### 命名慣例

| 類型 | 慣例 | 範例 |
|------|------|------|
| 檔案 | snake_case.lua | `lsp_config.lua` |
| 函數 | camelCase | `setupLSP()` |
| 變數 | snake_case | `local config = {}` |
| 常數 | UPPER_SNAKE | `local DEFAULT_PORT = 8080` |
| 鍵位 | 描述性 | `<leader>ff` 表示「找檔案」 |

### 匯入

```lua
-- 使用 require 匯入模組
local M = {}

-- Neovim API 快捷別名（可選但建議使用）
local fn = vim.fn
local api = vim.api
local cmd = vim.cmd
local opt = vim.opt
local g = vim.g

-- 延遲載入插件模組
return M
```

### 格式化

1. **使用註解**：解釋「為什麼」而非「做什麼」
2. **區段標題**：主要區段使用破折號
3. **一致的縮排**：Lua 使用 2 個空格
4. **尾隨逗號**：Lua 表格中允許
5. **最大行長**：建議約 100 個字元

### 鍵位定義

```lua
-- 使用輔助函數保持鍵位一致
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- 範例
map('n', '<leader>c', ':nohl<CR>')
map('v', '<leader>y', '"*y')
```

### 選項配置

```lua
-- 使用 vim.opt 配置選項
vim.opt.number = true
vim.opt.relativenumber = true

-- 使用表格 API 配置列表選項
vim.opt.path:append("**")
vim.opt.wildignore:append("*.log")
```

### 錯誤處理

```lua
-- 使用 pcall 處理可選依賴
local status_ok, module = pcall(require, "optional/module")
if status_ok then
  -- 安全使用模組
end

-- 檢查插件可用性
if vim.fn.has("win32") == 1 then
  -- Windows 專用程式碼
end
```

### 延遲載入

始終使用延遲載入以改善啟動時間：

```lua
-- 按事件
{ "plugin/name", event = "BufReadPost" }

-- 按命令
{ "plugin/name", cmd = "PluginCommand" }

-- 按鍵位
{ "plugin/name", keys = { {"<leader>f", "<cmd>PluginFunc<CR>"} } }

-- 按檔案類型
{ "plugin/name", ft = { "lua", "python" } }
```

## 重要提醒

1. **未經同意不刪除**：未經用戶明確同意，永遠不要刪除插件或重要功能
2. **測試變更**：始終使用 `:LazySync` 和重啟來驗證變更
3. **重構前備份**：重構前提交工作狀態
4. **尊重用戶偏好**：除非要求更改，否則保持現有鍵位和工作流程不變
5. **Win32 相容性**：此配置主要用於 Windows（win32）

## 常見任務

### 添加新插件

1. 在 `lua/plugins/` 創建新檔案或添加到現有分組
2. 使用 lazy.nvim 規格格式
3. 添加適當的延遲載入（event/cmd/keys）
4. 使用 `:LazySync` 測試

### 修改鍵位

鍵位定義在 `lua/config/keymaps.lua`。使用 `map()` 輔助函數。

### 更改主題

主題配置在 `lua/plugins/ui.lua`（預設為 gruvbox）。

### 除錯問題

1. 執行 `:checkhealth` 識別問題
2. 使用 `:Lazy debug` 處理插件問題
3. 檢查 `:messages` 獲取錯誤
4. 查看插件文檔

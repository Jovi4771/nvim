# Jovi's Neovim

個人 Neovim 配置，使用 lazy.nvim 管理插件。

## ✨ Features

- **LSP** - clangd, lua_ls, pyright
- **搜尋** - Telescope (+ file browser)
- **AI** - OpenCode 整合
- **Session** - Possession 管理工作階段
- **UI** - Gruvbox 主題、Lualine 狀態列、Alpha 啟動畫面

## ⚡️ Requirements

```powershell
# Neovim
scoop install neovim

# 搜尋引擎
scoop install ripgrep

# 語言伺服器
scoop install clangd
scoop install lua-language-server

# 其他工具
scoop install nodejs
scoop install python

# Python 相關
python -m pip install neovim
```

## 📁 Project Structure

```
nvim/
├── init.lua                 # 入口點
├── lua/
│   ├── config/              # 核心配置
│   │   ├── options.lua      # Neovim 選項
│   │   ├── keymaps.lua     # 鍵位映射
│   │   ├── autocmds.lua    # 自動命令
│   │   └── functions.lua   # 自訂函數
│   ├── plugins/             # 插件配置
│   │   ├── init.lua        # 插件總表
│   │   ├── lsp.lua         # LSP 配置
│   │   ├── ui.lua          # UI 組件
│   │   ├── telescope.lua    # 檔案搜尋
│   │   ├── tools.lua       # 工具類
│   │   ├── ai.lua          # AI 輔助
│   │   └── misc.lua        # 其他插件
│   └── utils/
│       └── clangd.lua      # Clangd 工具
└── lazy-lock.json
```

## ⌨️ Keymaps

| 按鍵 | 功能 |
|------|------|
| `<Space>` | Leader key |
| `<leader>c` | 清除搜尋反白 |
| `<leader>ff` | 找檔案 |
| `<leader>bb` | 找 Buffer |
| `<leader>fb` | 檔案瀏览器 |
| `<C-\>a` | 搜尋文字 |
| `<C-a>` | 詢問 OpenCode |
| `<C-x>` | OpenCode 功能選單 |
| `go` | 對選取範圍提問 |
| `<F2>` | 編輯 Vimrc |
| `<C-Right>` | 下一個 Buffer |
| `<C-Left>` | 上一個 Buffer |

## 📦 Installation

```powershell
# 克隆專案
git clone https://github.com/Jovi4771/nvim.git $env:LOCALAPPDATA\nvim

# 啟動 Neovim（會自動安裝插件）
nvim
```

## 🔧 Commands

```vim
" 同步插件
:LazySync

" 檢查健康
:checkhealth

" 重新載入配置
:source $MYVIMRC
```

## 📋 Plugins

| 類別 | 插件 |
|------|------|
| **LSP** | nvim-lspconfig, mason.nvim |
| **UI** | gruvbox, lualine, alpha-nvim |
| **搜尋** | telescope.nvim, telescope-file-browser |
| **工具** | possession, vim-surround, targets.vim |
| **AI** | opencode.nvim, snacks.nvim |
| **其他** | which-key, indentLine, nvim-notify |

return {
  --[[
  -- gruvbox (lua)
  {
    "ellisonleao/gruvbox.nvim"
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
  --]]

  -- gruvbox (vimscript)
  {
    "gruvbox-community/gruvbox",
    lazy = false,

    init = function()
      -- 設置主題選項
      vim.g.gruvbox_italic = 0    -- 不啟用斜體
      vim.g.gruvbox_bold = 1      -- 啟用粗體
      vim.g.gruvbox_underline = 0 -- 不啟用底線

      -- 設置主題
      vim.api.nvim_set_option("background", "dark") -- 設置暗色主題
      vim.cmd("colorscheme gruvbox")  -- enable gruvbox

      -- 其他補充
      vim.cmd("hi! link PreCondit GruvboxAquaBold") -- 設定預處理器的顏色 (#if, #else, #endif, .. etc)
      vim.cmd("highlight Comment ctermfg=73 guifg=#6CA6D4") -- 註解顏色
      --vim.cmd("highlight ExtraWhitespace ctermbg=white guibg=#E8F9FB") -- 顯示空白底色
      --vim.cmd("match ExtraWhitespace /\\s\\+$/")

    end,
  },
}

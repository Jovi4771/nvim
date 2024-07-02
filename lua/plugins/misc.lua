return {
  -- rooter
  {
    "notjedi/nvim-rooter.lua",
    opts = {
      rooter_patterns   = { '.svn', '.git', '.root' }, -- root
      trigger_partterns = { "*" },
      manual            = false,
    },
  },

  -- font size (gui)
  {
    "ktunprasert/gui-font-resize.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<C-=>",
        --":GUIFontSizeUp<CR>",
        ":lua GuiFontResizeUp()<CR>",
      },

      {
        "<C-->",
        --":GUIFontSizeDown<CR>",
        ":lua GuiFontResizeDown()<CR>",
      },
    },

    init = function()
      require("gui-font-resize").setup({
        default_size = 12, -- absolute size it will fallback to when :GUIFontSizeSet is not specified
        change_by = 1, -- step value that will inc/dec the fontsize by
        bounds = {
            maximum = 24, -- maximum font size, when you try to set a size bigger than this it will default to max
            minimum = 8, -- any modification lower than 8 will spring back to 8
        },
      })
    end,
  },

  -- vim 常用設定
  {
    "tpope/vim-sensible",
    event = "VeryLazy",
  },

  -- surround
  {
    "tpope/vim-surround",
    event = "VeryLazy",
  },

  -- textobject "a"
  {
    "wellle/targets.vim",
    event = "VeryLazy",
  },

  -- 顯示縮排
  {
    "Yggdroot/indentLine",
    lazy = false,

    init = function()
      vim.g.indentLine_bufNameExclude = { "Alpha", "alpha", "mason" } -- disable list
      vim.g.indentLine_color_gui = "#787e87"
    end,
  },

  -- C highlight
  {
    "octol/vim-cpp-enhanced-highlight",
    event = "VeryLazy",

    init = function()
      -- Highlight #Define
      vim.cmd([[syn match defined "\v\w@<!(\u|_|r+[A-Z0-9])[A-Z0-9_]*\w@!"]])
      vim.cmd([[hi def link defined Type]])

      -- Highlight global variable
      vim.cmd([[syn match globalVariable "\vg([A-Z][A-Za-z0-9_]+)+" ]])
      vim.cmd([[hi globalVariable ctermfg=217 guifg=#FF7FC9]])

      -- Highlight private variable
      vim.cmd([[syn match privateVariable "\vp([A-Z][A-Za-z0-9_]+)+" ]])
      vim.cmd([[hi privateVariable ctermfg=217 guifg=#CDC1FF]])
    end,
  },

  -- auto resize windows
  {
    "justincampbell/vim-eighties",
    event = "VeryLazy",
  },

  -- quickfix windows preview
  {
    "kevinhwang91/nvim-bqf",
    event = "VeryLazy",
  },

  -- ui patch
  {
    "nvim-lua/plenary.nvim",
    lazy = true,
  },

  -- icons
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },

  -- smoothly scroll
  {
    "psliwka/vim-smoothie",
    event = "VeryLazy",
  },

  -- notify
  {
    "rcarriga/nvim-notify",
    background_colour = "#000000",
    fps = 30,
    icons = {
      DEBUG = "🐛",
      ERROR = "💀",
      INFO  = "✅",
      WARN  = "⚠ ",
    },
    level = 2,
    minimum_width = 50,
    render = "compact",
    stages = "fade_in_slide_out",
    timeout = 5000,
    top_down = true,

    init = function()
      vim.notify = require("notify")
    end,
  },
}

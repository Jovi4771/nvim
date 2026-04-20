-----------------------------------------------------------
-- Miscellaneous Plugins
-- which-key, rooter, fonts, editor tools, etc.
-----------------------------------------------------------

return {

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.opt.timeout = true
      vim.opt.timeoutlen = 300
    end,
    opts = {
      triggers = {}, -- 註解此行以啟用自動彈出 which-key popup
      ["<leader>"] = {
        f = { name = "+file" },
        b = { name = "+buffer" },
        p = { name = "+project" },
        g = { name = "+git" },
        s = { name = "+search" },
        t = { name = "+toggle" },
        d = { name = "+debug" },
      },
    },
  },

  -- rooter
  {
    "notjedi/nvim-rooter.lua",
    opts = {
      --rooter_patterns   = { '.cache', '.setting', '.svn', '.git', '.root' }, -- root
      rooter_patterns   = { '.root' }, -- root
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
    event = "VeryLazy",

    init = function()
      vim.g.indentLine_bufNameExclude = { "Alpha", "alpha", "mason" } -- disable list
      vim.g.indentLine_color_gui = "#787e87"
    end,
  },

  -- C highlight
  {
    "octol/vim-cpp-enhanced-highlight",
    event = "VeryLazy",
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

  -- smoothly scroll
  {
    "psliwka/vim-smoothie",
    event = "VeryLazy",
  },

  -- notify
  {
    "rcarriga/nvim-notify",
    opts = {
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
    },
    init = function()
      vim.notify = require("notify")
    end,
  },
}

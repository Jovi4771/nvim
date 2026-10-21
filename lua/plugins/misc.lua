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
      -- timeoutlen 統一在 config/options.lua 設定
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
      --rooter_patterns  = { '.cache', '.setting', '.svn', '.git', '.root' }, -- root
      rooter_patterns  = { '.root' },
      -- 停用上游的 BufEnter：其 activate() 用 string.format 把 buffer 名稱
      -- 塞進 nvim_eval，名稱含 " 時（例如 opencode 的 term:// 指令）會噴 E488。
      -- 改用下方自訂的 autocmd，只呼叫不會碰 nvim_eval 的 get_root()。
      manual           = true,
    },
    config = function(_, opts)
      local rooter = require("nvim-rooter")
      rooter.setup(opts)

      vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("RooterSafe", { clear = true }),
        callback = function(args)
          -- 只處理真實檔案 buffer，終端/qf/nofile 一律跳過
          if vim.bo[args.buf].buftype ~= "" then return end

          local ok, root = pcall(rooter.get_root)
          if not ok or not root then return end
          if vim.fn.getcwd() ~= root then
            vim.api.nvim_set_current_dir(root)
          end
        end,
      })
    end,
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

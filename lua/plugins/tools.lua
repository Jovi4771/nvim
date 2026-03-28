-----------------------------------------------------------
-- Tools and Utilities
-- Combines: possession + spectre + vim-quickhl + vim-table-mode + vim-visual-multi
-----------------------------------------------------------

return {
  {
    "jedrzejboczar/possession.nvim",
    lazy = false,
    init = function()
      local sessionpath = vim.fn.stdpath("data") .. "/.cache/nvim-sessions"
      vim.fn.mkdir(sessionpath, 'p')
    end,
    opts = {
      session_dir  = vim.fn.stdpath("data") .. "/.cache/nvim-sessions",
      silent       = false,
      load_silent  = true,
      debug        = false,
      logfile      = false,
      prompt_no_cr = false,
      autosave = {
        current  = true,
        tmp      = false,
        tmp_name = 'tmp',
        on_load  = false,
        on_quit  = true,
      },
      commands = {
        save    = 'PossessionSave',
        load    = 'PossessionLoad',
        close   = 'PossessionClose',
        delete  = 'PossessionDelete',
        show    = 'PossessionShow',
        list    = 'PossessionList',
        migrate = 'PossessionMigrate',
      },
      hooks = {
        before_save = function(name) return {} end,
        after_save  = function(name, user_data, aborted) end,
        before_load = function(name, user_data) return user_data end,
        after_load  = function(name, user_data)
          if #name > 0 then
            local title = '' .. name
            vim.cmd('silent set titlestring=' .. title)
            vim.cmd('silent set title titlestring')
          end
        end,
      },
      plugins = {
        close_windows = {
          hooks = {'before_save', 'before_load'},
          preserve_layout = true,
          match = {
            floating = true,
            buftype  = {},
            filetype = {},
            custom   = false,
          },
        },
        delete_hidden_buffers = {
          hooks = {
            'before_load',
            vim.o.sessionoptions:match('buffer') and 'before_save',
          },
          force = false,
        },
        nvim_tree      = true,
        tabby          = true,
        dap            = true,
        delete_buffers = true,
      },
    },
  },

  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    opts = { open_cmd = "noswapfile vnew" },
    keys = {
      { "<leader>rn", function() require("spectre").open_visual({select_word=true}) end, desc = "Replace in files (Spectre)" },
    },
  },

  {
    "t9md/vim-quickhl",
    event = "VeryLazy",
    keys = {
      { "<leader>k", mode = {"n", "x", "o"}, "<Plug>(quickhl-manual-this)" },
      { "<leader>K", "<Plug>(quickhl-manual-reset)" },
      { "<leader>dk", ":QuickhlManualDelete<CR>" },
    },
    init = function()
      vim.g.quickhl_manual_enable_at_startup = 1
      vim.g.quickhl_manual_hl_priority = 15
      vim.g.quickhl_manual_colors = {
        "gui=bold ctermfg=7 ctermbg=11  guifg=#000000 guibg=#ff5f5f",
        "gui=bold ctermfg=7 ctermbg=33  guifg=#000000 guibg=#ff8700",
        "gui=bold ctermfg=7 ctermbg=44  guifg=#000000 guibg=#ffd700",
        "gui=bold ctermfg=7 ctermbg=55  guifg=#000000 guibg=#00d700",
        "gui=bold ctermfg=7 ctermbg=66  guifg=#000000 guibg=#00af5f",
        "gui=bold ctermfg=7 ctermbg=77  guifg=#000000 guibg=#5fd7d7",
        "gui=bold ctermfg=7 ctermbg=88  guifg=#000000 guibg=#0087ff",
        "gui=bold ctermfg=7 ctermbg=99  guifg=#000000 guibg=#afafff",
        "gui=bold ctermfg=7 ctermbg=110 guifg=#000000 guibg=#875fff",
        "gui=bold ctermfg=7 ctermbg=121 guifg=#000000 guibg=#b2b2b2",
        "gui=bold ctermfg=7 ctermbg=132 guifg=#000000 guibg=#e4e4e4",
      }
    end,
  },

  {
    "dhruvasagar/vim-table-mode",
    event = "VeryLazy",
    init = function()
      vim.g.table_mode_corner = '|'
      vim.g.table_mode_corner_corner = '+'
    end,
  },

  {
    "mg979/vim-visual-multi",
    event = "VeryLazy",
    keys = {
      { "<C-Down>", "<Plug>(VM-add-Cursor-Down)" },
      { "<C-Up>", "<Plug>(VM-add-Cursor-Up)" },
    },
    init = function()
      vim.g.VM_leader = "\\"
      vim.g.VM_case_setting = "sensitive"
    end,
  },
}

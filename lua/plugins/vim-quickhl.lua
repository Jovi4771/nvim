return {
  -- 多重 highlight
  {
    't9md/vim-quickhl',
    event = VeryLazy,

    keys = {
      {
        "<leader>k",
        mode = {"n", "x", "o"},
        "<Plug>(quickhl-manual-this)",
      },

      {
        "<leader>K",
        "<Plug>(quickhl-manual-reset)",
      },

      {
        "<leader>dk",
        ":QuickhlManualDelete<CR>",
      },
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
}

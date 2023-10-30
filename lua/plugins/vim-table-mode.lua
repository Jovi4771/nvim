return {
  -- table mode
  {
    'dhruvasagar/vim-table-mode',
    event = "VeryLazy",

    init = function()
      vim.g.table_mode_corner = '|'
      vim.g.table_mode_corner_corner = '+'
    end,
  },
}

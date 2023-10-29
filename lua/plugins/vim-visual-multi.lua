return {
  -- multi-edit
  {
    "mg979/vim-visual-multi",
    event = "VeryLazy",

    keys = {
      {
        "<C-Down>",
        "<Plug>(VM-add-Cursor-Down)",
      },

      {
        "<C-Up>",
        "<Plug>(VM-add-Cursor-Up)",
      },

      {
        "<C-Up>",
        "<Plug>(VM-add-Cursor-Up)",
      },
    },

    init = function()
      vim.g.VM_leader = "\\"
    end,
  },
}

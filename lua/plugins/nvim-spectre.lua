

return {
  "nvim-pack/nvim-spectre",
  cmd = "Spectre",
  opts = { open_cmd = "noswapfile vnew" },
  -- stylua: ignore
  keys = {
    {
      "<leader>rn", function() require("spectre").open_visual({select_word=true}) end, desc = "Replace in files (Spectre)"
    },
  },
}

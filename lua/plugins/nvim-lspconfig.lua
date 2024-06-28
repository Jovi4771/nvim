-----------------------------------------------------------
-- Neovim LSP Server
-----------------------------------------------------------
return {
  {
    "neovim/nvim-lspconfig",
    ---lazy = true,
    --event = {"VimEnter", "BufReadPost", "BufNewFile", "BufWritePre"},
    event = {"VimEnter"},
    init = function()
      local lspconfig = require("lspconfig")

      ----------
      -- lua
      ----------
      lspconfig.lua_ls.setup({
        settings = {
          diagnostics = {
            globals = {
              'vim',
              'VeryLazy',
              'VimEnter',
            },
          },
        },
      })

      ----------
      -- c, c++
      ----------
      lspconfig.clangd.setup({
        root_dir = lspconfig.util.root_pattern('compile_commands.json', 'compile_flags.txt', '.root', '.git'),
        settings = {
          diagnostics = {
            enable = true,
            cShadow = "none",
            cppUnusedInclude = "none",
          },
        },
      })
    end,
  },
}

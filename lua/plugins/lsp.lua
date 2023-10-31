-----------------------------------------------------------
-- Neovim LSP Server
-----------------------------------------------------------
return {
  {
    "neovim/nvim-lspconfig",
    lazy = true,
    --event = {"VimEnter", "BufReadPost", "BufNewFile", "BufWritePre"},
    event = {"VimEnter"},
    init = function()
      local lspconfig = require("lspconfig")

      -- lua
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

      -- c, c++
      lspconfig.clangd.setup({
        root_dir = lspconfig.util.root_pattern('compile_commands.json', 'compile_flags.txt', '.root', '.git')
      })

      -- disable log
      -- Levels by name: "TRACE", "DEBUG", "INFO", "WARN", "ERROR", "OFF"
      vim.lsp.set_log_level("OFF")

      -- Hide all semantic highlights
      for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
        vim.api.nvim_set_hl(0, group, {})
      end
    end,
  },
}

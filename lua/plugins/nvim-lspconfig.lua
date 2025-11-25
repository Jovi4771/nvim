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
      ----------
      -- c, c++
      ----------
      vim.lsp.enable('clangd')
      vim.lsp.config('clangd', {
        cmd = {
          'clangd', '--background-index', '--compile-commands-dir=build'
        },
        --root_dir = util.root_pattern('compile_commands.json', 'compile_flags.txt', '.root', '.git'),
        root_markers = {
          'compile_commands.json', 'compile_flags.txt', '.root', '.git'
        },
        settings = {
          diagnostics = {
            enable = true,
            cShadow = "none",
            cppUnusedInclude = "none",
          },
        },
      })

      ----------
      -- lua
      ----------
      vim.lsp.enable('lua_ls')

      ----------
      -- python
      ----------
      vim.lsp.enable('pyright')

      ----------
      -- general
      ----------
      --vim.lsp.config('*', {
      --  capabilities = {
      --    textDocument = {
      --      semanticTokensProvider = nil,
      --      codeLensProvider = nil
      --    }
      --  }
      --)

    end,
  },
}

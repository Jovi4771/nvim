-----------------------------------------------------------
-- LSP Configuration
-- Combines: nvim-lspconfig + mason
-----------------------------------------------------------

return {
  {
    "neovim/nvim-lspconfig",
    event = { "VimEnter" },
    init = function()
      vim.lsp.enable("clangd")
      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index",
          "--compile-commands-dir=build"
        },
        root_markers = {
          "compile_commands.json",
          "compile_flags.txt",
          ".root",
          ".git"
        },
        settings = {
          diagnostics = {
            enable = true,
            cShadow = "none",
            cppUnusedInclude = "none",
          },
        },
      })

      vim.lsp.enable("lua_ls")
      vim.lsp.enable("pyright")
    end,
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "pyright",
      },
    },
  },

  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      handlers = {},
    },
  },
}

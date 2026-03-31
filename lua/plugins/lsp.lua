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
      })

      vim.lsp.enable("lua_ls")
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
          },
        },
      })
      vim.lsp.enable("pyright")
    end,

    config = function()
      vim.opt.updatetime = 1000

      vim.api.nvim_create_autocmd("CursorHold", {
        callback = function()
          vim.diagnostic.open_float(nil, { focus = false, scope = "cursor" })
        end,
      })
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

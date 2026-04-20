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
      vim.api.nvim_create_autocmd("CursorHold", {
        group = vim.api.nvim_create_augroup("LspDiagnosticHover", { clear = true }),
        callback = function()
          require('clean-diagnostic').show()
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

  {
    "kurama622/clean-diagnostic",
    event = "LspAttach",
    opts = {
      sign_text = {
        "❌",   -- error  🔴
        "⚠️",   -- warn   🟠
        "ℹ️",   -- info   🔵
        "💡"    -- hint   🟢
      },
      border = "rounded",
      min_severity = 4,
      max_width = 78,
    },
    --keys = {
    --  {
    --    "<leader>sd",
    --    "<cmd>lua require('clean-diagnostic').show()<cr>",
    --    desc = "show the diagnostic of the current line",
    --  },
    --},
  }
}

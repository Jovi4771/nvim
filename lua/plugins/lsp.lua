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
          clangd = {
            diagnostics = {
              suppress = {
                "implicit",               -- 隱式函數宣告
                "missing-header",         -- 找不到頭文件
                "undeclared_var_use",     -- 使用未宣告的變數
                "unknown_type",           -- 未知類型
                "invalid_ios",            -- 無效的輸入/輸出
                "unsupported_construct", -- 不支援的建構
                "ambiguous-member",       -- 模糊的成員
                "no-member",              -- 沒有成員
                "unused",                 -- 未使用相關
                "unused-variable",        -- 未使用的變數
                "unused-function",        -- 未使用的函數
                "unused-parameter",       -- 未使用的參數
                "unused-include",         -- 未使用的 include
                "err_unknown_type",       -- Clang 內部：錯誤未知類型
                "err_undeclared",         -- Clang 內部：錯誤未宣告
                "warn_implicit_decl",     -- Clang 內部：警告隱式宣告
              },
            },
          },
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
